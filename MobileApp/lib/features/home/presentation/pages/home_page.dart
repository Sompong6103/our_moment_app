import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../event/data/repositories/event_repository.dart';
import '../../../event/domain/models/event_model.dart';
import '../../../event/presentation/pages/create_event_page.dart';
import '../../../event/presentation/pages/join_event_page.dart';
import '../../../event/presentation/widgets/event_card.dart';
import '../../../event/presentation/widgets/event_section_header.dart';
import '../../../notification/data/repositories/notification_repository.dart';
import '../../../notification/domain/models/notification_model.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../../profile/presentation/pages/my_account_page.dart';
import '../widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  List<EventModel> _events = [];
  List<NotificationModel> _notifications = [];
  String _userName = '';
  String? _avatarUrl;
  bool _loading = true;

  final _eventRepo = EventRepository();
  final _notifRepo = NotificationRepository();
  final _profileRepo = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _eventRepo.listMyEvents(),
        _notifRepo.list(),
        _profileRepo.getProfile(),
      ]);

      final eventsMap = results[0] as Map<String, List<EventModel>>;
      final notifications = results[1] as List<NotificationModel>;
      final profile = results[2] as ProfileModel;

      if (mounted) {
        setState(() {
          _events = [...eventsMap['organized'] ?? [], ...eventsMap['joined'] ?? []];
          _notifications = notifications;
          _userName = profile.fullName;
          _avatarUrl = profile.avatarUrl;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

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

    return Column(
      children: [
        HomeHeader(name: _userName, avatarUrl: _avatarUrl),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_events.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: EventSectionHeader(count: _events.length),
          ),
        if (!_loading && _events.isEmpty)
          const Expanded(
            child: EmptyState(
              title: 'You don\'t have a ceremony yet.',
              subtitle: 'You can view the ceremonies you have attended here.',
              imageAsset: 'assets/images/empty_events.png',
            ),
          )
        else if (!_loading)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: _events.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EventCard(event: _events[i]),
                ),
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
