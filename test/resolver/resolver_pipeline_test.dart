import 'package:any_image/src/model/source_type.dart';
import 'package:any_image/src/resolver/extension_resolver.dart';
import 'package:any_image/src/resolver/prefix_resolver.dart';
import 'package:any_image/src/resolver/resolver_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pipeline = ResolverPipeline(
    resolvers: [PrefixResolver(), ExtensionResolver()],
  );

  group('ResolverPipeline', () {
    group('network raster', () {
      test('resolves https png url correctly', () {
        final result = pipeline.resolveSync('https://example.com/image.png');
        expect(result.location, ImageLocation.network);
        expect(result.format, ImageFormat.raster);
      });

      test('resolves https url with no extension to network raster', () {
        final result = pipeline.resolveSync('https://example.com/image');
        expect(result.location, ImageLocation.network);
        expect(result.format, ImageFormat.raster);
      });
    });

    group('network svg', () {
      test('resolves https svg url correctly', () {
        final result = pipeline.resolveSync('https://example.com/logo.svg');
        expect(result.location, ImageLocation.network);
        expect(result.format, ImageFormat.svg);
      });

      test('resolves https svg url with query params correctly', () {
        final result =
            pipeline.resolveSync('https://example.com/logo.svg?v=123');
        expect(result.location, ImageLocation.network);
        expect(result.format, ImageFormat.svg);
      });
    });

    group('asset raster', () {
      test('resolves asset png correctly', () {
        final result = pipeline.resolveSync('assets/images/logo.png');
        expect(result.location, ImageLocation.asset);
        expect(result.format, ImageFormat.raster);
      });
    });

    group('asset svg', () {
      test('resolves asset svg correctly', () {
        final result = pipeline.resolveSync('assets/icons/logo.svg');
        expect(result.location, ImageLocation.asset);
        expect(result.format, ImageFormat.svg);
      });
    });

    group('fallback', () {
      test('falls back to network raster for unrecognised source', () {
        final result = pipeline.resolveSync('some-random-string');
        expect(result.location, ImageLocation.network);
        expect(result.format, ImageFormat.raster);
      });
    });
  });
}
