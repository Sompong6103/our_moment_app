import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfileAvatar({super.key, this.imageUrl, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E1FF),
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _fallback()
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Icon(Icons.person, size: size * 0.5, color: AppColors.primary);
  }
}
