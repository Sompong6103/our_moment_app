import 'package:flutter/material.dart';
import '../../../../core/services/api_config.dart';
import '../../data/repositories/guest_repository.dart';
import '../../domain/models/event_model.dart';
import '../pages/event_detail_page.dart';
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
            builder: (_) => EventDetailPage(event: event),
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
        if (event.coverImageUrl != null)
          Image.network(
            event.coverImageUrl!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        else if (event.coverImage != null)
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _OrganizerRow extends StatefulWidget {
  final EventModel event;

  const _OrganizerRow({required this.event});

  @override
  State<_OrganizerRow> createState() => _OrganizerRowState();
}

class _OrganizerRowState extends State<_OrganizerRow> {
  final _guestRepo = GuestRepository();
  List<String> _avatarUrls = const [];

  @override
  void initState() {
    super.initState();
    _loadAttendeeAvatars();
  }

  Future<void> _loadAttendeeAvatars() async {
    try {
      final guests = await _guestRepo.list(widget.event.id);
      final urls = guests
          .map((g) => (g['user'] as Map<String, dynamic>?)?['avatarUrl']?.toString() ?? '')
          .where((u) => u.isNotEmpty)
          .map((u) => u.startsWith('http') ? u : '${ApiConfig.uploadsUrl}/$u')
          .take(3)
          .toList();

      if (mounted) {
        setState(() => _avatarUrls = urls);
      }
    } catch (_) {
      // Keep fallback placeholder avatars on API failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[300],
            backgroundImage: event.organizerAvatarUrl != null ? NetworkImage(event.organizerAvatarUrl!) : null,
            child: event.organizerAvatarUrl == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'by ${event.organizer}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 8),
          AttendeeAvatars(count: event.attendeeCount, avatarUrls: _avatarUrls),
        ],
      ),
    );
  }
}
