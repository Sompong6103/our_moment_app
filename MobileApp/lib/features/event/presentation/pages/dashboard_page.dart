import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../../../core/widgets/guest_card.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/guest_repository.dart';
import '../../domain/models/event_model.dart';
import 'analytics_page.dart';
import 'edit_event_page.dart';
import 'guest_profile.dart';
import 'guest_see_all.dart';
import 'live_gallery.dart';

class DashboardPage extends StatefulWidget {
  final EventModel event;

  const DashboardPage({super.key, required this.event});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _sharePhotos = false;
  final _guestRepo = GuestRepository();
  final _eventRepo = EventRepository();

  late EventModel _event;
  List<Map<String, dynamic>> _guests = [];
  int _registeredCount = 0;
  int _checkedInCount = 0;
  int _wishCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _sharePhotos = _event.acceptPhotos;
    _loadData();
  }

  Future<void> _refreshEvent() async {
    try {
      final updated = await _eventRepo.getById(_event.id);
      if (mounted) {
        setState(() {
          _event = updated;
          _sharePhotos = updated.acceptPhotos;
        });
        _loadData();
      }
    } catch (_) {}
  }

  void _showAnnouncementSheet() {
    final messageController = TextEditingController();
    String target = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Send Announcement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type your announcement message...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFFF6F6F8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Send to', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => target = 'all'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: target == 'all' ? AppColors.primary : const Color(0xFFF6F6F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'All Guests',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: target == 'all' ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => target = 'checked_in'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: target == 'checked_in' ? AppColors.primary : const Color(0xFFF6F6F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Checked-in Only',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: target == 'checked_in' ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final msg = messageController.text.trim();
                      if (msg.isEmpty) return;
                      Navigator.pop(ctx);
                      try {
                        final result = await _eventRepo.announce(
                          _event.id,
                          title: 'Announcement',
                          message: msg,
                          target: target,
                        );
                        if (mounted) {
                          final count = result['recipientCount'] ?? 0;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Announcement sent to $count guest${count == 1 ? '' : 's'}')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to send: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Send Announcement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _guestRepo.list(_event.id),
        _eventRepo.getAnalytics(_event.id).catchError((_) => <String, dynamic>{}),
      ]);

      final guests = results[0] as List<Map<String, dynamic>>;
      final analytics = results[1] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _guests = guests;
          _registeredCount = analytics['registeredCount'] ?? guests.length;
          _checkedInCount = analytics['checkedInCount'] ?? 0;
          _wishCount = analytics['wishCount'] ?? 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _joinCode => _event.joinCode ?? 'N/A';

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                ),
                title: const Text('Edit Event', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Edit event details', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                onTap: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => EditEventPage(event: _event)),
                  );
                  if (updated == true) _refreshEvent();
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                ),
                title: const Text('Delete Event', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                subtitle: Text('Permanently remove this event', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteEvent();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${_event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _eventRepo.delete(_event.id);
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted'), backgroundColor: AppColors.primary),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete event'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _copyJoinCode() {
    Clipboard.setData(ClipboardData(text: _joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Join code copied'), backgroundColor: AppColors.primary, duration: Duration(seconds: 1)),
    );
  }

  void _showQrCode() {
    final qrKey = GlobalKey();

    Future<void> downloadQr() async {
      try {
        final boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        await Gal.putImageBytes(bytes, name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code saved to gallery'), backgroundColor: AppColors.primary),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save QR Code'), backgroundColor: Colors.red),
          );
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Text('Event QR Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Scan to join ${_event.title}', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: QrImageView(
                    data: 'ourmoment://join?code=$_joinCode&event=${_event.title}',
                    version: QrVersions.auto, size: 220,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('JOIN CODE: $_joinCode', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: downloadQr,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () async {
                          try {
                            final boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                            final image = await boundary.toImage(pixelRatio: 3.0);
                            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                            final bytes = byteData!.buffer.asUint8List();
                            final dir = await getTemporaryDirectory();
                            final file = File('${dir.path}/qr_code.png');
                            await file.writeAsBytes(bytes);
                            await SharePlus.instance.share(
                              ShareParams(files: [XFile(file.path)], text: 'Join ${_event.title} with code $_joinCode!'),
                            );
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppDetailScaffold(
        title: 'Dashboard',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppDetailScaffold(
      title: 'Dashboard',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: InkWell(
            onTap: _showMoreMenu,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.buttonGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.more_vert, size: 22, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover Image ──
            if (_event.coverImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _event.coverImageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _event.coverColor,
                      _event.coverColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.celebration, size: 48, color: Colors.white.withValues(alpha: 0.5)),
                ),
              ),
            const SizedBox(height: 16),

            // ── Event Title & Join Code ──
            Text(
              _event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            if (_event.date.isNotEmpty)
              Text(
                _event.date,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _copyJoinCode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'JOIN CODE: $_joinCode',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.copy_rounded, size: 14, color: AppColors.primary.withValues(alpha: 0.6)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Stats Row ──
            Row(
              children: [
                Expanded(child: _StatTile(value: '$_registeredCount', label: 'Registered', icon: Icons.person_add_alt_1_rounded, color: const Color(0xFF6C63FF))),
                const SizedBox(width: 10),
                Expanded(child: _StatTile(value: '$_checkedInCount', label: 'Checked In', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF4CAF50))),
                const SizedBox(width: 10),
                Expanded(child: _StatTile(value: '$_wishCount', label: 'Wishes', icon: Icons.favorite_border_rounded, color: const Color(0xFFE91E63))),
              ],
            ),

            const SizedBox(height: 28),

            // ── Quick Actions ──
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.people_outline,
                    title: 'Guests',
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuestsScreen(eventId: _event.id))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.photo_library_outlined,
                    title: 'Photos',
                    color: const Color(0xFFFF9800),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveGalleryScreen(isHost: true, eventId: _event.id, acceptPhotos: _event.acceptPhotos))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.qr_code_rounded,
                    title: 'QR Code',
                    color: const Color(0xFF2196F3),
                    onTap: _showQrCode,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Analytics',
                    color: const Color(0xFFE91E63),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsPage(event: _event))),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Host Setting ──
            const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.photo_camera_outlined, size: 18, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Share photos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text('Accept photos from guests', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      AppSwitch(
                        value: _sharePhotos,
                        onChanged: (v) => setState(() => _sharePhotos = v),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  InkWell(
                    onTap: () => _showAnnouncementSheet(),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.campaign_outlined, size: 18, color: Color(0xFFFF9800)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Announcement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Text('Send notification to everyone', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Recent Guests ──
            if (_guests.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Guests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuestsScreen(eventId: _event.id))),
                    child: const Text('See all', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(_guests.length > 5 ? 5 : _guests.length, (index) {
                final guest = _guests[index];
                final user = guest['user'] as Map<String, dynamic>? ?? {};
                final name = user['fullName'] ?? 'Unknown';
                final email = user['email'] ?? '';
                final avatar = user['avatarUrl'] ?? '';
                final checkedIn = guest['status'] == 'checked_in';
                return GuestCard(
                  name: name,
                  time: '',
                  avatarUrl: avatar,
                  inEvent: checkedIn,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GuestProfileScreen(
                        eventId: _event.id,
                        guestId: guest['id'] ?? '',
                        name: name,
                        email: email,
                        imageUrl: avatar,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Stat Tile ──
class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatTile({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Quick Action Card ──
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

