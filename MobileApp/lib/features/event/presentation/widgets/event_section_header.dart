import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EventSectionHeader extends StatelessWidget {
  final int count;

  const EventSectionHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Events',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAE7FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count Total',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
