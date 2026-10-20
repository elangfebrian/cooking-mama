import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Gambar resep dengan placeholder saat memuat / gagal.
/// Bila [width]/[height] kosong, gambar mengisi ruang dari parent
/// (mis. di dalam AspectRatio 4:3).
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.radius = 12,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? height;
  final double? width;
  final double radius;
  final BoxFit fit;

  Widget _placeholder() => Container(
        height: height,
        width: width,
        color: AppTheme.orangeSoft,
        child: const Center(
          child: Icon(Icons.restaurant, color: AppTheme.orange, size: 36),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? _placeholder()
          : (!kIsWeb && (url.startsWith('/') || url.startsWith('file://')))
              // Foto dari kamera/galeri (path lokal) - hanya di app native.
              ? Image.file(
                  File(url.replaceFirst('file://', '')),
                  height: height,
                  width: width,
                  fit: fit,
                  errorBuilder: (c, e, s) => _placeholder(),
                )
              : Image.network(
              url,
              height: height,
              width: width,
              fit: fit,
              loadingBuilder: (c, child, p) => p == null ? child : _placeholder(),
              errorBuilder: (c, e, s) => _placeholder(),
            ),
    );
  }
}
