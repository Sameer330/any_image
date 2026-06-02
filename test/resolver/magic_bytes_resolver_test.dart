import 'package:any_image/src/model/source_type.dart';
import 'package:any_image/src/resolver/magic_bytes_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  MagicBytesResolver resolverWith(List<int> bytes, {int statusCode = 206}) {
    final client = MockClient((_) async {
      return http.Response.bytes(bytes, statusCode);
    });
    return MagicBytesResolver(client: client);
  }

  late MagicBytesResolver resolver;

  setUp(() {
    resolver = MagicBytesResolver(client: http.Client());
  });

  group('MagicBytesResolver', () {
    group('non-HTTP sources', () {
      test('returns null for asset path', () async {
        final resolver = resolverWith([]);
        expect(await resolver.resolve('assets/image.png'), isNull);
      });

      test('returns null for empty string', () async {
        final resolver = resolverWith([]);
        expect(await resolver.resolve(''), isNull);
      });
    });

    group('format detection', () {
      test('detects PNG', () async {
        final result = await resolverWith(
          [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
        ).resolve('https://example.com/image');
        expect(result?.format, ImageFormat.raster);
      });

      test('detects JPEG', () async {
        final result = await resolverWith(
          [0xFF, 0xD8, 0xFF, 0xE0],
        ).resolve('https://example.com/image');
        expect(result?.format, ImageFormat.raster);
      });

      test('detects WebP', () async {
        final result = await resolverWith([
          0x52,
          0x49,
          0x46,
          0x46,
          0x00,
          0x00,
          0x00,
          0x00,
          0x57,
          0x45,
          0x42,
          0x50,
        ]).resolve('https://example.com/image');
        expect(result?.format, ImageFormat.raster);
      });

      test('detects GIF', () async {
        final result = await resolverWith(
          [0x47, 0x49, 0x46, 0x38, 0x39, 0x61],
        ).resolve('https://example.com/image');
        expect(result?.format, ImageFormat.raster);
      });

      test('detects SVG starting with <svg', () async {
        final result = await resolverWith(
          '<svg xmlns="http://www.w3.org/2000/svg"'.codeUnits,
        ).resolve('https://example.com/image');
        expect(result?.format, ImageFormat.svg);
      });
    });

    group('location', () {
      test('does not set location — pipeline is responsible', () async {
        final result = await resolverWith(
          [0xFF, 0xD8, 0xFF, 0xE0],
        ).resolve('https://example.com/image');
        expect(result?.location, isNull);
      });
    });

    group('preserves raw source', () {
      test('raw matches original source string', () async {
        const source = 'https://example.com/image';
        final result = await resolverWith(
          [0xFF, 0xD8, 0xFF, 0xE0],
        ).resolve(source);
        expect(result?.raw, source);
      });
    });

    group('failure cases', () {
      test('returns null on 404', () async {
        expect(
          await resolverWith([], statusCode: 404)
              .resolve('https://example.com/image'),
          isNull,
        );
      });

      test('returns null on empty body', () async {
        expect(
          await resolverWith([]).resolve('https://example.com/image'),
          isNull,
        );
      });

      test('returns null for unrecognized bytes', () async {
        expect(
          await resolverWith([0x00, 0x01, 0x02, 0x03])
              .resolve('https://example.com/image'),
          isNull,
        );
      });

      test('returns null on network exception', () async {
        final client = MockClient((_) async => throw Exception('timeout'));
        final resolver = MagicBytesResolver(client: client);
        expect(await resolver.resolve('https://example.com/image'), isNull);
      });
    });

    group('MagicBytesResolver (real URLs)', () {
      testWidgets('httpbin SVG', (tester) async {
        final result = await resolver.resolve('https://httpbin.org/image/svg');
        printOnFailure(
            'resolved: location=${result?.location}, format=${result?.format}');
        expect(result?.format, ImageFormat.svg);
      });

      testWidgets('dicebear identicon', (tester) async {
        final result = await resolver
            .resolve('https://api.dicebear.com/7.x/identicon/svg');
        printOnFailure(
            'resolved: location=${result?.location}, format=${result?.format}');
        expect(result?.format, ImageFormat.svg);
      });

      testWidgets('dicebear bottts', (tester) async {
        final result =
            await resolver.resolve('https://api.dicebear.com/7.x/bottts/svg');
        printOnFailure(
            'resolved: location=${result?.location}, format=${result?.format}');
        expect(result?.format, ImageFormat.svg);
      });

      testWidgets('shields.io badge', (tester) async {
        final result = await resolver
            .resolve('https://img.shields.io/badge/status-active-green');
        printOnFailure(
            'resolved: location=${result?.location}, format=${result?.format}');
        expect(result?.format, ImageFormat.svg);
      });

      testWidgets('dummyimage raster', (tester) async {
        final result =
            await resolver.resolve('https://dummyimage.com/250/000/fff');
        printOnFailure(
            'resolved: location=${result?.location}, format=${result?.format}');
        expect(result?.format, ImageFormat.raster);
      });

      testWidgets('loading.io animation', (tester) async {
        final result =
            await resolver.resolve('https://loading.io/api/animation/preview');
        printOnFailure(
            'resolved: location=${result?.location}, format=${result?.format}');

        expect(result?.format, isNull);
        expect(result?.format, isNull);
      });
    });
  });
}
