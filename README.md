# Text Mark

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

---

Rich inline text styling for Flutter — your tags, your syntax, zero friction.

Define `[tags]` once, nest them freely, and render styled text natively via
Flutter's `RichText` / `TextSpan`. No Markdown lock-in, no fixed syntax.


## Installation

**❗ In order to start using Text Mark you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Install via `flutter pub add`:

```sh
dart pub add text_mark
```

---

## Features

- **Your syntax** — `[tag]` by default, or any custom format via `TagFormat`
- **Nesting** — `[bold][red]...[/red][/bold]` just works; child styles win on conflict
- **Dynamic values** — `[c=FF5733]`, `[size=24]` — value embedded in the tag
- **Three API levels** — local styles / dynamic tags / global `TextMarkTheme`
- **LRU cache** — parse results cached by (text + rules fingerprint), 200 entries default
- **Extensions** — `.textmark()` on `String` and `Text`
- **Zero dependencies** — pure Flutter

---

## Quick start

### Standalone (no theme)

```dart
TextMark(
  text: "[bold]Hello[/bold] [red]world[/red]!",
  tagFormat: TagFormat.bracket,
  styles: {
    'bold': TextStyle(fontWeight: FontWeight.bold),
    'red':  TextStyle(color: Color(0xFFE53935)),
  },
)
```

### With a global theme (recommended)

Define your styles once in a dedicated file:

```dart
// app_text_styles.dart
class AppTextStyles {
  static const styles = <String, TextStyle>{
    'red':  TextStyle(color: Color(0xFFE53935)),
    'bold': TextStyle(fontWeight: FontWeight.bold),
    'h1':   TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
    'warn': TextStyle(color: Color(0xFFF57F17), backgroundColor: Color(0xFFFFF9C4)),
  };
 
  static final dynamicStyles = <String, TextStyle Function(String?)>{
    'c':    (v) => TextStyle(color: _hexColor(v ?? 'FF0000')),
    'size': (v) => TextStyle(fontSize: double.tryParse(v ?? '16') ?? 16),
  };
}
```

Place the theme inside `MaterialApp.builder`:

```dart
MaterialApp(
  builder: (context, child) => TextMarkTheme(
    tagFormat: TagFormat.bracket,
    styles: AppTextStyles.styles,
    dynamicStyles: AppTextStyles.dynamicStyles,
    child: child!,
  ),
)
```

Then anywhere in the tree — no repeated config:

```dart
// Widget
TextMark(text: "[h1]Title[/h1] with [red]alert[/red]")
 
// String extension
"[bold]Easy[/bold] as [red]that[/red].".textmark()
 
// Text extension — preserves style, textAlign, maxLines…
Text("[warn]Warning:[/warn] read carefully.", style: TextStyle(fontSize: 16))
  .textmark()
```
 
---

## Nesting

```dart
TextMark(
  text: "[bold]This is bold and [red]this part is also red[/red], "
        "back to bold only[/bold], then plain.",
)
```

- Child styles win on conflict (e.g. a red child inside a blue parent → red)
- Parent styles propagate where the child is silent (e.g. bold parent + red child → bold + red)
- Misordered closing tags degrade gracefully — no crash

---

## Dynamic value tags

```dart
TextMark(
  text: "Price: [c=E53935]€49[/c]  Size: [size=24]big[/size]",
  dynamicStyles: {
    'c':    (v) => TextStyle(color: _hexColor(v ?? 'FF0000')),
    'size': (v) => TextStyle(fontSize: double.tryParse(v ?? '16') ?? 16),
    'bg':   (v) => TextStyle(backgroundColor: _hexColor(v ?? 'FFFF00')),
    'font': (v) => TextStyle(fontFamily: v),
  },
)
```
 
---

## Local overrides

Local styles are merged on top of the theme — local keys always win:

```dart
TextMark(
  text: "[bold]Global bold[/bold] and [vip]local only[/vip].",
  styles: {
    'vip': TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.w600),
  },
)
```
 
---

## Tag formats

```dart
TagFormat.bracket          // [tag]...[/tag]   ← default, recommended
TagFormat.doubleBrace      // {{tag}}...{{/tag}}
TagFormat.wrap('@', '::')  // @tag::...@/tag::
TagFormat.custom(          // fully custom RegExp
  open:  RegExp(r'<(\w+)>'),
  close: RegExp(r'</(\w+)>'),
)
```

`[tag]` is the recommended default — safe in JSON, YAML, and API payloads with no escaping required.
 
---

## Cache

The parse cache lives on `TextMarkTheme` and is shared across the entire subtree.
Cache size is configurable:

```dart
TextMarkTheme(cacheSize: 500, ...) // default: 200
```

The cache key is `hash(rawText) + hash(registeredTagNames)`.
Style value changes without tag name changes do NOT invalidate the cache —
style maps are expected to be constants.
 
---

## Roadmap

- [ ] `WidgetSpan` support — inline icons / custom widgets
- [ ] Parse result caching with style-value fingerprint
- [ ] Accessibility / semantics label support


[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
