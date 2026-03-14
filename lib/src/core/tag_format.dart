/// Defines the open/close tag syntax used to delimit styled regions.
///
/// Text Mark ships with [TagFormat.bracket] as the recommended default.
/// All other formats are available via factory constructors.
///
/// ```dart
/// TagFormat.bracket
/// TagFormat.doubleBrace
/// TagFormat.wrap('@', '::')
/// TagFormat.custom(...)
/// ```
class TagFormat {
  /// RegExp matching an opening tag.
  ///
  /// Must capture:
  /// - Group 1 : the tag name  (e.g. `red`, `bold`)
  /// - Group 2 : the inline value after `=`, including the `=`  (optional,
  ///   e.g. `=FF5733` from `[c=FF5733]`). Null when no value is present.
  final RegExp openPattern;

  /// RegExp matching a closing tag.
  ///
  /// Must capture the tag name in group 1 so the parser can match it
  /// against the opening tag on the stack.
  final RegExp closePattern;

  const TagFormat._({
    required this.openPattern,
    required this.closePattern,
  });

  /// Pre-built formats.

  /// `[tag]...[/tag]`  —  the recommended default.
  ///
  /// Safe in JSON, YAML, Dart strings, and API payloads.
  /// No conflict with Flutter's widget XML or HTML content.
  static final TagFormat bracket = TagFormat._(
    openPattern: RegExp(r'\[(\w[\w-]*)(=[^\]]+)?\]'),
    closePattern: RegExp(r'\[/(\w[\w-]*)\]'),
  );

  /// `{{tag}}...{{/tag}}`
  static final TagFormat doubleBrace = TagFormat._(
    openPattern: RegExp(r'\{\{(\w[\w-]*)\}\}'),
    closePattern: RegExp(r'\{\{/(\w[\w-]*)\}\}'),
  );

  /// Factory constructors.

  /// Wraps tags with [prefix] before the tag name and [suffix] after the name.
  /// The closing tag uses `[prefix]/tagName[suffix]`.
  ///
  /// Example: `TagFormat.wrap('@', '::')` matches `@red::...@/red::`.
  factory TagFormat.wrap(String prefix, String suffix) {
    final p = RegExp.escape(prefix);
    final s = RegExp.escape(suffix);
    return TagFormat._(
      openPattern: RegExp('$p(\\w[\\w-]*)(=[^$s]+)?$s'),
      closePattern: RegExp('${p}/(\\w[\\w-]*)$s'),
    );
  }

  /// Fully custom format. Each pattern must capture the tag name in group 1.
  /// Group 2 of [open] may optionally capture an inline value (with `=`).
  factory TagFormat.custom({
    required RegExp open,
    required RegExp close,
  }) {
    return TagFormat._(openPattern: open, closePattern: close);
  }
}
