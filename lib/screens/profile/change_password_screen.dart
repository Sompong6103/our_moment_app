import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/common/app_primary_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/profile/profile_detail_scaffold.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: 'Change Password',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Old Password',
              hintText: 'Enter old password',
              obscureText: _hideOldPassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _hideOldPassword = !_hideOldPassword);
                },
                icon: Icon(
                  _hideOldPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textDark,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'New Password',
              hintText: 'Enter new password',
              obscureText: _hideNewPassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _hideNewPassword = !_hideNewPassword);
                },
                icon: Icon(
                  _hideNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textDark,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirm New Password',
              hintText: 'Re-enter new password',
              obscureText: _hideConfirmPassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _hideConfirmPassword = !_hideConfirmPassword);
                },
                icon: Icon(
                  _hideConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textDark,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 26),
            AppPrimaryButton(
              label: 'Update Password',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated (mock).'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
