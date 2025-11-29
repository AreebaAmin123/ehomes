import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomNetworkImageProvider
    extends ImageProvider<CustomNetworkImageProvider> {
  final String url;
  final Map<String, String>? headers;
  final double scale;

  const CustomNetworkImageProvider(
    this.url, {
    this.headers,
    this.scale = 1.0,
  });

  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300x400?text=No+Image';
    }

    // Clean the URL
    var cleanUrl = url.trim();

    // If it's already a full URL, validate and return
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    // Remove any leading/trailing slashes
    cleanUrl = cleanUrl.replaceAll(RegExp(r'^/+|/+$'), '');

    // Extract filename (last component)
    final filename = cleanUrl.split('/').last;

    // Add extension if missing
    final filenameWithExt =
        !filename.contains('.') ? '$filename.jpg' : filename;

    // Define possible base paths in order of preference
    final basePaths = [
      'https://ehomes.pk/Vendor_Panel/uploads/slider',
      'https://ehomes.pk/Vendor_Panel/uploads/banners',
      'https://ehomes.pk/Vendor_Panel/upload_banner',
      'https://ehomes.pk/Vendor_Panel/uploads',
      'https://ehomes.pk/admin_panel/uploads/slider',
      'https://ehomes.pk/admin_panel/uploads'
    ];

    // For slider/banner images, try all paths
    if (cleanUrl.contains('slider') || cleanUrl.contains('banner')) {
      return '${basePaths[0]}/$filenameWithExt';
    }

    // For other images, use appropriate path based on context
    if (cleanUrl.contains('admin_panel/uploads')) {
      return '${basePaths[5]}/$filenameWithExt';
    } else if (cleanUrl.contains('admin_panel/upload_banner')) {
      return '${basePaths[2]}/$filenameWithExt';
    } else if (cleanUrl.contains('Vendor_Panel/upload_promotion')) {
      return 'https://ehomes.pk/Vendor_Panel/upload_promotion/$filenameWithExt';
    } else {
      // Default to vendor panel uploads
      return '${basePaths[3]}/$filenameWithExt';
    }
  }

  @override
  Future<CustomNetworkImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture<CustomNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CustomNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: scale,
      debugLabel: url,
      informationCollector: () sync* {
        yield ErrorDescription('Image URL: $url');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
    CustomNetworkImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    try {
      final client = http.Client();
      final fixedUrl = fixImageUrl(url);
      final uri = Uri.parse(fixedUrl);
      final request = http.Request('GET', uri);

      if (headers != null) {
        request.headers.addAll(headers!);
      }
      request.headers.addAll({
        'Accept': 'image/jpeg,image/png,image/*;q=0.8',
        'User-Agent': 'Flutter/1.0',
        'Cache-Control': 'max-age=31536000',
      });

      final response = await client.send(request);

      if (response.statusCode != 200) {
        client.close();
        throw Exception('HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      var bytesReceived = 0;
      final List<List<int>> chunks = [];

      await for (final chunk in response.stream) {
        chunks.add(chunk);
        bytesReceived += chunk.length;
        chunkEvents.add(ImageChunkEvent(
          cumulativeBytesLoaded: bytesReceived,
          expectedTotalBytes: totalBytes,
        ));
      }

      client.close();

      final Uint8List bytes = Uint8List.fromList(
        chunks.expand((chunk) => chunk).toList(),
      );

      if (!await _validateImageData(bytes)) {
        throw Exception('Invalid image data');
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      debugPrint('Error loading image $url: $e');
      if (url.contains('.webp')) {
        // Try fallback to JPEG if WebP fails
        return _loadAsync(
          CustomNetworkImageProvider(
            url.replaceAll('.webp', '.jpg'),
            headers: headers,
            scale: scale,
          ),
          chunkEvents,
          decode,
        );
      }
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  Future<bool> _validateImageData(Uint8List bytes) async {
    try {
      if (bytes.length < 12) return false;

      // Check for JPEG header (FF D8)
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return true;
      }

      // Check for PNG header (89 50 4E 47 0D 0A 1A 0A)
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47 &&
          bytes[4] == 0x0D &&
          bytes[5] == 0x0A &&
          bytes[6] == 0x1A &&
          bytes[7] == 0x0A) {
        return true;
      }

      // Check for WebP header (RIFF .... WEBP)
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error validating image data: $e');
      return false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CustomNetworkImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CustomNetworkImageProvider')}("$url", scale: $scale)';
}
