import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'source_resolver.dart';

/// Runs all resolvers and merges location and format
/// from the best available meta data
///
/// Does not stop at the first non-null result
/// Collects location and format from resolvers independently, then
/// combines them
class ResolverPipeline {
  final List<SourceResolver> resolvers;

  const ResolverPipeline({required this.resolvers});

  /// Resolves [source] by merging results from all resolvers
  ResolvedSource resolve(String source) {
    ImageLocation? location;
    ImageFormat? format;

    for (final resolver in resolvers) {
      final result = resolver.resolve(source);
      if (result == null) continue;
      location ??= result.location;
      format ??= result.format;
    }

    return ResolvedSource(
      raw: source,
      location: location ?? ImageLocation.network,
      format: format ?? ImageFormat.raster,
    );
  }
}
