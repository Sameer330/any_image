import '../model/resolved_source.dart';

/// Contract for resolvers that require async operations
///
/// Use this interface when resolution cannot be determined
/// from the source string alone and requires an external
/// call such as an HTTP request.
///
/// Sync resolvers should implement [SourceResolver] instead
/// to avoid unnecessary async overhead in the pipeline
abstract interface class AsyncSourceResolver {
  /// Attempts to resolve [source] into a [ResolvedSource]
  ///
  /// Returns null if this resolver cannot classify the source,
  /// allowing the pipeline to fall through to the next resolver
  Future<ResolvedSource?> resolve(String source);
}
