import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Overlapping circular avatar row with optional count label.
///
/// Consolidated from the original AttendeeAvatars widget and
/// _AttendeesRow in detail_event_header.
class AttendeeAvatars extends StatelessWidget {
  final int count;
  final double avatarSize;
  final double overlap;
  final String? label;

  const AttendeeAvatars({
    super.key,
    required this.count,
    this.avatarSize = 26,
    this.overlap = 10,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, 3);
    final extras = count - shown;
    final hasExtras = extras > 0;
    final totalWidth =
        shown * (avatarSize - overlap) + overlap + (hasExtras ? avatarSize + 2 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: avatarSize,
          width: totalWidth,
          child: Stack(
            children: [
              for (int i = 0; i < shown; i++)
                Positioned(
                  left: i * (avatarSize - overlap),
                  child: CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: avatarSize * 0.5, color: Colors.white),
                  ),
                ),
              if (hasExtras)
                Positioned(
                  left: shown * (avatarSize - overlap),
                  child: CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '+$extras',
                      style: TextStyle(color: Colors.white, fontSize: avatarSize * 0.35),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
