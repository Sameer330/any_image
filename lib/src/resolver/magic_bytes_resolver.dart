import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:any_image/src/model/resolved_source.dart';

import '../../any_image.dart';
import 'async_source_resolver.dart';

/// Resolves image format by inspecting the first bytes of the response body
///
/// Used as an async fallback when [PrefixResolver] and [ExtensionResolver]
/// cannot determine format — typically for extension-less network URLs
///
/// Sends a range request (`bytes=0-63`) to avoid downloading the full image.
/// Streams the response and reads at most 64 bytes, even if the server ignores
/// the Range header and returns the full file.
///
/// Only determines [ImageFormat]. Location must already be established
/// by a sync resolver before this runs.
///
/// Returns null for non-network sources or on any fetch failure.
class MagicBytesResolver implements AsyncSourceResolver {
  final http.Client _client;

  MagicBytesResolver({required http.Client client}) : _client = client;

  @override
  Future<ResolvedSource?> resolve(String source) async {
    if (!source.startsWith('http://') && !source.startsWith('https://')) {
      return null;
    }

    try {
      final request = http.Request('GET', Uri.parse(source))
        ..headers['Range'] = 'bytes=0-63';

      final streamed = await _client.send(request);

      if (streamed.statusCode != 200 && streamed.statusCode != 206) {
        streamed.stream.drain();
        return null;
      }

      final bytes = <int>[];
      await for (final chunk in streamed.stream) {
        bytes.addAll(chunk);
        if (bytes.length >= 64) break;
      }

      final format = _detectFormat(Uint8List.fromList(bytes));
      if (format == null) return null;

      return ResolvedSource(raw: source, format: format);
    } catch (_) {
      return null;
    }
  }

  ImageFormat? _detectFormat(Uint8List bytes) {
    if (bytes.isEmpty) return null;
    if (_isPng(bytes)) return ImageFormat.raster;
    if (_isJpeg(bytes)) return ImageFormat.raster;
    if (_isWebp(bytes)) return ImageFormat.raster;
    if (_isGif(bytes)) return ImageFormat.raster;
    if (_isSvg(bytes)) return ImageFormat.svg;
    return null;
  }

  bool _isPng(Uint8List b) =>
      b.length >= 4 &&
      b[0] == 0x89 &&
      b[1] == 0x50 &&
      b[2] == 0x4E &&
      b[3] == 0x47;

  bool _isJpeg(Uint8List b) => b.length >= 2 && b[0] == 0xFF && b[1] == 0xD8;

  bool _isWebp(Uint8List b) =>
      b.length >= 12 &&
      b[0] == 0x52 &&
      b[1] == 0x49 &&
      b[2] == 0x46 &&
      b[3] == 0x46 && // RIFF
      b[8] == 0x57 &&
      b[9] == 0x45 &&
      b[10] == 0x42 &&
      b[11] == 0x50; // WEBP

  bool _isGif(Uint8List b) =>
      b.length >= 3 && b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46; // GIF

  bool _isSvg(Uint8List b) {
    final text = utf8.decode(b, allowMalformed: true).trimLeft();
    if (text.startsWith('<svg')) return true;
    if (text.startsWith('<?xml')) return text.contains('<svg');
    return false;
  }
}
