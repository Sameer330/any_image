import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../model/resolved_source.dart';
import '../model/source_type.dart';
import '../renderer/asset_raster_renderer.dart';
import '../renderer/asset_svg_renderer.dart';
import '../renderer/image_renderer.dart';
import '../renderer/network_raster_renderer.dart';
import '../renderer/network_svg_renderer.dart';
import '../resolver/extension_resolver.dart';
import '../resolver/magic_bytes_resolver.dart';
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
/// Magic bytes resolution is used for extension-less URLs and can be
/// disabled via [allowNetwork].
///
/// ```dart
/// AnyImage(source: 'https://example.com/image.png')
/// AnyImage(source: 'assets/icons/logo.svg')
/// ```
class AnyImage extends StatefulWidget {
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

  /// Allows developer to control network usage to render images
  ///
  /// Network[http] access is enabled by default
  final bool allowNetwork;

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
    this.allowNetwork = true,
  });

  @override
  State<AnyImage> createState() => _AnyImageState();
}

class _AnyImageState extends State<AnyImage> {
  late Future<ResolvedSource> _resolved;
  late ResolverPipeline _pipeline;
  late http.Client _client;

  @override
  void initState() {
    super.initState();

    _client = http.Client();
    _pipeline = _buildPipeline();
    _resolved = _resolve();
  }

  @override
  void didUpdateWidget(AnyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allowNetwork != widget.allowNetwork) {
      _client.close();
      _client = http.Client();
      _pipeline = _buildPipeline();
    }
    if (oldWidget.source != widget.source ||
        oldWidget.allowNetwork != widget.allowNetwork) {
      _resolved = _resolve();
    }
  }

  ResolverPipeline _buildPipeline() {
    return ResolverPipeline(
      resolvers: const [PrefixResolver(), ExtensionResolver()],
      asyncResolvers: widget.allowNetwork
          ? [MagicBytesResolver(client: _client)]
          : const [],
    );
  }

  Future<ResolvedSource> _resolve() async {
    if (widget.format != null) {
      // sync resolve is sufficient — format is known
      final resolved = _pipeline.resolve(widget.source);
      return ResolvedSource(
        raw: resolved.raw,
        location: resolved.location,
        format: widget.format,
      );
    }
    return await _pipeline.resolveAsync(widget.source);
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

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
