import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/models/notification_model.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  final List<NotificationModel> notifications;
  final VoidCallback? onAllRead;

  const NotificationPage({super.key, required this.notifications, this.onAllRead});

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
    _markAllAsRead();
  }

  @override
  void didUpdateWidget(covariant NotificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifications != widget.notifications) {
      _notifications = List.of(widget.notifications);
      _markAllAsRead();
    }
  }

  Future<void> _markAllAsRead() async {
    final hasUnread = _notifications.any((n) => !n.isRead);
    if (!hasUnread) return;
    try {
      await _notifRepo.markAllRead();
      if (mounted) {
        setState(() {
          _notifications = _notifications
              .map((n) => n.isRead
                  ? n
                  : NotificationModel(
                      id: n.id,
                      title: n.title,
                      message: n.message,
                      eventName: n.eventName,
                      type: n.type,
                      isRead: true,
                      createdAt: n.createdAt,
                      eventId: n.eventId,
                    ))
              .toList();
        });
        // Notify parent to update badge
        widget.onAllRead?.call();
      }
    } catch (_) {}
  }

  Future<void> _refresh() async {
    try {
      final items = await _notifRepo.list();
      if (mounted) {
        setState(() => _notifications = items);
        // After refresh, mark all read again
        _markAllAsRead();
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
              ? const Center(
                  child: EmptyState(
                    title: 'Notifications will appear here',
                    subtitle: 'Watch this space for offers, updates, and more',
                    imageAsset: 'assets/images/empty_notifications.png',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      return NotificationCard(
                        notification: _notifications[index],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
