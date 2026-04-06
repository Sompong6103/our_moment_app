import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/models/notification_model.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationPage({super.key, required this.notifications});

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
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return NotificationCard(
                        notification: notifications[index]);
                  },
                ),
        ),
      ],
    );
  }
}
