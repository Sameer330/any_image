import 'source_type.dart';

/// Represents an image source after it has been resolved
/// to a specific type.
class ResolvedSource {
  /// The original string as passed by developer
  final String raw;

  /// The resolved type of the raw source
  final SourceType type;

  const ResolvedSource({
    required this.raw,
    required this.type,
  });
}
