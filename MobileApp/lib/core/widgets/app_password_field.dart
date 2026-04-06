import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text_field.dart';

/// A password text field with built-in visibility toggle.
///
/// Consolidates the repeated password-obscure-toggle pattern used across
/// Login, Create Account, and Change Password screens.
class AppPasswordField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const AppPasswordField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      obscureText: _obscured,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textDark,
          size: 20,
        ),
      ),
    );
  }
}
