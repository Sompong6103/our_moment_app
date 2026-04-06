import 'package:flutter/material.dart';
import '../../../../core/widgets/app_password_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Change Password',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppPasswordField(
              label: 'Old Password',
              hintText: 'Enter old password',
            ),
            const SizedBox(height: 16),
            const AppPasswordField(
              label: 'New Password',
              hintText: 'Enter new password',
            ),
            const SizedBox(height: 16),
            const AppPasswordField(
              label: 'Confirm New Password',
              hintText: 'Re-enter new password',
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
