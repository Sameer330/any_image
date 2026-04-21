import 'package:flutter/widgets.dart';

import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'image_renderer.dart';

/// Renders a raster image loaded from Flutter assets
///
/// Delegates to [Image.asset] from the Flutter framework
class AssetRasterRenderer implements ImageRenderer {
  @override
  bool canRender(ResolvedSource source) {
    return source.location == ImageLocation.asset &&
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
    return Image.asset(
      source.raw,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorWidget != null
          ? (context, error, stackTrace) => errorWidget
          : null,
    );
  }
}
