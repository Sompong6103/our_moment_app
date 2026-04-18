import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/guest_card.dart';
import '../../../../core/widgets/segment_button.dart';
import '../../data/repositories/guest_repository.dart';
import 'guest_profile.dart';

class GuestsScreen extends StatefulWidget {
  final String eventId;
  const GuestsScreen({super.key, required this.eventId});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['All', 'In event'];
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final _guestRepo = GuestRepository();
  List<Map<String, dynamic>> _guests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    try {
      final guests = await _guestRepo.list(widget.eventId);
      if (mounted) setState(() { _guests = guests; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredGuests {
    List<Map<String, dynamic>> list = _guests;
    if (_selectedIndex == 1) {
      list = list.where((g) => g['status'] == 'checked_in').toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((g) {
        final user = g['user'] as Map<String, dynamic>?;
        final name = (user?['fullName'] ?? '') as String;
        return name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _searchQuery = value),
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
                children: [
                  ...List.generate(_tabs.length, (i) {
                    return Expanded(
                      child: SegmentButton(
                        title: _tabs[i],
                        selected: _selectedIndex == i,
                        onTap: () => setState(() => _selectedIndex = i),
                      ),
                    );
                  }),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_filteredGuests.length} PEOPLE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guest List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: guests.length,
              itemBuilder: (context, index) {
                final guest = guests[index];
                final user = guest['user'] as Map<String, dynamic>? ?? {};
                final name = user['fullName'] ?? 'Unknown';
                final email = user['email'] ?? '';
                final avatar = user['avatarUrl'] ?? '';
                final inEvent = guest['status'] == 'checked_in';

                String joinTime = '';
                if (guest['joinedAt'] != null) {
                  final dt = DateTime.tryParse(guest['joinedAt']);
                  if (dt != null) {
                    final diff = DateTime.now().difference(dt);
                    if (diff.inMinutes < 1) {
                      joinTime = 'Joined just now';
                    } else if (diff.inHours < 1) {
                      joinTime = 'Joined ${diff.inMinutes} minutes ago.';
                    } else {
                      joinTime = 'Joined ${diff.inHours} hours ago.';
                    }
                  }
                }

                return GuestCard(
                  name: name,
                  time: joinTime,
                  avatarUrl: avatar,
                  inEvent: inEvent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GuestProfileScreen(
                        eventId: widget.eventId,
                        guestId: user['id'] ?? '',
                        name: name,
                        email: email,
                        imageUrl: avatar,
                        isHost: true,
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