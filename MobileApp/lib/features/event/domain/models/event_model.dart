import 'package:flutter/material.dart';

class EventModel {
  final String title;
  final String type;
  final String date;
  final String organizer;
  final Color coverColor;
  final int attendeeCount;
  final String? location;
  final String? time;
  final String? description;
  final String? coverImage;
  final Color? themeColor;
  final String? themeName;
  final int? joinedCount;
  final bool isHost;
  final bool isJoined;
  final DateTime? eventDateTime;

  const EventModel({
    required this.title,
    required this.type,
    required this.date,
    required this.organizer,
    required this.coverColor,
    required this.attendeeCount,
    this.location,
    this.time,
    this.description,
    this.coverImage,
    this.themeColor,
    this.themeName,
    this.joinedCount,
    this.isHost = false,
    this.isJoined = false,
    this.eventDateTime,
  });

  /// Whether check-in is available (joined guest on event day).
  bool get canCheckIn {
    if (isHost || !isJoined || eventDateTime == null) return false;
    final now = DateTime.now();
    return now.year == eventDateTime!.year &&
        now.month == eventDateTime!.month &&
        now.day == eventDateTime!.day;
  }
}
