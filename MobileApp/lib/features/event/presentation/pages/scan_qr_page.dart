import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _joinEventByQRCode(String qrValue) async {
    debugPrint('API call → POST /api/events/join  body: {code: $qrValue}');
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'eventId': 'evt_12345',
      'eventName': 'Mock Event',
      'message': 'Joined event successfully',
    };
  }

  Future<void> _handleQRCode(String qrValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    controller.stop();

    try {
      final result = await _joinEventByQRCode(qrValue);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าร่วมอีเวนต์สำเร็จ: ${result['eventName']}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, qrValue);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'เข้าร่วมไม่สำเร็จ'),
            backgroundColor: Colors.red,
          ),
        );
        controller.start();
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่'),
          backgroundColor: Colors.red,
        ),
      );
      controller.start();
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickImageAndScan() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (picked == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final barcodes = await controller
          .analyzeImage(picked.path)
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;
      Navigator.pop(context);

      if (barcodes == null ||
          !barcodes.barcodes.any((b) => b.rawValue != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบ QR Code ในรูปภาพ'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final qrValue =
          barcodes.barcodes.firstWhere((b) => b.rawValue != null).rawValue!;
      await _handleQRCode(qrValue);
    } on TimeoutException {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถวิเคราะห์รูปภาพได้ (ไม่รองรับ Simulator)'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถอ่าน QR Code จากรูปภาพได้: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'ไม่สามารถเปิดกล้องได้\n${error.errorDetails?.message ?? ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                  return;
                }
              }
            },
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Stack(
                children: [
                  _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                  _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                  _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                  _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              children: [
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Scan QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
          ),

          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.flash_on,
                  onPressed: () => controller.toggleTorch(),
                ),
                _buildCircleButton(
                  icon: Icons.image_outlined,
                  onPressed: _pickImageAndScan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    const double length = 40;
    const double thickness = 6;
    const double radius = 15;

    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: length,
        height: length,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? Radius.circular(radius) : Radius.zero,
            topRight: isTop && !isLeft ? Radius.circular(radius) : Radius.zero,
            bottomLeft: !isTop && isLeft ? Radius.circular(radius) : Radius.zero,
            bottomRight: !isTop && !isLeft ? Radius.circular(radius) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.black26,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
      ),
    );
  }
}
