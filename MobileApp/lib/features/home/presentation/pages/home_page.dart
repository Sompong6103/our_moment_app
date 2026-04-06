import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../event/data/sample_events.dart';
import '../../../event/domain/models/event_model.dart';
import '../../../event/presentation/pages/create_event_page.dart';
import '../../../event/presentation/pages/join_event_page.dart';
import '../../../event/presentation/widgets/event_card.dart';
import '../../../event/presentation/widgets/event_section_header.dart';
import '../../../notification/data/sample_notifications.dart';
import '../../../notification/domain/models/notification_model.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../../../profile/presentation/pages/my_account_page.dart';
import '../widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  final List<EventModel> _events = List.from(sampleEvents);
  final List<NotificationModel> _notifications = List.from(sampleNotifications);

  void _showPlusMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: const Text('Join event'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinEventPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Create event'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateEventPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    if (_navIndex == 1) {
      return NotificationPage(notifications: _notifications);
    }

    if (_navIndex == 2) {
      return const MyAccountPage();
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader(name: 'Cheewanon S.')),
        if (_events.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverToBoxAdapter(
              child: EventSectionHeader(count: _events.length),
            ),
          ),
        if (_events.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: 'You don\'t have a ceremony yet.',
              subtitle: 'You can view the ceremonies you have attended here.',
              imageAsset: 'assets/images/empty_events.png',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EventCard(event: _events[i]),
                ),
                childCount: _events.length,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: _buildTabBody()),
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton(
              onPressed: _showPlusMenu,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _navIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onDestinationSelected: (i) => setState(() => _navIndex = i),
          destinations: [
            NavigationDestination(
              icon: Icon(
                size: 26,
                Icons.home,
                color: _navIndex == 0
                    ? AppColors.primary
                    : AppColors.iconInactive,
              ),
              selectedIcon: const Icon(
                Icons.home,
                color: AppColors.primary,
                size: 26,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.notifications,
                size: 26,
                color: _navIndex == 1
                    ? AppColors.primary
                    : AppColors.iconInactive,
              ),
              selectedIcon: const Icon(
                Icons.notifications,
                color: AppColors.primary,
                size: 26,
              ),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person,
                size: 26,
                color: _navIndex == 2
                    ? AppColors.primary
                    : AppColors.iconInactive,
              ),
              selectedIcon: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 26,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
