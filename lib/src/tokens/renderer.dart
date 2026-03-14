import 'package:flutter/cupertino.dart';
import 'package:text_mark/src/core/core.dart';

/// Converts a flat list of [TextToken]s into a list of [InlineSpan]s
/// ready to be passed to [RichText] or [TextSpan.children].
///
/// The renderer is intentionally thin — all style merging has already been
/// done by [TextMarkParser]. Each token maps 1-to-1 to a [TextSpan].
class TextMarkRenderer {
  const TextMarkRenderer();

  /// Renders [tokens] into [InlineSpan]s.
  ///
  /// [ambientStyle] is the [DefaultTextStyle] captured by the widget. It is
  /// applied to [PlainToken]s so they inherit the surrounding text appearance.
  /// [StyledToken]s carry a pre-merged style that already incorporates the
  /// ambient style when it was provided to the parser.
  List<InlineSpan> render(
    List<TextToken> tokens, {
    TextStyle? ambientStyle,
  }) {
    if (tokens.isEmpty) return const [];

    return tokens.map((t) => _toSpan(t, ambientStyle)).toList(growable: false);
  }

  InlineSpan _toSpan(TextToken token, TextStyle? ambient) {
    return switch (token) {
      final PlainToken t => TextSpan(text: t.text, style: ambient),
      final StyledToken t => TextSpan(text: t.text, style: t.style),
    };
  }
}
