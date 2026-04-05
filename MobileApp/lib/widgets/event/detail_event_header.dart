import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/event_model.dart';

class DetailEventHeader extends StatelessWidget {
  final EventModel event;

  const DetailEventHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: event.coverImage != null
              ? Image.asset(
                  event.coverImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        event.coverColor,
                        event.coverColor.withAlpha(180),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Location
        if (event.location != null)
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.primary,
            text: event.location!,
          ),
        const SizedBox(height: 6),

        // Date & time
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          iconColor: AppColors.primary,
          text: event.time != null
              ? '${event.date} | ${event.time}'
              : event.date,
        ),
        const SizedBox(height: 12),

        // Attendee avatars + joined count
        _AttendeesRow(event: event),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendeesRow extends StatelessWidget {
  final EventModel event;

  const _AttendeesRow({required this.event});

  static const _avatarSize = 30.0;
  static const _overlap = 10.0;

  @override
  Widget build(BuildContext context) {
    final shown = event.attendeeCount.clamp(0, 3);
    final hasExtras = event.attendeeCount > 3;

    return Row(
      children: [
        SizedBox(
          height: _avatarSize,
          width: shown * (_avatarSize - _overlap) +
              _overlap +
              (hasExtras ? 32 : 0),
          child: Stack(
            children: [
              for (int i = 0; i < shown; i++)
                Positioned(
                  left: i * (_avatarSize - _overlap),
                  child: CircleAvatar(
                    radius: _avatarSize / 2,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person,
                        size: 14, color: Colors.white),
                  ),
                ),
              if (hasExtras)
                Positioned(
                  left: shown * (_avatarSize - _overlap),
                  child: Container(
                    width: _avatarSize,
                    height: _avatarSize,
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${event.attendeeCount - shown}+',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${event.joinedCount ?? event.attendeeCount} People are joined',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
