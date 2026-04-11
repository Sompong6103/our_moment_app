import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../domain/models/agenda_item.dart';
import '../widgets/agenda_timeline.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // ข้อมูลจำลองสำหรับ Agenda
  final List<AgendaItem> agendaItems = List.generate(4, (index) => const AgendaItem(
    dateTime: "Sat, 25 Oct 2025 | 18:00",
    title: "Buddhist ceremony",
    description: "Offering food to nine monks.",
    location: "ห้อง Grand 2",
  )); //ต้องดึงข้อมูลจริงจาก backend มาแทน

  final List<bool> _notifyStates = List.generate(4, (_) => false);

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Agenda',
      child: Column(
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
                  return CupertinoSwitch(
                    // ignore: deprecated_member_use
                    activeColor: AppColors.primary,
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