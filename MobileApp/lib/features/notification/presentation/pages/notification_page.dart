import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/models/notification_model.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  final List<NotificationModel> notifications;

  const NotificationPage({super.key, required this.notifications});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _notifRepo = NotificationRepository();
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(widget.notifications);
  }

  @override
  void didUpdateWidget(covariant NotificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifications != widget.notifications) {
      _notifications = List.of(widget.notifications);
    }
  }

  Future<void> _markAsRead(int index) async {
    final notif = _notifications[index];
    if (notif.isRead || notif.id == null) return;
    try {
      await _notifRepo.markRead(notif.id!);
      if (mounted) {
        setState(() {
          _notifications[index] = NotificationModel(
            id: notif.id,
            text: notif.text,
            type: notif.type,
            isRead: true,
            createdAt: notif.createdAt,
            eventId: notif.eventId,
          );
        });
      }
    } catch (_) {}
  }

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
          child: _notifications.isEmpty
              ? const EmptyState(
                  title: 'Notifications will appear here',
                  subtitle: 'watch this space for offer, update, and more',
                  imageAsset: 'assets/images/empty_notifications.png',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return NotificationCard(
                      notification: _notifications[index],
                      onTap: () => _markAsRead(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
