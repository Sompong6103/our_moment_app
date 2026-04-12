import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/event_model.dart';
import 'attendee_avatars.dart';

class EventDetailHeader extends StatelessWidget {
  final EventModel event;
  final List<String> attendeeAvatarUrls;

  const EventDetailHeader({
    super.key,
    required this.event,
    this.attendeeAvatarUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: event.coverImageUrl != null
              ? Image.network(
                  event.coverImageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : event.coverImage != null
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

        Text(
          event.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        if (event.location != null)
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.primary,
            text: event.location!,
          ),
        const SizedBox(height: 6),

        _InfoRow(
          icon: Icons.calendar_today_outlined,
          iconColor: AppColors.primary,
          text: event.time != null
              ? '${event.date} | ${event.time}'
              : event.date,
        ),
        const SizedBox(height: 12),

        AttendeeAvatars(
          count: event.attendeeCount,
          avatarUrls: attendeeAvatarUrls,
          avatarSize: 30,
          label: '${event.joinedCount ?? event.attendeeCount} People are joined',
        ),
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
