import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/event_model.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/segment_button.dart';
import '../../widgets/event/event_card.dart';
import '../../widgets/profile/profile_detail_scaffold.dart';

class MyEventScreen extends StatefulWidget {
  final List<EventModel> hostedEvents;
  final List<EventModel> pastEvents;

  const MyEventScreen({
    super.key,
    required this.hostedEvents,
    required this.pastEvents,
  });

  @override
  State<MyEventScreen> createState() => _MyEventScreenState();
}

class _MyEventScreenState extends State<MyEventScreen> {
  int _selectedTab = 0;

  List<EventModel> get _visibleEvents {
    return _selectedTab == 0 ? widget.hostedEvents : widget.pastEvents;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: 'My Event',
      child: Padding(
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
                      title: 'Past Event',
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
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
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
