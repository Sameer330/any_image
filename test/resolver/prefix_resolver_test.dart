import 'package:any_image/src/model/source_type.dart';
import 'package:any_image/src/resolver/prefix_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = PrefixResolver();

  group('PrefixResolver', () {
    group('asset prefix', () {
      const source = 'assets/images/logo.png';

      test('resolved assets/ prefix to asset location', () {
        final result = resolver.resolve(source);
        expect(result?.location, ImageLocation.asset);
      });

      test('defaults format to raster for asset prefix', () {
        final result = resolver.resolve(source);
        expect(result?.format, ImageFormat.raster);
      });

      test('preserve raw source string', () {
        final result = resolver.resolve(source);
        expect(result?.raw, source);
      });
    });

    group('network prefix', () {
      test('resolved https:// prefix to network location', () {
        final result = resolver.resolve('https://example.com/image.png');
        expect(result?.location, ImageLocation.network);
      });

      test('resolved http:// prefix to network location', () {
        final result = resolver.resolve('http://example.com/image.png');
        expect(result?.location, ImageLocation.network);
      });

      test('defaults format to raster for network prefix', () {
        final result = resolver.resolve('https://example.com/image.png');
        expect(result?.format, ImageFormat.raster);
      });
    });

    group('unrecognised prefix', () {
      test('returns null for unknown prefix', () {
        final result = resolver.resolve('ftp://example.com/image.png');
        expect(result, isNull);
      });

      test('returns null for plain filename', () {
        final result = resolver.resolve('logo.png');
        expect(result, isNull);
      });
    });
  });
}
