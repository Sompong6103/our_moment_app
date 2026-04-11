import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 90,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.buttonGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
            ),
          ),
        ),
        title: const Text("Agenda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ส่วนหัวข้ออธิบาย
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "You can choose to enable notifications before the schedule begins.",
              style: TextStyle(color: AppColors.textDark, fontSize: 14),
            ),
          ),

          // 2. รายการ Agenda พร้อม Timeline
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