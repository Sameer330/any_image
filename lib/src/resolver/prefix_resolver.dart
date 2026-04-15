import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'source_resolver.dart';

/// Resolves image sources based on well-known string prefixes
///
/// Handles following cases
/// - `assets/` prefix -> [ImageLocation.asset]
/// - `http://` or `https://` prefix -> [ImageLocation.network]
///
/// Returns null for sources that do not match any known prefix
/// to allow pipeline to fall through to next resolver
class PrefixResolver implements SourceResolver {
  const PrefixResolver();

  @override
  ResolvedSource? resolve(String source) {
    if (source.startsWith('assets/')) {
      return ResolvedSource(
        raw: source,
        location: ImageLocation.asset,
        // Set default to raster, format will be resolved later in pipeline
        format: ImageFormat.raster,
      );
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return ResolvedSource(
        raw: source,
        location: ImageLocation.network,
        format: ImageFormat.raster,
      );
    }

    return null;
  }
}
