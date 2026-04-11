import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/segment_button.dart';

class LiveGalleryScreen extends StatefulWidget {
  const LiveGalleryScreen({super.key});

  @override
  State<LiveGalleryScreen> createState() => _LiveGalleryScreenState();
}

class _LiveGalleryScreenState extends State<LiveGalleryScreen> {
  // เก็บสถานะว่าเลือกหมวดหมู่ไหนอยู่
  int selectedIndex = 0;
  final List<String> categories = ["All", "Couple", "Guests", "582 PHOTOS"]; // หมวดหมู่สุดท้ายเป็นตัวอย่างจำนวนรูปจากฐานข้อมูล

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Live Gallery',
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      child: Column(
        children: [
          // --- ส่วนของ Segmented Control ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.segmentBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: List.generate(categories.length, (index) {
                  return Expanded(
                    child: SegmentButton(
                      title: categories[index],
                      selected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          // --- ส่วนของ Grid รูปภาพ ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 คอลัมน์ตามรูป
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1, // รูปทรงจัตุรัส
              ),
              itemCount: 8, // จำนวนรูปตัวอย่าง
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://picsum.photos/seed/${index + 50}/400', // รูปจำลอง
                    fit: BoxFit.cover,
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