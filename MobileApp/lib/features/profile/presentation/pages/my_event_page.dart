import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/segment_button.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../event/data/repositories/event_repository.dart';
import '../../../event/domain/models/event_model.dart';
import '../../../event/presentation/widgets/event_card.dart';

class MyEventPage extends StatefulWidget {
  const MyEventPage({super.key});

  @override
  State<MyEventPage> createState() => _MyEventPageState();
}

class _MyEventPageState extends State<MyEventPage> {
  int _selectedTab = 0;
  List<EventModel> _hostedEvents = [];
  List<EventModel> _joinedEvents = [];
  bool _loading = true;

  final _eventRepo = EventRepository();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final data = await _eventRepo.listMyEvents();
      if (mounted) {
        setState(() {
          _hostedEvents = data['organized'] ?? [];
          _joinedEvents = data['joined'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<EventModel> get _visibleEvents {
    return _selectedTab == 0 ? _hostedEvents : _joinedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'My Event',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.segmentBackground,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentButton(
                      title: 'Host',
                      selected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: SegmentButton(
                      title: 'Joined',
                      selected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _visibleEvents.isEmpty
                  ? const EmptyState(
                      title: 'No events available',
                      subtitle: 'Your events will appear here.',
                      imageAsset: 'assets/images/empty_events.png',
                    )
                  : ListView.separated(
                      itemCount: _visibleEvents.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        return EventCard(event: _visibleEvents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
