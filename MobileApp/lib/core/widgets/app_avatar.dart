import 'package:flutter/material.dart';
import '../services/api_config.dart';
import '../theme/app_colors.dart';

/// Reusable circular avatar with network image and fallback icon.
///
/// Consolidated from ProfileAvatar + inline CircleAvatars across the app.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color fallbackBackgroundColor;
  final Color fallbackIconColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.size = 64,
    this.fallbackBackgroundColor = AppColors.avatarFallback,
    this.fallbackIconColor = AppColors.primary,
  });

  String? get _resolvedUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    return '${ApiConfig.uploadsUrl}/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 2);
    final url = _resolvedUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fallbackBackgroundColor,
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _fallback()
          : Image.network(
              url,
              fit: BoxFit.cover,
              headers: const {'Cache-Control': 'no-cache'},
              errorBuilder: (context, error, stackTrace) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Icon(Icons.person, size: size * 0.5, color: fallbackIconColor);
  }
}
