import 'package:flutter/widgets.dart';
import 'package:text_mark/src/core/core.dart';

import 'package:text_mark/src/tokens/renderer.dart';
import 'package:text_mark/src/tokens/text_mark_theme.dart';

/// Renders a string containing custom tags as richly styled inline text.
///
/// ## Usage — with a global [TextMarkTheme] (recommended)
///
/// ```dart
/// TextMarkTheme(
///   styles: AppTextStyles.styles,
///   dynamicStyles: AppTextStyles.dynamicStyles,
///   child: child!,
/// )
///
/// TextMark(text: "[bold]Hello[/bold] [red]world[/red]!")
/// ```
///
/// ## Usage — standalone, no theme
///
/// ```dart
/// TextMark(
///   text: "[bold]Hello[/bold] [red]world[/red]!",
///   tagFormat: TagFormat.bracket,
///   styles: {
///     'bold': TextStyle(fontWeight: FontWeight.bold),
///     'red':  TextStyle(color: Color(0xFFE53935)),
///   },
/// )
/// ```
///
/// ## Local overrides
///
/// Local [styles] and [dynamicStyles] are merged on top of the theme.
/// Local keys always win over the theme.
///
/// ## Nesting
///
/// Tags may be nested freely:
/// ```dart
/// "[bold][red]red and bold[/red] still bold[/bold]"
/// ```
/// Child styles win on conflict; parent styles propagate where the child
/// is silent.
///
/// ## Dynamic values
///
/// ```dart
/// TextMark(
///   text: "Color: [c=E53935]red[/c]  Size: [size=24]big[/size]",
///   dynamicStyles: {
///     'c':    (v) => TextStyle(color: _hexColor(v ?? 'FF0000')),
///     'size': (v) => TextStyle(fontSize: double.tryParse(v ?? '16') ?? 16),
///   },
/// )
/// ```
class TextMark extends StatelessWidget {
  /// The raw text string containing tag delimiters.
  final String text;

  /// Tag format override for this widget.
  /// Falls back to the [TextMarkTheme] format when null.
  final TagFormat? tagFormat;

  /// Static styles local to this widget.
  /// Merged on top of the theme — local keys win.
  final Map<String, TextStyle> styles;

  /// Dynamic styles local to this widget.
  /// Merged on top of the theme — local keys win.
  final Map<String, TextStyle Function(String? value)> dynamicStyles;

  /// Base text style applied to unstyled segments.
  /// Falls back to [DefaultTextStyle] when null.
  final TextStyle? baseStyle;

  /// Passed through to [RichText.textAlign].
  final TextAlign textAlign;

  /// Passed through to [RichText.maxLines].
  final int? maxLines;

  /// Passed through to [RichText.overflow].
  final TextOverflow overflow;

  /// Passed through to [RichText.softWrap].
  final bool softWrap;

  const TextMark({
    super.key,
    required this.text,
    this.tagFormat,
    this.styles = const {},
    this.dynamicStyles = const {},
    this.baseStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeConfig = TextMarkConfig.of(context);

    final resolvedFormat = tagFormat ?? themeConfig?.format;
    assert(
      resolvedFormat != null,
      'TextMark: no TagFormat found.\n'
      'Either set tagFormat directly on this widget, or wrap a parent with '
      'TextMarkTheme.',
    );

    final localRules = _buildLocalRules();
    final mergedConfig = themeConfig?.mergeRules(localRules);
    final rules = mergedConfig?.rules ?? localRules;
    final cache = mergedConfig?.cache;

    final ambient = DefaultTextStyle.of(context).style;
    final base = baseStyle != null ? ambient.merge(baseStyle) : ambient;

    final parser = TextMarkParser(
      format: resolvedFormat!,
      rules: rules,
      cache: cache,
    );
    final tokens = parser.parse(text, baseStyle: base);

    final spans = const TextMarkRenderer().render(tokens, ambientStyle: base);

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  Map<String, StyleRule> _buildLocalRules() {
    return {
      for (final e in styles.entries) e.key: StyleRule.fixed(e.key, e.value),
      for (final e in dynamicStyles.entries)
        e.key: StyleRule.dynamic_(e.key, e.value),
    };
  }
}
