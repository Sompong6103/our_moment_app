import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../data/sample_events.dart';
import '../../data/sample_profile.dart';
import '../../routes/app_routes.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/profile/profile_menu_tile.dart';
import 'change_password_screen.dart';
import 'my_event_screen.dart';
import 'personal_info_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ProfileAvatar(imageUrl: sampleProfile.avatarUrl, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sampleProfile.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sampleProfile.email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(125, 29, 29, 29),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ProfileMenuTile(
            icon: Icons.account_circle_outlined,
            title: 'Personal Info',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const PersonalInfoScreen(profile: sampleProfile),
                ),
              );
            },
          ),
          Divider(color: AppColors.border, height: 1),
          ProfileMenuTile(
            icon: Icons.key_outlined,
            title: 'Change Password',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          Divider(color: AppColors.border, height: 1),
          ProfileMenuTile(
            icon: Icons.auto_awesome_outlined,
            title: 'My Event',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyEventScreen(
                    hostedEvents: sampleEvents.take(1).toList(),
                    pastEvents: sampleEvents.skip(1).toList(),
                  ),
                ),
              );
            },
          ),
          Divider(color: AppColors.border, height: 1),
          ProfileMenuTile(
            icon: Icons.logout,
            iconColor: AppColors.danger,
            textColor: AppColors.danger,
            title: 'Logout',
            onTap: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
            },
          ),
          const Spacer(),
          Center(
            child: Text(
              'Version 1.0.0 (beta)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
