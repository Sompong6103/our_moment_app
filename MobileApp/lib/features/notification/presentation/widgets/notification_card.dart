import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: notification.isRead ? AppColors.border : AppColors.primary.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.type.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.type.icon,
                color: notification.type.iconColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                notification.text,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
