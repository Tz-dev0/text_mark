import 'package:flutter/painting.dart';

/// Maps a tag name to a [TextStyle], either fixed or computed from an
/// inline value embedded in the tag (e.g. `[c=FF5733]`).
///
/// ```dart
/// StyleRule.fixed('bold', TextStyle(fontWeight: FontWeight.bold))
///
/// StyleRule.dynamic_('c', (v) => TextStyle(color: _hexColor(v ?? 'FF0000')))
/// ```

class StyleRule {
  final String tag;
  final TextStyle Function(String? value) _builder;

  /// Internal constructor used by [fixed] and [dynamic_].
  StyleRule._(this.tag, this._builder);

  /// Creates a rule that always resolves to the same [TextStyle].
  factory StyleRule.fixed(String tag, TextStyle style) {
    return StyleRule._(tag, (_) => style);
  }

  /// Creates a rule whose style is computed from an optional inline value.
  factory StyleRule.dynamic_(
    String tag,
    TextStyle Function(String? value) builder,
  ) {
    return StyleRule._(tag, builder);
  }

  /// Resolves the final [TextStyle] for the provided inline [value].
  TextStyle resolve(String? value) => _builder(value);
}