import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/resolved_source.dart';
import '../model/source_type.dart';
import 'image_renderer.dart';

/// Renders an SVG image loaded from a network URL
///
/// Delegates to [SvgPicture.network] from flutter_svg
class NetworkSvgRenderer implements ImageRenderer {
  @override
  bool canRender(ResolvedSource source) {
    return source.location == ImageLocation.network &&
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
    return SvgPicture.network(
      source.raw,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      placeholderBuilder: placeholder != null ? (_) => placeholder : null,
    );
  }
}
