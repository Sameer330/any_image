/// Represents a resolved type of an image source
enum SourceType {
  /// An image accessible by HTTP or HTTPS
  network,

  /// A project asset declared in pubspec.yaml
  asset,

  /// A vector SVG image. Location could be asset or network.
  svg,
}
