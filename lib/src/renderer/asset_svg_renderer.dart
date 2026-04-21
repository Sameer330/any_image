import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'image_renderer.dart';

/// Renders an SVG image loaded from Flutter assets
///
/// Delegates to [SvgPicture.asset] from flutter_svg
class AssetSvgRenderer implements ImageRenderer {
  const AssetSvgRenderer();

  @override
  bool canRender(ResolvedSource source) {
    return source.location == ImageLocation.asset &&
        source.format == ImageFormat.svg;
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
    return SvgPicture.asset(
      source.raw,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      placeholderBuilder: placeholder != null ? (_) => placeholder : null,
      errorBuilder: errorWidget != null ? (_, __, ___) => errorWidget : null,
    );
  }
}
