import 'package:flutter/material.dart';

import '../services/api_config.dart';
import '../theme/app_colors.dart';

class GuestCard extends StatelessWidget {
  final String name;
  final String time;
  final String avatarUrl;
  final bool inEvent;
  final VoidCallback? onTap;

  const GuestCard({
    super.key,
    required this.name,
    required this.time,
    required this.avatarUrl,
    this.inEvent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: ApiConfig.fullImageUrl(avatarUrl) != null
                  ? NetworkImage(ApiConfig.fullImageUrl(avatarUrl)!)
                  : null,
              child: ApiConfig.fullImageUrl(avatarUrl) == null
                  ? const Icon(Icons.person, size: 22, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                ],
              ),
            ),
            if (inEvent)
              Column(
                children: [
                  Icon(Icons.person_pin, size: 22, color: AppColors.primary),
                  const SizedBox(height: 2),
                  const Text('In event', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
