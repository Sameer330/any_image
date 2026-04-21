import 'package:flutter/widgets.dart';

import '../model/resolved_source.dart';
import '../model/source_type.dart';
import '../renderer/asset_raster_renderer.dart';
import '../renderer/asset_svg_renderer.dart';
import '../renderer/image_renderer.dart';
import '../renderer/network_raster_renderer.dart';
import '../renderer/network_svg_renderer.dart';
import '../resolver/extension_resolver.dart';
import '../resolver/prefix_resolver.dart';
import '../resolver/resolver_pipeline.dart';

/// A universal image widget that renders any image source
///
/// Accepts an opaque [source] string and automatically resolves
/// the correct renderer based on location and format signals
///
/// Supports network URLs, asset paths, and SVG images without
/// requiring the caller to know the image type in advance
///
/// ```dart
/// AnyImage(source: 'https://example.com/image.png')
/// AnyImage(source: 'assets/icons/logo.svg')
/// ```
class AnyImage extends StatelessWidget {
  /// The image source — a URL, asset path, or file path.
  final String source;

  /// The width of the rendered image.
  final double? width;

  /// The height of the rendered image.
  final double? height;

  /// How the image should be inscribed into the available space.
  final BoxFit? fit;

  /// Widget shown while the image is loading.
  final Widget? placeholder;

  /// Widget shown if the image fails to load.
  final Widget? errorWidget;

  /// Overrides automatic source type resolution.
  ///
  /// Use this when the source string does not contain enough
  /// signals for the resolver to determine the correct type.
  final ImageFormat? format;

  static const _pipeline = ResolverPipeline(
    resolvers: [PrefixResolver(), ExtensionResolver()],
  );

  static const _renderers = [
    NetworkRasterRenderer(),
    AssetRasterRenderer(),
    NetworkSvgRenderer(),
    AssetSvgRenderer(),
  ];

  const AnyImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.format,
  });

  @override
  Widget build(BuildContext context) {
    var resolved = _pipeline.resolve(source);

    if (format != null) {
      resolved = ResolvedSource(
        raw: resolved.raw,
        location: resolved.location,
        format: format,
      );
    }

    final renderer = _renderers.cast<ImageRenderer?>().firstWhere(
          (r) => r!.canRender(resolved),
          orElse: () => null,
        );

    if (renderer == null) {
      return errorWidget ?? const SizedBox.shrink();
    }

    return renderer.render(
      resolved,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
