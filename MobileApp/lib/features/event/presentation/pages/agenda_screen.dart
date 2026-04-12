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
  const AgendaScreen({super.key, required this.eventId});

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
      if (mounted) {
        setState(() {
          agendaItems = items;
          _notifyStates = List.generate(items.length, (_) => false);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
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
                trailingBuilder: (context, index) {
                  return AppSwitch(
                    value: _notifyStates[index],
                    onChanged: (val) {
                      setState(() {
                        _notifyStates[index] = val;
                      });
                    },
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