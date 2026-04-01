import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class AttendeeAvatars extends StatelessWidget {
  final int count;

  const AttendeeAvatars({super.key, required this.count});

  static const _avatarDiameter = 26.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, 3);
    final extras = count - shown;
    final totalWidth =
        shown * (_avatarDiameter - _overlap) + _overlap + (extras > 0 ? 28 : 0);

    return SizedBox(
      height: _avatarDiameter,
      width: totalWidth,
      child: Stack(
        children: [
          for (int i = 0; i < shown; i++)
            Positioned(
              left: i * (_avatarDiameter - _overlap),
              child: CircleAvatar(
                radius: _avatarDiameter / 2,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 13, color: Colors.white),
              ),
            ),
          if (extras > 0)
            Positioned(
              left: shown * (_avatarDiameter - _overlap),
              child: CircleAvatar(
                radius: _avatarDiameter / 2,
                backgroundColor: AppColors.primary,
                child: Text(
                  '+$extras',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
