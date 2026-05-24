import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<String?> pickImageAsBase64() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  static bool isBase64(String source) {
    return source.startsWith('data:image');
  }

  static Uint8List? decodeBase64(String source) {
    try {
      final commaIndex = source.indexOf(',');
      if (commaIndex == -1) return null;
      return base64Decode(source.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}

class AppImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return _fallback();

    if (ImageHelper.isBase64(source)) {
      final bytes = ImageHelper.decodeBase64(source);
      if (bytes == null) return _fallback();
      try {
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      } catch (_) {
        return _fallback();
      }
    }

    try {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF2A9D8F),
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } catch (_) {
      return _fallback();
    }
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(Icons.eco_outlined,
            size: (width ?? 40) * 0.5, color: const Color(0xFFBDBDBD)),
      ),
    );
  }
}
