import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/agenda_item.dart';
import '../widgets/agenda_timeline.dart';

class AgendaScreen extends StatefulWidget {
  final String eventId;
  final bool isMember;
  const AgendaScreen({super.key, required this.eventId, this.isMember = false});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final _eventRepo = EventRepository();
  List<AgendaItem> agendaItems = [];
  List<bool> _notifyStates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAgenda();
  }

  Future<void> _loadAgenda() async {
    try {
      final items = await _eventRepo.getAgenda(widget.eventId);
      List<String> subscribedIds = [];
      if (widget.isMember) {
        try {
          subscribedIds = await _eventRepo.getMyReminders(widget.eventId);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          agendaItems = items;
          _notifyStates = items.map((item) => subscribedIds.contains(item.id)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Agenda load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleReminder(int index, bool value) async {
    final item = agendaItems[index];
    debugPrint('Toggle reminder: itemId=${item.id}, value=$value, eventId=${widget.eventId}');
    setState(() => _notifyStates[index] = value);
    try {
      if (value) {
        await _eventRepo.subscribeReminder(widget.eventId, item.id!);
      } else {
        await _eventRepo.unsubscribeReminder(widget.eventId, item.id!);
      }
      debugPrint('Toggle reminder success');
    } catch (e) {
      debugPrint('Toggle reminder error: $e');
      if (mounted) setState(() => _notifyStates[index] = !value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Agenda',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "You can choose to enable notifications before the schedule begins.",
              style: TextStyle(color: AppColors.textDark, fontSize: 14),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AgendaTimeline(
                items: agendaItems,
                trailingBuilder: !widget.isMember ? null : (context, index) {
                  final isPast = agendaItems[index].isPast;
                  return AppSwitch(
                    value: isPast ? false : _notifyStates[index],
                    onChanged: isPast ? null : (val) => _toggleReminder(index, val),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}