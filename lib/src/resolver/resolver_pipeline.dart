import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'async_source_resolver.dart';
import 'source_resolver.dart';

/// Runs all resolvers and merges location and format
/// from the best available signals.
///
/// Sync resolvers run first in priority order. Async resolvers
/// run only if location or format remain unresolved after the
/// sync pass. Falls back to [ImageLocation.network] and
/// [ImageFormat.raster] if no resolver produces a result.
class ResolverPipeline {
  /// Synchronous resolvers, run in priority order.
  final List<SourceResolver> resolvers;

  /// Async resolvers, run only when sync resolvers leave
  /// location or format unresolved.
  final List<AsyncSourceResolver> asyncResolvers;

  const ResolverPipeline({
    required this.resolvers,
    this.asyncResolvers = const [],
  });

  /// Resolves [source] using sync resolvers only.
  ///
  /// Use this when async resolution is not needed or not
  /// available, such as during widget build without a
  /// FutureBuilder.
  ResolvedSource resolveSync(String source) {
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

  /// Resolves [source] using sync resolvers first, then async
  /// resolvers if location or format remain unresolved.
  Future<ResolvedSource> resolve(String source) async {
    ImageLocation? location;
    ImageFormat? format;

    for (final resolver in resolvers) {
      final result = resolver.resolve(source);
      if (result == null) continue;
      location ??= result.location;
      format ??= result.format;
    }

    if (location == null || format == null) {
      for (final resolver in asyncResolvers) {
        final result = await resolver.resolve(source);
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
}
