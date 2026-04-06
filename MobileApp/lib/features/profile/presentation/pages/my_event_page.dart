import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/segment_button.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../event/domain/models/event_model.dart';
import '../../../event/presentation/widgets/event_card.dart';

class MyEventPage extends StatefulWidget {
  final List<EventModel> hostedEvents;
  final List<EventModel> pastEvents;

  const MyEventPage({
    super.key,
    required this.hostedEvents,
    required this.pastEvents,
  });

  @override
  State<MyEventPage> createState() => _MyEventPageState();
}

class _MyEventPageState extends State<MyEventPage> {
  int _selectedTab = 0;

  List<EventModel> get _visibleEvents {
    return _selectedTab == 0 ? widget.hostedEvents : widget.pastEvents;
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
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
