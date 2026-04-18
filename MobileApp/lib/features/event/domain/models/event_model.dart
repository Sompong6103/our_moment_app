import 'package:flutter/material.dart';
import '../../../../core/services/api_config.dart';

class EventModel {
  final String id;
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
  final String? coverImageUrl;
  final Color? themeColor;
  final String? themeName;
  final int? joinedCount;
  final bool isHost;
  final bool isJoined;
  final DateTime? eventDateTime;
  final DateTime? eventDateEnd;
  final String? joinCode;
  final String? status;
  final String? organizerId;
  final bool acceptPhotos;
  final int? guestCount;
  final int? photoCount;
  final int? wishCount;
  final double? latitude;
  final double? longitude;
  final String? organizerAvatarUrl;

  const EventModel({
    required this.id,
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
    this.coverImageUrl,
    this.themeColor,
    this.themeName,
    this.joinedCount,
    this.isHost = false,
    this.isJoined = false,
    this.eventDateTime,
    this.eventDateEnd,
    this.joinCode,
    this.status,
    this.organizerId,
    this.acceptPhotos = false,
    this.guestCount,
    this.photoCount,
    this.wishCount,
    this.latitude,
    this.longitude,
    this.organizerAvatarUrl,
  });

  static Color _parseColor(String? hex, [Color fallback = const Color(0xFF655CBB)]) {
    if (hex == null || hex.isEmpty) return fallback;
    String h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.tryParse(h, radix: 16) ?? fallback.toARGB32());
  }

  static String? _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ApiConfig.uploadsUrl}/$url';
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final dateStart = json['dateStart'] != null ? DateTime.tryParse(json['dateStart']) : null;
    final dateEnd = json['dateEnd'] != null ? DateTime.tryParse(json['dateEnd']) : null;

    String formattedDate = '';
    String? formattedTime;
    if (dateStart != null) {
      final localStart = dateStart.toLocal();
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      formattedDate = '${days[localStart.weekday - 1]}, ${localStart.day} ${months[localStart.month - 1]} ${localStart.year}';
      final startTime = '${localStart.hour.toString().padLeft(2, '0')}:${localStart.minute.toString().padLeft(2, '0')}';
      if (dateEnd != null) {
        final localEnd = dateEnd.toLocal();
        final endTime = '${localEnd.hour.toString().padLeft(2, '0')}:${localEnd.minute.toString().padLeft(2, '0')}';
        formattedTime = '$startTime - $endTime';
      } else {
        formattedTime = startTime;
      }
    }

    String organizerName = 'Unknown';
    String? organizerAvatar;
    if (json['organizer'] is Map) {
      organizerName = json['organizer']['fullName'] ?? 'Unknown';
      organizerAvatar = _fullImageUrl(json['organizer']['avatarUrl']);
    }

    final counts = json['_count'] as Map<String, dynamic>?;

    // Location
    String? locationStr;
    double? lat;
    double? lng;
    if (json['location'] is Map) {
      final loc = json['location'] as Map<String, dynamic>;
      locationStr = loc['address'] as String?;
      lat = double.tryParse(loc['latitude']?.toString() ?? '');
      lng = double.tryParse(loc['longitude']?.toString() ?? '');
    } else if (json['location'] is String) {
      locationStr = json['location'];
    }

    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      date: formattedDate,
      organizer: organizerName,
      coverColor: _parseColor(json['coverColor']),
      attendeeCount: counts?['guests'] ?? 0,
      location: locationStr,
      time: formattedTime,
      description: json['description'],
      coverImageUrl: _fullImageUrl(json['coverImageUrl']),
      themeColor: json['themeColor'] != null ? _parseColor(json['themeColor']) : null,
      themeName: json['themeName'],
      joinedCount: counts?['guests'],
      joinCode: json['joinCode'],
      status: json['status'],
      organizerId: json['organizerId'],
      acceptPhotos: json['acceptPhotos'] ?? false,
      eventDateTime: dateStart,
      eventDateEnd: dateEnd,
      isHost: json['_isHost'] ?? false,
      isJoined: json['_isJoined'] ?? false,
      guestCount: counts?['guests'],
      photoCount: counts?['photos'],
      wishCount: counts?['wishes'],
      latitude: lat,
      longitude: lng,
      organizerAvatarUrl: organizerAvatar,
    );
  }

  /// Whether check-in is available (joined guest, event day, before end time).
  bool get canCheckIn {
    if (isHost || !isJoined || eventDateTime == null) return false;
    final now = DateTime.now();
    final localStart = eventDateTime!.toLocal();
    final sameDay = now.year == localStart.year &&
        now.month == localStart.month &&
        now.day == localStart.day;
    if (!sameDay) return false;
    // If event has end time, can only check in before it ends
    if (eventDateEnd != null && now.isAfter(eventDateEnd!)) return false;
    return true;
  }

  /// Whether the event has ended (past end time or past event day).
  bool get isEventOver {
    if (eventDateTime == null) return false;
    final now = DateTime.now();
    if (eventDateEnd != null) return now.isAfter(eventDateEnd!);
    // No end time: consider event over after the event day
    final localStart = eventDateTime!.toLocal();
    final endOfDay = DateTime(localStart.year, localStart.month, localStart.day, 23, 59, 59);
    return now.isAfter(endOfDay);
  }

  /// Whether the event ended more than 1 day ago.
  bool get isEventPastOneDay {
    if (eventDateTime == null) return false;
    final now = DateTime.now();
    final ref = eventDateEnd ?? eventDateTime!;
    return now.difference(ref).inDays >= 1;
  }
}
