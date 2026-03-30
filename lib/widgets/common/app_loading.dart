import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Global loading overlay ที่เรียกใช้ได้จากทุกหน้าผ่าน static method.
///
/// ```dart
/// AppLoading.show(context);                          // แสดง loading
/// AppLoading.show(context, message: 'กำลังบันทึก...'); // แสดงพร้อมข้อความ
/// AppLoading.hide();                                 // ปิด loading
/// ```
class AppLoading {
  AppLoading._();

  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// แสดง loading overlay ทับหน้าจอปัจจุบัน
  static void show(BuildContext context, {String? message}) {
    // ป้องกันเปิดซ้ำ
    if (_isShowing) return;

    final overlay = Overlay.of(context, rootOverlay: true);

    _overlayEntry = OverlayEntry(
      builder: (_) => _LoadingOverlay(message: message),
    );

    overlay.insert(_overlayEntry!);
    _isShowing = true;
  }

  /// ปิด loading overlay
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }

  /// ตรวจสอบว่า loading กำลังแสดงอยู่หรือไม่
  static bool get isShowing => _isShowing;
}

class _LoadingOverlay extends StatefulWidget {
  final String? message;

  const _LoadingOverlay({this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    });
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -12).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Transform.translate(
                        offset: Offset(0, _animations[i].value),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 20),
              Text(
                widget.message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
