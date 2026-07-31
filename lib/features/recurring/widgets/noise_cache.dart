import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'noise_texture.dart';

/// Singleton cache for the inlined noise texture.
/// Decodes the base64 once and reuses the same `Uint8List`/`MemoryImage`.
class NoiseCache {
  static Uint8List? _bytes;
  static MemoryImage? _image;
  static bool _isInitializing = false;

  static Uint8List _decodeNoise(String base64Str) {
    return base64Decode(base64Str);
  }

  static Future<void> initialize() async {
    if (_bytes != null || _isInitializing) return;
    _isInitializing = true;
    try {
      _bytes = await compute(_decodeNoise, noiseTextureBase64);
      _image = MemoryImage(_bytes!);
    } catch (e) {
      debugPrint('NoiseCache initialization error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  static Uint8List get bytes {
    if (_bytes == null) {
      // Fallback to synchronous decode if accessed before initialize completes
      _bytes = base64Decode(noiseTextureBase64);
      _image = MemoryImage(_bytes!);
    }
    return _bytes!;
  }

  static ImageProvider get image {
    if (_image == null) {
      final _ = bytes; // trigger decode
    }
    return _image!;
  }
}
