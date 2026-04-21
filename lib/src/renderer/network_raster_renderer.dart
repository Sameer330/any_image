import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'image_renderer.dart';

/// Renders a raster image loaded from a network URL
///
/// Delegates to [CachedNetworkImage] for loading and caching
class NetworkRasterRenderer implements ImageRenderer {
  const NetworkRasterRenderer();

  @override
  bool canRender(ResolvedSource source) {
    return source.location == ImageLocation.network &&
        source.format == ImageFormat.raster;
  }

  @override
  Widget render(
    ResolvedSource source, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: source.raw,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder != null ? (context, url) => placeholder : null,
      errorWidget:
          errorWidget != null ? (context, url, error) => errorWidget : null,
    );
  }
}
