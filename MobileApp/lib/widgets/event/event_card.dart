import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../screens/event/detail_event_screen.dart';
import 'attendee_avatars.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailEventScreen(event: event),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withAlpha(80),
        surfaceTintColor: Colors.white,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(event: event),
            _OrganizerRow(event: event),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final EventModel event;

  const _CoverImage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (event.coverImage != null)
          Image.asset(
            event.coverImage!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        else
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [event.coverColor, event.coverColor.withAlpha(180)],
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withAlpha(168), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.type} • ${event.date}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrganizerRow extends StatelessWidget {
  final EventModel event;

  const _OrganizerRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            'by ${event.organizer}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const Spacer(),
          AttendeeAvatars(count: event.attendeeCount),
        ],
      ),
    );
  }
}
