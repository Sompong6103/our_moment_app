import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/sample_events.dart';
import '../../domain/models/event_model.dart';
import 'event_detail_page.dart';
import 'scan_qr_page.dart';

// Mock: map join codes to events
const _eventCodes = <String, int>{
  'WED24': 1,
};

EventModel? _findEventByCode(String code) {
  final index = _eventCodes[code.toUpperCase().trim()];
  if (index != null && index < sampleEvents.length) return sampleEvents[index];
  return null;
}

class JoinEventPage extends StatefulWidget {
  const JoinEventPage({super.key});

  @override
  State<JoinEventPage> createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  final _codeController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinWithCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = 'Please enter an event code');
      return;
    }
    final event = _findEventByCode(code);
    if (event == null) {
      setState(() => _errorText = 'Invalid code. Please try again.');
      return;
    }
    setState(() => _errorText = null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailPage(event: event, showJoinButton: true),
      ),
    );
  }

  Future<void> _handleQrResult(String? qrValue) async {
    if (qrValue == null) return;
    // Parse QR: ourmoment://join?code=WED24&event=...
    String? code;
    if (qrValue.contains('code=')) {
      final uri = Uri.tryParse(qrValue);
      code = uri?.queryParameters['code'];
    } else {
      code = qrValue;
    }
    if (code == null) return;

    final event = _findEventByCode(code);
    if (event != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailPage(event: event, showJoinButton: true),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR Code'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topImageHeight = MediaQuery.of(context).size.height * 0.42;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Container(
            height: topImageHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/join_event_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height - topImageHeight + 30,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'ENTER EVENT CODE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.left,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 16),
                    onChanged: (_) {
                      if (_errorText != null) setState(() => _errorText = null);
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Code',
                      hintStyle: const TextStyle(color: AppColors.inputHint),
                      errorText: _errorText,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  AppPrimaryButton(
                    label: 'Join Event',
                    onPressed: _joinWithCode,
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const Expanded(
                          child: Divider(thickness: 1, color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(
                          child: Divider(thickness: 1, color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ScanQrPage()),
                        );
                        _handleQrResult(result);
                      },
                      icon: const Icon(Icons.qr_code_scanner,
                          color: AppColors.textPrimary, size: 22),
                      label: const Text(
                        'Scan QR Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
