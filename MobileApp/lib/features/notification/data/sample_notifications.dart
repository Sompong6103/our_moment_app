import '../domain/models/notification_model.dart';

const sampleNotifications = <NotificationModel>[
  NotificationModel(
    text:
        "The traditional Thai wedding procession (Khun Mak) of Aom & Ton's Wedding is about to begin.",
    type: NotificationType.ceremony,
  ),
  NotificationModel(
    text: "In 3 days you have Aom & Ton's Wedding event.",
    type: NotificationType.reminder,
  ),
];
