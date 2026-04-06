import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/live_gallary.dart';

class EventFeatureGrid extends StatelessWidget {
  const EventFeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.assignment_outlined,
                iconBgColor: const Color(0xFFF4F1FF),
                iconColor: AppColors.primary,
                title: 'Agenda',
                subtitle: 'Event Schedule',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.photo_library_outlined,
                iconBgColor: const Color(0xFFF0EBFF),
                iconColor: AppColors.primary,
                title: 'Live Gallery',
                subtitle: 'Real-time photos',
                onTap: () {
                  // Navigate to live gallery screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveGalleryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.chat_bubble_outline,
                iconBgColor: const Color(0xFFFFF4EA),
                iconColor: const Color(0xFFC9A96E),
                title: 'Wish Wall',
                subtitle: 'Guest wishes',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.location_on_outlined,
                iconBgColor: const Color(0xFFE5F8EF),
                iconColor: const Color(0xFF4CAF50),
                title: 'Event Map',
                subtitle: 'Find your way',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
