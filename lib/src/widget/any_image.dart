import 'package:flutter/widgets.dart';

import '../model/resolved_source.dart';
import '../model/source_type.dart';
import '../renderer/asset_raster_renderer.dart';
import '../renderer/asset_svg_renderer.dart';
import '../renderer/image_renderer.dart';
import '../renderer/network_raster_renderer.dart';
import '../renderer/network_svg_renderer.dart';
import '../resolver/extension_resolver.dart';
import '../resolver/mime_resolver.dart';
import '../resolver/prefix_resolver.dart';
import '../resolver/resolver_pipeline.dart';

/// A universal image widget that renders any image source.
///
/// Accepts an opaque [source] string and automatically resolves
/// the correct renderer based on location and format signals.
///
/// Supports network URLs, asset paths, and SVG images without
/// requiring the caller to know the image type in advance.
///
/// By default uses sync resolution only. Pass [asyncResolvers]
/// such as [MimeResolver] to enable async resolution for
/// extension-less URLs.
///
/// ```dart
/// AnyImage(source: 'https://example.com/image.png')
/// AnyImage(source: 'assets/icons/logo.svg')
/// ```
class AnyImage extends StatefulWidget {
  /// The image source — a URL or asset path.
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

  /// The resolver pipeline used to classify the source.
  ///
  /// Defaults to [PrefixResolver] and [ExtensionResolver].
  /// Override to add [MimeResolver] or custom resolvers.
  final ResolverPipeline pipeline;

  static const _defaultPipeline = ResolverPipeline(
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
    this.pipeline = _defaultPipeline,
  });

  /// Creates an [AnyImage] with MIME sniffing enabled.
  ///
  /// Use this when the source URL does not contain a file
  /// extension or other format signals. Makes an HTTP HEAD
  /// request to determine the image format from the
  /// Content-Type header.
  ///
  /// Has no effect on asset sources — MIME sniffing only
  /// applies to network URLs.
  ///
  /// ```dart
  /// AnyImage.withMimeSniffing(
  ///   source: 'https://cdn.example.com/a8f3k',
  /// )
  /// ```
  const AnyImage.withMimeSniffing({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.format,
  }) : pipeline = const ResolverPipeline(
          resolvers: [PrefixResolver(), ExtensionResolver()],
          asyncResolvers: [MimeResolver()],
        );

  @override
  State<AnyImage> createState() => _AnyImageState();
}

class _AnyImageState extends State<AnyImage> {
  late Future<ResolvedSource> _resolved;

  @override
  void initState() {
    super.initState();
    _resolved = _resolve();
  }

  @override
  void didUpdateWidget(AnyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _resolved = _resolve();
    }
  }

  Future<ResolvedSource> _resolve() async {
    var resolved = await widget.pipeline.resolve(widget.source);

    if (widget.format != null) {
      resolved = ResolvedSource(
        raw: resolved.raw,
        location: resolved.location,
        format: widget.format,
      );
    }

    return resolved;
  }

  Widget _render(ResolvedSource resolved) {
    final renderer = AnyImage._renderers.cast<ImageRenderer?>().firstWhere(
          (r) => r!.canRender(resolved),
          orElse: () => null,
        );

    if (renderer == null) {
      return widget.errorWidget ?? const SizedBox.shrink();
    }

    return renderer.render(
      resolved,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResolvedSource>(
      future: _resolved,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorWidget ?? const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return widget.placeholder ?? const SizedBox.shrink();
        }

        return _render(snapshot.data!);
      },
    );
  }
}
