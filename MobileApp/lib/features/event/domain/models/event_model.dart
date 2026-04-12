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
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      formattedDate = '${days[dateStart.weekday - 1]}, ${dateStart.day} ${months[dateStart.month - 1]} ${dateStart.year}';
      final startTime = '${dateStart.hour.toString().padLeft(2, '0')}:${dateStart.minute.toString().padLeft(2, '0')}';
      if (dateEnd != null) {
        final endTime = '${dateEnd.hour.toString().padLeft(2, '0')}:${dateEnd.minute.toString().padLeft(2, '0')}';
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

  /// Whether check-in is available (joined guest on event day).
  bool get canCheckIn {
    if (isHost || !isJoined || eventDateTime == null) return false;
    final now = DateTime.now();
    return now.year == eventDateTime!.year &&
        now.month == eventDateTime!.month &&
        now.day == eventDateTime!.day;
  }
}
