import 'package:http/http.dart' as http;
import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'async_source_resolver.dart';

/// Resolves image format by making an HTTP HEAD request
/// and reading the Content-Type header
///
/// Use this resolver for network URLs that do not contain
/// a file extension or other format signals
///
/// This resolver only handles network sources. Non-network
/// sources are returned as null immediately without any
/// HTTP request
///
/// Register it via [ResolverPipeline] as an optional async
/// resolver:
///
/// ```dart
/// ResolverPipeline(
///   resolvers: [PrefixResolver(), ExtensionResolver()],
///   asyncResolvers: [MimeResolver()],
/// )
/// ```
class MimeResolver implements AsyncSourceResolver {
  const MimeResolver();

  static const _mimeToFormat = {
    'image/svg+xml': ImageFormat.svg,
    'image/png': ImageFormat.raster,
    'image/jpeg': ImageFormat.raster,
    'image/webp': ImageFormat.raster,
    'image/gif': ImageFormat.raster,
  };

  @override
  Future<ResolvedSource?> resolve(String source) async {
    // Only network sources can be resolved via MIME sniffing.
    // Asset, file, and other source types are not applicable.
    if (!source.startsWith('http://') && !source.startsWith('https://')) {
      return null;
    }

    try {
      final response = await http.head(Uri.parse(source));
      final contentType = response.headers['content-type'];

      if (contentType == null) return null;

      final mimeType = contentType.split(';').first.trim().toLowerCase();
      final format = _mimeToFormat[mimeType];

      if (format == null) return null;

      return ResolvedSource(
        raw: source,
        location: ImageLocation.network,
        format: format,
      );
    } catch (_) {
      return null;
    }
  }
}
