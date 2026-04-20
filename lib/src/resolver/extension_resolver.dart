import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'source_resolver.dart';

/// Resolves image sources based on file extension
///
/// Handles the following cases:
/// - `.svg` extension -> [ImageFormat.svg]
/// - `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif` -> [ImageFormat.raster]
///
/// Note: This resolver only determines format, not location.
/// It should run after [PrefixResolver] in the pipeline so that
/// location is already established when possible
class ExtensionResolver implements SourceResolver {
  const ExtensionResolver();

  static const _svgExtension = '.svg';

  /// FYI - pixel based images
  /// Raster - commonly used in UI design domain
  static const _rasterExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.gif',
  };

  @override
  ResolvedSource? resolve(String source) {
    final path = _stripQuery(source);
    final ext = _extractExtension(path);

    if (ext == null) return null;

    if (ext == _svgExtension) {
      return ResolvedSource(raw: source, format: ImageFormat.svg);
    }

    if (_rasterExtensions.contains(ext)) {
      return ResolvedSource(raw: source, format: ImageFormat.raster);
    }

    return null;
  }

  String _stripQuery(String source) {
    final queryIndex = source.indexOf('?');
    return queryIndex != -1 ? source.substring(0, queryIndex) : source;
  }

  String? _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return null;
    return path.substring(dotIndex).toLowerCase();
  }
}
