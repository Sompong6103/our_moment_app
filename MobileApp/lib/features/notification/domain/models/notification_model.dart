import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum NotificationType { ceremony, reminder, update, offer }

extension NotificationTypeStyle on NotificationType {
  Color get iconColor {
    switch (this) {
      case NotificationType.ceremony:
        return AppColors.notifCeremonyIcon;
      case NotificationType.reminder:
        return AppColors.notifReminderIcon;
      case NotificationType.update:
        return AppColors.notifUpdateIcon;
      case NotificationType.offer:
        return AppColors.notifOfferIcon;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case NotificationType.ceremony:
        return AppColors.notifCeremonyBg;
      case NotificationType.reminder:
        return AppColors.notifReminderBg;
      case NotificationType.update:
        return AppColors.notifUpdateBg;
      case NotificationType.offer:
        return AppColors.notifOfferBg;
    }
  }

  Color get borderColor {
    switch (this) {
      case NotificationType.ceremony:
        return AppColors.notifCeremonyBorder;
      case NotificationType.reminder:
        return AppColors.notifReminderBorder;
      case NotificationType.update:
        return AppColors.notifUpdateBorder;
      case NotificationType.offer:
        return AppColors.notifOfferBorder;
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.ceremony:
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.update:
        return Icons.campaign;
      case NotificationType.offer:
        return Icons.local_offer;
    }
  }
}

class NotificationModel {
  final String text;
  final NotificationType type;

  const NotificationModel({required this.text, required this.type});
}
