import 'package:flutter/material.dart';
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Guests',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
          ),

          // 2. Filter / Stats Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF675AC2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('All', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 15),
                  const Text('In event', style: TextStyle(color: Colors.grey)),
                  const Spacer(),
                  const Text(
                    '582 PEOPLE',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Guest List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                GuestTile(
                  name: 'Krittanai Ngampanja',
                  time: 'Joined 0 minutes ago.',
                  imageUrl: 'https://i.pravatar.cc/150?u=1',
                ),
                GuestTile(
                  name: 'Cheewanon Srisawadwattana',
                  time: 'Joined 9 minutes ago.',
                  imageUrl: 'https://i.pravatar.cc/150?u=2',
                  isInEvent: true,
                ),
                GuestTile(
                  name: 'Cameron Williamson',
                  time: 'Joined 10 minutes ago.',
                  imageUrl: 'https://i.pravatar.cc/150?u=3',
                ),
                GuestTile(
                  name: 'Darrell Steward',
                  time: 'Joined 10 minutes ago.',
                  imageUrl: 'https://i.pravatar.cc/150?u=4',
                ),
                GuestTile(
                  name: 'Ralph Edwards',
                  time: 'Joined 10 minutes ago.',
                  imageUrl: 'https://i.pravatar.cc/150?u=5',
                ),
                GuestTile(
                  name: 'Darlene Robertson',
                  time: 'Joined 30 minutes ago.',
                  imageUrl: 'https://i.pravatar.cc/150?u=6',
                ),
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
  final String time;
  final String imageUrl;
  final bool isInEvent;

  const GuestTile({
    super.key,
    required this.name,
    required this.time,
    required this.imageUrl,
    this.isInEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Color(0xFFB0ACD9), fontSize: 12),
                ),
              ],
            ),
          ),
          if (isInEvent)
            Column(
              children: const [
                Icon(Icons.location_on_outlined, color: Color(0xFF70C7B7), size: 20),
                Text(
                  'In event',
                  style: TextStyle(color: Color(0xFF70C7B7), fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}