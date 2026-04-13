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
  final String? id;
  final String title;
  final String message;
  final String? eventName;
  final NotificationType type;
  final bool isRead;
  final DateTime? createdAt;
  final String? eventId;

  const NotificationModel({
    this.id,
    required this.title,
    required this.message,
    this.eventName,
    required this.type,
    this.isRead = false,
    this.createdAt,
    this.eventId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType type;
    switch (json['type']?.toString().toLowerCase()) {
      case 'ceremony':
        type = NotificationType.ceremony;
        break;
      case 'reminder':
        type = NotificationType.reminder;
        break;
      case 'offer':
        type = NotificationType.offer;
        break;
      default:
        type = NotificationType.update;
    }

    // Extract event name from nested event object or direct field
    String? eventName;
    if (json['event'] is Map) {
      eventName = (json['event'] as Map<String, dynamic>)['title'];
    } else if (json['eventName'] is String) {
      eventName = json['eventName'];
    }

    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? json['title'] ?? '',
      eventName: eventName,
      type: type,
      isRead: json['isRead'] ?? json['readAt'] != null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      eventId: json['eventId'],
    );
  }
}
