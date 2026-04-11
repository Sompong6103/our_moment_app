import 'package:flutter/material.dart';
import 'guest_profile.dart';
import '../../../../core/theme/app_colors.dart';


class GuestsScreen extends StatelessWidget {
  const GuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Guests', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              ),
            ),
          ),
          
          // รายชื่อ Guest
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                GuestTile(
                  name: 'Cheewanon Srisawadwattana',
                  email: 'sn.cheewa@gmail.com',
                  time: 'Joined 9 minutes ago.',
                  imageUrl: 'https://i.pravatar.cc/150?u=99',
                  isInEvent: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GuestProfileScreen(
                          name: 'Cheewanon Srisawadwattana',
                          email: 'sn.cheewa@gmail.com',
                          imageUrl: 'https://i.pravatar.cc/150?u=99',
                        ),
                      ),
                    );
                  },
                ),
                // เพิ่มรายการอื่นๆ ได้ที่นี่...
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GuestTile extends StatelessWidget {
  final String name;
  final String email;
  final String time;
  final String imageUrl;
  final bool isInEvent;
  final VoidCallback onTap;

  const GuestTile({
    super.key, 
    required this.name, 
    required this.email,
    required this.time, 
    required this.imageUrl, 
    required this.onTap,
    this.isInEvent = false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 25, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(color: Color(0xFFB0ACD9), fontSize: 12)),
                ],
              ),
            ),
            if (isInEvent)
              const Icon(Icons.location_on_outlined, color: Color(0xFF70C7B7), size: 20),
          ],
        ),
      ),
    );
  }
}