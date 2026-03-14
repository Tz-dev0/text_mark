/// Textmark — Rich inline text styling for Flutter.
///
/// Define your own [tags], nest them freely, use dynamic values,
/// and share styles globally via [TextMarkTheme].
///
/// Quick start:
/// ```dart
/// TextMark(
///   text: "[bold]Hello[/bold] [red]world[/red]!",
///   styles: {
///     'bold': TextStyle(fontWeight: FontWeight.bold),
///     'red':  TextStyle(color: Color(0xFFE53935)),
///   },
/// )
/// ```
library textmark;

export 'src/core/core.dart';
export 'src/tokens/tokens.dart';
