import 'package:flutter/painting.dart';

import 'tag_format.dart';
import 'style_rule.dart';
import 'token.dart';
import 'cache.dart';

/// Parses a raw string into a flat list of [TextToken]s.
///
/// ## Algorithm
///
/// The parser is a **recursive descent** parser that maintains a style stack.
/// Each time an opening tag is encountered the corresponding [TextStyle] is
/// pushed onto the stack. Each time a closing tag is encountered the top of
/// the stack is popped.
///
/// At every text segment the current effective style is computed by folding
/// the stack top-down with [TextStyle.merge] — child styles win on conflict,
/// parent styles propagate where the child is silent.
///
/// The output is a **flat** list: nesting is fully resolved during parsing.
/// The renderer only needs to create one [TextSpan] per token.
///
/// ## Nesting rules
///
/// - Proper nesting `[a][b]...[/b][/a]` is handled correctly.
/// - Misordered closing tags `[a][b]...[/a][/b]` pop until the named tag
///   is found, discarding intermediate unclosed tags gracefully.
/// - Unclosed tags at end-of-string are silently discarded.
/// - Unknown tags are emitted as literal plain text (delimiters included).
///
/// ## Caching
///
/// When a [TextMarkCache] is provided the result is looked up before parsing
/// and stored after a cache miss, keyed by (text, rulesFingerprint).
class TextMarkParser {
  final TagFormat format;
  final Map<String, StyleRule> rules;
  final TextMarkCache? cache;

  /// Stable fingerprint of the current rule set — used as part of the cache key.
  final int _fingerprint;

  TextMarkParser({
    required this.format,
    required this.rules,
    this.cache,
  }) : _fingerprint = computeRulesFingerprint(rules.keys);

  /// Parses [text] and returns an ordered flat list of [TextToken]s.
  ///
  /// Results are served from [cache] when available, and cache misses are
  /// stored after parsing.
  List<TextToken> parse(String text, {TextStyle? baseStyle}) {
    if (text.isEmpty) return const [];

    if (cache != null) {
      final cached = cache!.get(text, _fingerprint);
      if (cached != null) return cached;
    }

    final tokens = _parse(text, baseStyle: baseStyle);

    cache?.set(text, _fingerprint, tokens);

    return tokens;
  }

  /// Core parsing loop that emits plain and styled tokens in source order.
  List<TextToken> _parse(String text, {TextStyle? baseStyle}) {
    final tokens = <TextToken>[];
    final styleStack = <TextStyle?>[baseStyle];

    int cursor = 0;

    while (cursor < text.length) {
      final remaining = text.substring(cursor);

      final openMatch = format.openPattern.firstMatch(remaining);
      final closeMatch = format.closePattern.firstMatch(remaining);

      final Match? nextMatch = _earliest(openMatch, closeMatch);

      if (nextMatch == null) {
        _flush(tokens, remaining, styleStack);
        break;
      }

      if (nextMatch.start > 0) {
        _flush(tokens, remaining.substring(0, nextMatch.start), styleStack);
      }

      final isOpen = identical(nextMatch, openMatch);

      if (isOpen) {
        _handleOpen(nextMatch, styleStack);
      } else {
        _handleClose(nextMatch, tokens, styleStack);
      }

      cursor += nextMatch.end;
    }

    return tokens;
  }

  /// Handles an opening tag by pushing a new merged style onto [stack].
  ///
  /// Unknown tags push a `null` marker so parser state remains balanced.
  void _handleOpen(Match match, List<TextStyle?> stack) {
    final tagName = _tagName(match);
    final inlineValue = _inlineValue(match);
    final rule = rules[tagName];

    if (rule == null) {
      stack.add(null);
      return;
    }

    final ownStyle = rule.resolve(inlineValue);
    final parentStyle = _currentStyle(stack);

    final mergedStyle = parentStyle != null
        ? parentStyle.merge(ownStyle)
        : ownStyle;

    stack.add(mergedStyle);
  }

  /// Handles a closing tag by unwinding one style level when possible.
  ///
  /// Unknown closing tags are emitted as plain text.
  void _handleClose(Match match, List<TextToken> tokens, List<TextStyle?> stack) {
    final tagName = _tagName(match);
    final rule = rules[tagName];

    if (rule == null) {
      _flush(tokens, match.group(0)!, stack);
      return;
    }

    if (stack.length > 1) {
      stack.removeLast();
    }
  }

  /// Emits a [PlainToken] or [StyledToken] depending on the current stack.
  void _flush(List<TextToken> tokens, String text, List<TextStyle?> stack) {
    if (text.isEmpty) return;
    final style = _currentStyle(stack);
    if (style == null) {
      tokens.add(PlainToken(text));
    } else {
      tokens.add(StyledToken(text, style));
    }
  }

  /// Returns the effective merged style at the top of the stack, or null
  /// when the stack is at the base level with no explicit style.
  TextStyle? _currentStyle(List<TextStyle?> stack) => stack.last;

  /// Returns the earlier of two matches (by start position), or the non-null one.
  Match? _earliest(Match? a, Match? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.start <= b.start ? a : b;
  }

  /// Extracts the tag name from an open or close match (group 1).
  String _tagName(Match match) =>
      match.groupCount >= 1 ? (match.group(1) ?? '') : '';

  /// Extracts the inline value from an open match (group 2, strips leading `=`).
  String? _inlineValue(Match match) {
    if (match.groupCount < 2) return null;
    final raw = match.group(2);
    if (raw == null || raw.isEmpty) return null;
    return raw.startsWith('=') ? raw.substring(1) : raw;
  }
}
