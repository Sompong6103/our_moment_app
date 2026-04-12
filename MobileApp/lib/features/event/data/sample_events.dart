import 'package:flutter/material.dart';
import '../domain/models/event_model.dart';

final sampleEvents = [
  EventModel(
    title: "Aom & Ton's Wedding",
    type: 'Wedding ceremony',
    date: 'Sat, 25 Oct 2025',
    organizer: 'Courtney Henny',
    coverColor: const Color(0xFF7BA3AC),
    attendeeCount: 3,
    location: 'Thailand, Bangkok, Baiyok tower',
    time: '18:00 - 22:00',
    description:
        'A casual yet insightful gathering for designers, creators, and digital thinkers to connect, share stories, and explore the future of design. Join us for a day filled with inspiring talks, interactive sessions, and networking with local talents from the creative industry.',
    coverImage: 'assets/images/detail_event_mockup.png',
    themeColor: const Color(0xFF001F54),
    themeName: 'Blue Navy',
    joinedCount: 15,
    isHost: true,
    eventDateTime: DateTime(2025, 10, 25),
  ),
  EventModel(
    title: "Aom & Ton's Wedding",
    type: 'Wedding ceremony',
    date: '16 Feb 2026',
    organizer: 'Kristin Watson',
    coverColor: const Color(0xFF8CAB7A),
    attendeeCount: 3,
    location: 'Thailand, Bangkok, Baiyok tower',
    time: '18:00 - 22:00',
    description:
        'A casual yet insightful gathering for designers, creators, and digital thinkers to connect, share stories, and explore the future of design.',
    coverImage: 'assets/images/detail_event_mockup.png',
    themeColor: const Color(0xFF001F54),
    themeName: 'Blue Navy',
    joinedCount: 15,
    isJoined: true,
    eventDateTime: DateTime(2026, 2, 16),
  ),
  EventModel(
    title: "Aom & Ton's Wedding",
    type: 'Wedding ceremony',
    date: '12 Apr 2026',
    organizer: 'Kristin Watson',
    coverColor: const Color(0xFF8CAB7A),
    attendeeCount: 3,
    location: 'Thailand, Bangkok, Baiyok tower',
    time: '18:00 - 22:00',
    description:
        'A casual yet insightful gathering for designers, creators, and digital thinkers to connect, share stories, and explore the future of design.',
    coverImage: 'assets/images/detail_event_mockup.png',
    themeColor: const Color(0xFF001F54),
    themeName: 'Blue Navy',
    joinedCount: 15,
    isJoined: true,
    eventDateTime: DateTime(2026, 4, 12),
  ),
];
