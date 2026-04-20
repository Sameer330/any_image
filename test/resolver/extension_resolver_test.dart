import 'package:any_image/src/model/source_type.dart';
import 'package:any_image/src/resolver/extension_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = ExtensionResolver();

  group('ExtensionResolver', () {
    group('svg extension', () {
      const source = 'https://example.com/logo.svg';

      test('resolved .svg extension to svg format', () {
        final result = resolver.resolve(source);
        expect(result?.format, ImageFormat.svg);
      });

      test('defaults location to network for svg', () {
        final result = resolver.resolve(source);
        expect(result?.location, ImageLocation.network);
      });

      test('preserves raw source string', () {
        final result = resolver.resolve(source);
        expect(result?.raw, source);
      });
    });

    group('raster extension', () {
      test('resolves .png to raster format', () {
        final result = resolver.resolve('https://example.com/image.png');
        expect(result?.format, ImageFormat.raster);
      });

      test('resolved .jpg to raster format', () {
        final result = resolver.resolve('https://example.com/image.jpg');
        expect(result?.format, ImageFormat.raster);
      });

      test('resolves .jpeg to raster format', () {
        final result = resolver.resolve('https://example.com/image.jpeg');
        expect(result?.format, ImageFormat.raster);
      });

      test('resolves .webp to raster format', () {
        final result = resolver.resolve('https://example.com/image.webp');
        expect(result?.format, ImageFormat.raster);
      });

      test('resolves .gif to raster format', () {
        final result = resolver.resolve('https://example.com/image.gif');
        expect(result?.format, ImageFormat.raster);
      });
    });

    group('query parameters', () {
      test('resolved .svg with query params correctly', () {
        final result = resolver.resolve('https://example.com/logo.svg?v=123');
        expect(result?.format, ImageFormat.svg);
      });

      test('resolves .png with query params correctly', () {
        final result =
            resolver.resolve('https://example.com/image.png?token=abc');
        expect(result?.format, ImageFormat.raster);
      });
    });

    group('unrecognised extension', () {
      test('returns null for unknown extension', () {
        final result = resolver.resolve('https://example.com/file.pdf');
        expect(result, isNull);
      });

      test('returns null for no extension', () {
        final result = resolver.resolve('https://example.com/image');
        expect(result, isNull);
      });
    });
  });
}
