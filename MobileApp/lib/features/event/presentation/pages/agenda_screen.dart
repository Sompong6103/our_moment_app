import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // สำหรับ CupertinoSwitch ที่ดูสวยงาม
import '../../../../core/theme/app_colors.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // ข้อมูลจำลองสำหรับ Agenda
  final List<Map<String, dynamic>> agendaItems = List.generate(4, (index) => {
    "time": "Sat, 25 Oct 2025 | 18:00",
    "title": "Buddhist ceremony",
    "desc": "Offering food to nine monks.",
    "location": "ห้อง Grand 2",
    "isNotify": false,
  }); //ต้องดึงข้อมูลจริงจาก backend มาแทน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("Agenda", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: agendaItems.length,
              itemBuilder: (context, index) {
                return _buildTimelineItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับสร้างแต่ละแถวของ Timeline
  Widget _buildTimelineItem(int index) {
    bool isLast = index == agendaItems.length - 1;

    return IntrinsicHeight(
      child: Row(
        children: [
          // ส่วนที่ 1: เส้น Timeline และจุดวงกลม
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary, // สีม่วงตามดีไซน์
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),

          // ส่วนที่ 2: การ์ดเนื้อหา
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary), // icon วันที่และเวลา
                            const SizedBox(width: 5),
                            Text(
                              agendaItems[index]['time'], // แสดงวันที่และเวลา
                              style: const TextStyle(color: AppColors.primary, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          agendaItems[index]['title'], // แสดงชื่อกิจกรรม
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          agendaItems[index]['desc'], // แสดงรายละเอียดกิจกรรม
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Container( //container สำหรับแสดงข้อความสถานที่จัดกิจกรรม
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.iconInactive),
                              const SizedBox(width: 4),
                              Text(
                                agendaItems[index]['location'], // แสดงสถานที่จัดกิจกรรม
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // ปุ่ม Toggle แจ้งเตือน
                  CupertinoSwitch(
                    // ignore: deprecated_member_use
                    activeColor: AppColors.primary,
                    value: agendaItems[index]['isNotify'],
                    onChanged: (val) {
                      setState(() {
                        agendaItems[index]['isNotify'] = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}