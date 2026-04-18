import 'package:flutter/material.dart';

import '../../../../core/services/api_config.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/guest_repository.dart';

class AllergiesSeeAllScreen extends StatefulWidget {
  final String eventId;
  const AllergiesSeeAllScreen({super.key, required this.eventId});

  @override
  State<AllergiesSeeAllScreen> createState() => _AllergiesSeeAllScreenState();
}

class _AllergiesSeeAllScreenState extends State<AllergiesSeeAllScreen> {
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
      final filtered = guests
          .where((g) => (g['allergies'] as String?)?.isNotEmpty == true)
          .toList();
      if (mounted) setState(() { _guests = filtered; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Allergies',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _guests.isEmpty
              ? const Center(child: Text('No allergies reported'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _guests.length,
                  itemBuilder: (context, index) {
                    final guest = _guests[index];
                    final user = guest['user'] as Map<String, dynamic>? ?? {};
                    final name = user['fullName'] ?? 'Unknown';
                    final avatar = user['avatarUrl'] ?? '';
                    final allergies = guest['allergies'] as String;
                    final resolvedAvatar = ApiConfig.fullImageUrl(avatar);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: resolvedAvatar != null ? NetworkImage(resolvedAvatar) : null,
                              child: resolvedAvatar == null
                                  ? const Icon(Icons.person, size: 20, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(allergies, style: const TextStyle(fontSize: 13, color: Colors.red)),
                                ],
                              ),
                            ),
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
