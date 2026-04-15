/// Represents the location of an image source
enum ImageLocation {
  /// An image accessible via HTTP or HTTPS
  network,

  /// A Flutter asset declared in pubspec.yaml
  asset,
}

/// Represents the format of an image source
enum ImageFormat {
  /// A raster image such as PNG, JPEG, WebP, or GIF
  raster,

  /// A vector SVG image
  svg,
}
