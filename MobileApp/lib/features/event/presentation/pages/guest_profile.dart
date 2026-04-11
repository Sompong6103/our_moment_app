import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GuestProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String imageUrl;

  const GuestProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.imageUrl,
  });

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
        title: const Text('Guests Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วน Header Profile
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 35, backgroundImage: NetworkImage(imageUrl)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Column(
                    children: [
                      Icon(Icons.location_on_outlined, color: Color(0xFF70C7B7)),
                      Text('In event', style: TextStyle(color: Color(0xFF70C7B7), fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // ฟิลด์ข้อมูลต่างๆ
            _buildInfoField('Join event date', '27-Feb-2026'),
            _buildInfoField('Check in time', '28-Feb-2026 | 5:19 PM'),
            _buildInfoField(
              'Wishes', 
              '“May your love grow stronger each passing year. You two truly bring out the best in each other.”',
              isMultiline: true
            ),
          ],
        ),
      ),
    );
  }

  // Widget ช่วยสร้างช่องแสดงข้อมูล
  Widget _buildInfoField(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget สำหรับแถบรายชื่อในหน้าแรก
