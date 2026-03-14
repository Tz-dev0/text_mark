import 'package:flutter/material.dart';
import 'package:text_mark/text_mark.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'text_mark example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      builder: (context, child) => TextMarkTheme(
        tagFormat: TagFormat.bracket,
        styles: const {
          'h1': TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          'bold': TextStyle(fontWeight: FontWeight.bold),
          'accent': TextStyle(color: Color(0xFF1A73E8)),
          'warn': TextStyle(color: Color(0xFFB00020)),
        },
        dynamicStyles: {
          'size': (value) =>
              TextStyle(fontSize: double.tryParse(value ?? '16') ?? 16),
          'c': (value) => TextStyle(color: _hexColor(value ?? '1A73E8')),
        },
        child: child!,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('text_mark - example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextMark(text: '[h1]Text Mark[/h1]'),
          SizedBox(height: 12),
          TextMark(
            text: 'Nesting: [bold]gras + [accent]accent[/accent][/bold] normal.',
          ),
          SizedBox(height: 12),
          TextMark(
            text: 'Dynamic: [c=E53935]rouge[/c], [size=22]grand texte[/size].',
          ),
          SizedBox(height: 12),
          TextMark(
            text:
                '[warn]Alerte:[/warn] les balises inconnues restent en texte brut: [foo]bar[/foo].',
          ),
        ],
      ),
    );
  }
}

Color _hexColor(String hex) {
  final normalized = hex.replaceAll('#', '').toUpperCase();
  final argb = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.parse(argb, radix: 16));
}
