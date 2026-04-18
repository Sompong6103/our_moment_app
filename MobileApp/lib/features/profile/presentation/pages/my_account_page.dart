import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/profile_model.dart';
import '../widgets/profile_menu_tile.dart';
import 'change_password_page.dart';
import 'my_event_page.dart';
import 'personal_info_page.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final _profileRepo = ProfileRepository();
  final _authRepo = AuthRepository();

  ProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepo.getProfile();
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _authRepo.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = _profile;

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
                AppAvatar(imageUrl: profile?.avatarUrl, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.email ?? '',
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
            onTap: () async {
              if (profile == null) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PersonalInfoPage(profile: profile),
                ),
              );
              _loadProfile();
            },
          ),
          Divider(color: AppColors.border, height: 1),
          ProfileMenuTile(
            icon: Icons.key_outlined,
            title: 'Change Password',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordPage()),
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
                  builder: (_) => const MyEventPage(),
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
            onTap: _logout,
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
