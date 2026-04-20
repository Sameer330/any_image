import 'source_type.dart';

/// Represents an image source after it has been resolved
/// to a specific type.
/// 
/// This is the handoff object between the resolver layer
/// and the renderer layer
class ResolvedSource {
  /// The original string as passed by developer
  final String raw;

  /// Where the image is loaded from.
  final ImageLocation? location;

  /// How the image should be rendered.
  final ImageFormat? format;

  const ResolvedSource({
    required this.raw,
    this.location,
    this.format,
  });
}
