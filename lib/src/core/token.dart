import 'package:flutter/painting.dart';

/// A node in the flat list produced by [TextMarkParser].
///
/// The parser outputs a **flat** list — nesting is resolved during parsing
/// and each [StyledToken] already carries the fully merged style (all ancestor
/// styles merged top-down, child wins on conflict).
sealed class TextToken {
  const TextToken();
}

/// A plain text segment with no additional styling.
final class PlainToken extends TextToken {
  const PlainToken(this.text);
  final String text;

  @override
  String toString() => 'PlainToken("$text")';
}

/// A text segment with a fully resolved [TextStyle].
///
/// The style already includes all ancestor contributions — the renderer
/// simply applies it without any further merging.
final class StyledToken extends TextToken {

  const StyledToken(this.text, this.style);
  final String text;

  /// Fully merged style: base + all ancestor styles + this node's own style.
  final TextStyle style;

  @override
  String toString() => 'StyledToken("$text", $style)';
}
