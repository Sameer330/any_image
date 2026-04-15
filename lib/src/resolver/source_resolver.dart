import '../model/resolved_source.dart';

/// A contract for all source resolver in pipeline
///
/// Implement this interface to add custom resolution logic
abstract interface class SourceResolver {
  /// Tries to resolves source into a [ResolvedSource]
  ResolvedSource? resolve(String source);
}
