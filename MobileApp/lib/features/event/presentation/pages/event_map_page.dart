import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class EventMapScreen extends StatelessWidget {
  const EventMapScreen({super.key});

  // ฟังก์ชันสำหรับเปิด Google Maps (ใส่พิกัดที่ต้องการ)
  Future<void> _launchMap() async {
    const String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=Varee+International+School";
    final Uri url = Uri.parse(googleMapsUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Event Map',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ส่วนแสดงรูปภาพแผนที่
            Container(
              height: 400, // ปรับความสูงตามความเหมาะสม
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://placeholder.com/map_image_url', // เปลี่ยนเป็น URL รูปแผนที่
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.scaffoldBackground,
                      child: const Icon(Icons.map, size: 100, color: AppColors.iconInactive),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            // ปุ่ม Open Maps
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _launchMap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // สีม่วงตามรูป
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Open Maps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}