import 'package:any_image/any_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'any_image example', home: ExampleScreen());
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('any_image example')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('Network raster'),
            AnyImage(
              source: 'https://picsum.photos/400/200',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: Center(child: CircularProgressIndicator()),
              errorWidget: Center(child: Icon(Icons.broken_image)),
            ),
            _SectionLabel('Network SVG'),
            AnyImage(
              source:
                  'https://upload.wikimedia.org/wikipedia/commons/4/4f/SVG_Logo.svg',
              width: double.infinity,
              height: 200,
              placeholder: Center(child: CircularProgressIndicator()),
              errorWidget: Center(child: Icon(Icons.broken_image)),
            ),
            _SectionLabel('Asset raster'),
            AnyImage(
              source: 'assets/images/placeholder.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorWidget: Center(child: Icon(Icons.broken_image)),
            ),
            _SectionLabel('Network — no extension (MIME sniffing)'),
            AnyImage.withMimeSniffing(
              source: 'https://avatars.githubusercontent.com/u/33640448?v=4',
              width: double.infinity,
              height: 200,
              placeholder: Center(child: CircularProgressIndicator()),
              errorWidget: Center(child: Icon(Icons.broken_image)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
