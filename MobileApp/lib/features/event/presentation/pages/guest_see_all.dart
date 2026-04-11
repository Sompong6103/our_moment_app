import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/guest_card.dart';
import '../../../../core/widgets/segment_button.dart';
import 'guest_profile.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['All', 'In event', '582 PEOPLE'];

  final List<Map<String, dynamic>> _guests = [
    {'name': 'Krittanai Ngampanja', 'email': 'krittanai@gmail.com', 'time': 'Joined 0 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k1', 'inEvent': false},
    {'name': 'Cheewanon Srisawadwattana', 'email': 'sn.cheewa@gmail.com', 'time': 'Joined 9 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k2', 'inEvent': true},
    {'name': 'Cameron Williamson', 'email': 'cameron@gmail.com', 'time': 'Joined 10 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k3', 'inEvent': false},
    {'name': 'Darrell Steward', 'email': 'darrell@gmail.com', 'time': 'Joined 10 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k4', 'inEvent': false},
    {'name': 'Ralph Edwards', 'email': 'ralph@gmail.com', 'time': 'Joined 10 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k5', 'inEvent': false},
    {'name': 'Darlene Robertson', 'email': 'darlene@gmail.com', 'time': 'Joined 30 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k6', 'inEvent': false},
    {'name': 'Guy Hawkins', 'email': 'guy@gmail.com', 'time': 'Joined 40 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k7', 'inEvent': false},
    {'name': 'Brooklyn Simmons', 'email': 'brooklyn@gmail.com', 'time': 'Joined 58 minutes ago.', 'avatar': 'https://i.pravatar.cc/150?u=k8', 'inEvent': false},
  ];

  List<Map<String, dynamic>> get _filteredGuests {
    if (_selectedIndex == 1) return _guests.where((g) => g['inEvent'] == true).toList();
    return _guests;
  }

  @override
  Widget build(BuildContext context) {
    final guests = _filteredGuests;

    return AppDetailScaffold(
      title: 'Guests',
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.primary)),
              ),
            ),
          ),

          // Segment Tabs
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.segmentBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  return Expanded(
                    child: SegmentButton(
                      title: _tabs[i],
                      selected: _selectedIndex == i,
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Guest List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: guests.length,
              itemBuilder: (context, index) {
                final guest = guests[index];
                return GuestCard(
                  name: guest['name'],
                  time: guest['time'],
                  avatarUrl: guest['avatar'],
                  inEvent: guest['inEvent'],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GuestProfileScreen(
                        name: guest['name'],
                        email: guest['email'],
                        imageUrl: guest['avatar'],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}