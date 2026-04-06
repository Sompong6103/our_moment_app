import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WishWallScreen extends StatefulWidget {
  const WishWallScreen({super.key});

  @override
  State<WishWallScreen> createState() => _WishWallScreenState();
}

class _WishWallScreenState extends State<WishWallScreen> {
  // 1. ตัวแปรเก็บรายการคำอวยพร (เริ่มต้นเป็นลิสต์ว่างแสดงหน้า Empty wish wall)
  final List<Map<String, String>> _wishes = [];

  // 2. Controller สำหรับรับค่าจากช่องพิมพ์
  final TextEditingController _textController = TextEditingController();

  // ฟังก์ชันสำหรับเพิ่มคำอวยพร
  void _sendWish() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _wishes.insert(0, {
          "name": "Guest User", 
          "wish": "“${_textController.text}”",
          "time": "Just now",
          "avatar": "https://i.pravatar.cc/150?u=guest" 
        });
        _textController.clear(); // ล้างช่องกรอกข้อความหลังส่งคำอวยพร
        // อาจต้องเพิ่มการบันทึกคำอวยพรลงฐานข้อมูลที่นี่

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Guest Wishes Wall",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // แสดงเนื้อหา
          Expanded(
            child: _wishes.isEmpty 
              ? _buildEmptyState() // ไม่มีคำอวยพร 
              : _buildWishList(),   // มีคำอวยพร 
          ),

          // ช่องกรอกข้อความด้านล่าง
          _buildInputArea(),
        ],
      ),
    );
  }

  // --- UI สำหรับกรณีไม่มีข้อมูล ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/empty_wishwall.png', // รูปแทนตัวอย่าง
                height: 200,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No one has written a well-wishes yet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "watch this space for offer, update, and more",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI สำหรับกรณีมีรายการคำอวยพร ---
  Widget _buildWishList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _wishes.length,
      itemBuilder: (context, index) {
        final item = _wishes[index]; // ดึงข้อมูลคำอวยพรแต่ละรายการ
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['wish']!, // แสดงข้อความอวยพร
                style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(radius: 14, backgroundImage: NetworkImage(item['avatar']!)),
                  const SizedBox(width: 10),
                  Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  Text(item['time']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- UI ส่วนแถบรับข้อความด้านล่าง ---
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Aa",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.inputHint),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.indigo),
              onPressed: _sendWish,
            ),
          ],
        ),
      ),
    );
  }
}