import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/notification_model.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/notification/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Notification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: notifications.isEmpty
              ? const EmptyState(
                  title: 'Notifications will appear here',
                  subtitle: 'watch this space for offer, update, and more',
                  imageAsset: 'assets/images/empty_notifications.png',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return NotificationCard(notification: notifications[index]);
                  },
                ),
        ),
      ],
    );
  }
}
