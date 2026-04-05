import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoundIconButton(Icons.arrow_back_ios_new, AppColors.iconInactive),
                  const Text(
                    "Detail Event",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildRoundIconButton(Icons.grid_view_rounded, const Color(0xFFE0E0FF), iconColor: AppColors.iconInactive),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Main Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  'https://images.unsplash.com/photo-1511795409834-ef04bbd61622', //รูปตัวอย่าง
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // 3. Event Titles & Icons
              const Text(
                "Aom & Ton's Wedding (host name)",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.location_on_outlined, "Thailand, Bangkok, Baiyok tower (location data)"),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.calendar_month_outlined, "Sat, 25 Oct 2025 | 18:00 - 22:00 (time data)"),
              const SizedBox(height: 15),

              // 4. Joined People Avatars
              Row(
                children: [
                  _buildAvatarStack(),
                  const SizedBox(width: 10),
                  const Text(
                    "15 People are joined (guest data)",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 5. Grid Menu (2x2)
              Row(
                children: [
                  Expanded(child: _buildMenuCard("Agenda", "Event Schedule", Icons.calendar_today, const Color(0xFFDED9FF))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildMenuCard("Live Gallery", "Real-time photos", Icons.image_outlined, const Color(0xFFFFE1F1))),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildMenuCard("Wish Wall", "Guest wishes", Icons.chat_bubble_outline, const Color(0xFFFBF1E6))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildMenuCard("Event Map", "Find your way", Icons.location_on_outlined, const Color(0xFFE1F9E9))),
                ],
              ),
              const SizedBox(height: 30),

              // 6. Detail Section
              const Text("Detail", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "A casual yet insightful gathering for designers, creators, and digital thinkers to connect, share stories, and explore the future of design. Join us for a day filled with inspiring talks, interactive sessions, and networking with local talents from the creative industry.",
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 30),

              // 7. Theme Section
              const Text("Theme", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Color(0xFF000080), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 15),
                  const Text("Blue Navy", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper สำหรับปุ่มใน Header
  Widget _buildRoundIconButton(IconData icon, Color bgColor, {Color iconColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }

  // Helper สำหรับแถวข้อมูล (Location, Date)
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple[300]),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }

  // Helper สำหรับ Card เมนู
  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: Colors.black.withOpacity(0.6)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Helper สำหรับ Stack รูปคนเข้าร่วม
  Widget _buildAvatarStack() {
    return SizedBox(
      width: 100,
      height: 30,
      child: Stack(
        children: List.generate(4, (index) {
          if (index == 3) { // แสดง "+10" เมื่อเกิน 3 คน อาจปรับให้แสดงจำนวนจริงจากข้อมูลได้
            return Positioned(
              left: index * 20,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey[200],
                child: const Text("10+", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            );
          }
          return Positioned(
            left: index * 20,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blue[100 * (index + 1)],
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150'), // avatar ตัวอย่าง
            ),
          );
        }),
      ),
    );
  }
}