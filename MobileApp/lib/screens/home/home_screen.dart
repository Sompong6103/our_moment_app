import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/common/app_loading.dart';
import '../../data/sample_notifications.dart';
import '../../data/sample_events.dart';
import '../../models/event_model.dart';
import '../../models/notification_model.dart';
import '../notification/notification_screen.dart';
import '../profile/my_account_screen.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/event/event_card.dart';
import '../../widgets/event/events_section_header.dart';
import '../../widgets/home/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                
                // Navigator.pop(context);
                // AppLoading.show(context);
                // // จำลอง: ปิด loading หลัง 2 วินาที
                // Future.delayed(const Duration(seconds: 2), () {
                //   AppLoading.hide();
                // });
              },
            ),
            ListTile(
              title: const Text('Create event'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    if (_navIndex == 1) {
      return NotificationScreen(notifications: _notifications);
    }

    if (_navIndex == 2) {
      return const MyAccountScreen();
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader(name: 'Cheewanon S.')),
        if (_events.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverToBoxAdapter(
              child: EventsSectionHeader(count: _events.length),
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
