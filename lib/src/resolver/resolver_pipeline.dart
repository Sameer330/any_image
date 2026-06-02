import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'async_source_resolver.dart';
import 'source_resolver.dart';

/// Runs all resolvers and merges location and format
/// from the best available meta data
///
/// Does not stop at the first non-null result
/// Collects location and format from resolvers independently, then
/// combines them
class ResolverPipeline {
  final List<SourceResolver> resolvers;
  final List<AsyncSourceResolver> asyncResolvers;

  const ResolverPipeline({
    required this.resolvers,
    this.asyncResolvers = const [],
  });

  /// Resolves [source] synchronously using registered [resolvers]
  ///
  /// Applies defaults for any unresolved fields.
  /// Prefer [resolveAsync] when async resolvers are registered.
  ResolvedSource resolve(String source) {
    final (location, format) = _runSyncPass(source);

    return ResolvedSource(
      raw: source,
      location: location ?? ImageLocation.network,
      format: format ?? ImageFormat.raster,
    );
  }

  /// Resolves [source] using sync resolvers first, then async resolvers
  /// if format remains unresolved
  ///
  /// Falls back to defaults if no resolver can determine a field.
  Future<ResolvedSource> resolveAsync(String source) async {
    var (location, format) = _runSyncPass(source);

    if (format == null) {
      for (final asyncResolver in asyncResolvers) {
        final result = await asyncResolver.resolve(source);
        if (result == null) continue;
        location ??= result.location;
        format ??= result.format;
        if (location != null && format != null) break;
      }
    }

    return ResolvedSource(
      raw: source,
      location: location ?? ImageLocation.network,
      format: format ?? ImageFormat.raster,
    );
  }

  (ImageLocation?, ImageFormat?) _runSyncPass(String source) {
    ImageLocation? location;
    ImageFormat? format;

    for (final resolver in resolvers) {
      final result = resolver.resolve(source);
      if (result == null) continue;
      location ??= result.location;
      format ??= result.format;
    }

    return (location, format);
  }
}
