import 'package:flutter/material.dart';

class EventModel {
  final String title;
  final String type;
  final String date;
  final String organizer;
  final Color coverColor;
  final int attendeeCount;

  const EventModel({
    required this.title,
    required this.type,
    required this.date,
    required this.organizer,
    required this.coverColor,
    required this.attendeeCount,
  });
}
