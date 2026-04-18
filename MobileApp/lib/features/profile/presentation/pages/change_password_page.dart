import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/widgets/app_password_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/profile_repository.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _profileRepo = ProfileRepository();
  bool _saving = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_saving) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _profileRepo.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully.'), behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Change Password',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPasswordField(
              label: 'Old Password',
              hintText: 'Enter old password',
              controller: _oldPasswordController,
            ),
            const SizedBox(height: 16),
            AppPasswordField(
              label: 'New Password',
              hintText: 'Enter new password',
              controller: _newPasswordController,
            ),
            const SizedBox(height: 16),
            AppPasswordField(
              label: 'Confirm New Password',
              hintText: 'Re-enter new password',
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 26),
            AppPrimaryButton(
              label: _saving ? 'Updating...' : 'Update Password',
              onPressed: _saving ? null : _updatePassword,
            ),
          ],
        ),
      ),
    );
  }
}
