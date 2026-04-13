import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/guest_repository.dart';
import '../../domain/models/event_model.dart';
import '../widgets/event_detail_header.dart';
import '../widgets/event_feature_grid.dart';
import 'dashboard_page.dart';
import 'guest_details_page.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;
  final bool showJoinButton;

  const EventDetailPage({super.key, required this.event, this.showJoinButton = false});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _checkedIn = false;
  late bool _showJoinButton;
  late bool _joined;
  List<String> _attendeeAvatarUrls = const [];
  final _guestRepo = GuestRepository();

  @override
  void initState() {
    super.initState();
    _showJoinButton = widget.showJoinButton;
    _joined = widget.event.isJoined;
    _loadAttendeeAvatars();
    _loadGuestStatus();
  }

  Future<void> _loadGuestStatus() async {
    if (widget.event.isHost || !_joined) return;
    try {
      final status = await _guestRepo.getMyStatus(widget.event.id);
      if (mounted && status['status'] == 'checked_in') {
        setState(() => _checkedIn = true);
      }
    } catch (_) {}
  }

  Future<void> _loadAttendeeAvatars() async {
    try {
      final guests = await _guestRepo.list(widget.event.id);
      final urls = guests
          .map((g) => (g['user'] as Map<String, dynamic>?)?['avatarUrl']?.toString() ?? '')
          .where((u) => u.isNotEmpty)
          .map((u) => u.startsWith('http') ? u : '${ApiConfig.uploadsUrl}/$u')
          .take(3)
          .toList();

      if (mounted) {
        setState(() => _attendeeAvatarUrls = urls);
      }
    } catch (_) {
      // Keep fallback placeholder avatars when API is unavailable.
    }
  }

  bool get _canCheckIn {
    if (widget.event.isHost || !_joined) return false;
    return widget.event.canCheckIn;
  }

  bool get _showPastStatus {
    if (widget.event.isHost || !_joined) return false;
    return widget.event.isEventOver;
  }

  void _handleCheckIn() async {
    try {
      await _guestRepo.checkIn(widget.event.id);
      if (mounted) {
        setState(() => _checkedIn = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checked in to ${widget.event.title} successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openGuestDetails() async {
    final joined = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GuestDetailsPage(event: widget.event),
      ),
    );

    if (joined == true && mounted) {
      // Pop all pages back to Home, then push EventDetailPage
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventDetailPage(event: widget.event),
        ),
      );
    }
  }

  Future<void> _leaveEvent() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Leave Event'),
        content: Text('Are you sure you want to leave "${widget.event.title}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Leave'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _guestRepo.leave(widget.event.id);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return AppDetailScaffold(
      title: 'Detail Event',
      actions: event.isHost
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardPage(event: event),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.dashboard_outlined,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ]
          : _joined
              ? [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textPrimary, size: 22),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'leave') _leaveEvent();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'leave',
                        height: 40,
                        child: Text('Leave Event', style: TextStyle(color: Colors.red, fontSize: 14)),
                      ),
                    ],
                  ),
                ]
              : null,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventDetailHeader(event: event, attendeeAvatarUrls: _attendeeAvatarUrls),
                  const SizedBox(height: 20),

                  EventFeatureGrid(isHost: event.isHost, eventId: event.id, event: event),
                  const SizedBox(height: 24),

                  const Text(
                    'Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: event.themeColor ?? AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        event.themeName ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Join button (register to attend) ──
          if (_showJoinButton)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _openGuestDetails,
                    icon: const Icon(Icons.how_to_reg_outlined, size: 20),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    label: const Text('Join Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          // ── Check-in button (joined guest, event day, before end) ──
          if (!_showJoinButton && _canCheckIn)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _checkedIn ? null : _handleCheckIn,
                    icon: Icon(_checkedIn ? Icons.check_circle : Icons.login_rounded, size: 20),
                    label: Text(
                      _checkedIn ? 'Checked in' : 'Check in to Event',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _checkedIn ? Colors.green : AppColors.primary,
                      disabledBackgroundColor: Colors.green,
                      disabledForegroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
            ),
          // ── Past event: show attendance status ──
          if (!_showJoinButton && _showPastStatus)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _checkedIn ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _checkedIn ? Colors.green : Colors.red,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _checkedIn ? Icons.check_circle : Icons.cancel_outlined,
                        size: 20,
                        color: _checkedIn ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _checkedIn ? 'You attended this event' : 'You did not attend this event',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _checkedIn ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
