import 'package:flutter/widgets.dart';
import 'package:text_mark/src/core/core.dart';

import 'package:text_mark/src/tokens/text_mark.dart';

/// Adds `.textmark()` directly to [String].
///
/// Requires a [TextMarkTheme] ancestor for tag format and default styles.
///
/// ```dart
/// "[bold]Hello[/bold] [red]world[/red]!".textmark()
///
/// "[vip]Gold member[/vip]".textmark(
///   styles: {'vip': TextStyle(color: Color(0xFFFFB300))},
/// )
/// ```
extension TextMarkStringExtension on String {
  Widget textMark({
    TagFormat? tagFormat,
    Map<String, TextStyle> styles = const {},
    Map<String, TextStyle Function(String? value)> dynamicStyles = const {},
    TextStyle? baseStyle,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextOverflow overflow = TextOverflow.clip,
    bool softWrap = true,
  }) {
    return TextMark(
      text: this,
      tagFormat: tagFormat,
      styles: styles,
      dynamicStyles: dynamicStyles,
      baseStyle: baseStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Adds `.textmark()` directly to Flutter's [Text] widget.
///
/// Preserves the original widget's [Text.style], [Text.textAlign],
/// [Text.maxLines], and [Text.overflow] automatically.
///
/// ```dart
/// const Text(
///   "[warn]Warning:[/warn] please [italic]read carefully[/italic].",
///   style: TextStyle(fontSize: 16),
///   textAlign: TextAlign.center,
/// ).textmark()
/// ```
extension TextMarkTextExtension on Text {
  Widget textMark({
    TagFormat? tagFormat,
  }) {
    return TextMark(
      text: data ?? '',
      tagFormat: tagFormat,
      baseStyle: style,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      softWrap: softWrap ?? true,
    );
  }
}
