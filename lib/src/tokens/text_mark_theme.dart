import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:text_mark/src/core/core.dart';
import 'package:text_mark/src/tokens/tokens.dart';

/// The resolved configuration available to all [TextMark] widgets in
/// the subtree.
class TextMarkConfig {
  const TextMarkConfig({
    required this.format,
    required this.rules,
    required this.cache,
  });

  final TagFormat format;

  /// All registered style rules, keyed by tag name.
  final Map<String, StyleRule> rules;

  /// Shared LRU parse cache — lives here so it survives widget rebuilds.
  final TextMarkCache cache;

  /// Looks up the nearest [TextMarkConfig] in the widget tree.
  static TextMarkConfig? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TextMarkInherited>()
        ?.config;
  }

  /// Returns a new config that merges [extraRules] on top of this one.
  /// Local rules (passed to a specific [TextMark]) win on conflict.
  TextMarkConfig mergeRules(Map<String, StyleRule> extraRules) {
    if (extraRules.isEmpty) return this;
    return TextMarkConfig(
      format: format,
      rules: {...rules, ...extraRules},
      cache: cache,
    );
  }
}

/// Provides a [TextMarkConfig] to the entire subtree.
///
/// ## Recommended placement
///
/// Place inside [MaterialApp.builder] to keep `main.dart` clean and let
/// [MaterialApp] resolve its own theme first:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => TextMarkTheme(
///     tagFormat: TagFormat.bracket,
///     styles: AppTextStyles.styles,
///     child: child!,
///   ),
/// )
/// ```
///
/// ## Recommended style organisation
///
/// Define styles in a dedicated file to avoid cluttering the widget tree:
///
/// ```dart
/// class AppTextStyles {
///   static const styles = {
///     'red':  TextStyle(color: Color(0xFFE53935)),
///     'bold': TextStyle(fontWeight: FontWeight.bold),
///     'h1':   TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
///   };
///   static final dynamicStyles = {
///     'c':    (v) => TextStyle(color: _hexColor(v ?? 'FF0000')),
///     'size': (v) => TextStyle(fontSize: double.tryParse(v ?? '16') ?? 16),
///   };
/// }
/// ```
class TextMarkTheme extends StatelessWidget {
  const TextMarkTheme({
    required this.child,
    super.key,
    this.tagFormat = const _DefaultFormat(),
    this.styles = const {},
    this.dynamicStyles = const {},
    this.cacheSize = 200,
  });

  /// Tag format for the entire subtree. Defaults to [TagFormat.bracket].
  final TagFormat tagFormat;

  /// Static styles: tag name → [TextStyle].
  final Map<String, TextStyle> styles;

  /// Dynamic styles: tag name → builder receiving the inline value string.
  ///
  /// The builder receives `null` when the tag has no inline value.
  final Map<String, TextStyle Function(String? value)> dynamicStyles;

  /// Maximum number of parse results to keep in memory.
  /// Defaults to 200. Tune downward on memory-constrained devices.
  final int cacheSize;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rules = _buildRules();
    final config = TextMarkConfig(
      format: tagFormat,
      rules: rules,
      cache: TextMarkCache(maxSize: cacheSize),
    );
    return _TextMarkInherited(config: config, child: child);
  }

  Map<String, StyleRule> _buildRules() {
    return {
      for (final e in styles.entries) e.key: StyleRule.fixed(e.key, e.value),
      for (final e in dynamicStyles.entries)
        e.key: StyleRule.dynamic_(e.key, e.value),
    };
  }
}

class _TextMarkInherited extends InheritedWidget {
  const _TextMarkInherited({required this.config, required super.child});
  final TextMarkConfig config;

  @override
  bool updateShouldNotify(_TextMarkInherited old) =>
      config.format != old.config.format ||
      config.rules != old.config.rules ||
      config.cacheSize != old.config.cacheSize;
}

/// Provides a const default bracket format for [TextMarkTheme].
///
/// [TagFormat.bracket] cannot be const because it contains [RegExp] instances.
class _DefaultFormat implements TagFormat {
  const _DefaultFormat();

  @override
  RegExp get openPattern => RegExp(r'\[(\w[\w-]*)(=[^\]]+)?\]');

  @override
  RegExp get closePattern => RegExp(r'\[/(\w[\w-]*)\]');
}

extension on TextMarkConfig {
  int get cacheSize => cache.maxSize;
}
