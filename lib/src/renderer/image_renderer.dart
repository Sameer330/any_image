import 'package:flutter/widgets.dart';

import '../model/resolved_source.dart';

/// Contract for all image renderers
///
/// Each renderer is responsible for a single combination
/// of [ImageLocation] and [ImageFormat]. The widget layer
/// selects the correct renderer based on the resolved source
///
/// Implement this interface to add custom rendering logic
abstract interface class ImageRenderer {
  /// Whether this renderer can handle [source]
  bool canRender(ResolvedSource source);

  /// Builds the image widget for [source]
  ///
  /// [width], [height], and [fit] control layout
  /// [placeholder] is shown during loading
  /// [errorWidget] is shown if rendering fails
  Widget render(
    ResolvedSource source, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  });
}
