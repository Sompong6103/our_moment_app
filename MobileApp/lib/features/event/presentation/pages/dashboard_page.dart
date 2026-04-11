import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../../../core/widgets/guest_card.dart';
import '../../domain/models/event_model.dart';
import 'analytics_page.dart';
import 'guest_profile.dart';
import 'guest_see_all.dart';
import 'photo_management_page.dart';

class DashboardPage extends StatefulWidget {
  final EventModel event;

  const DashboardPage({super.key, required this.event});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _sharePhotos = false;

  void _showQrCode() {
    final qrKey = GlobalKey();

    Future<void> downloadQr() async {
      try {
        final boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        await Gal.putImageBytes(bytes, name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code saved to gallery'), backgroundColor: AppColors.primary),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save QR Code'), backgroundColor: Colors.red),
          );
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Event QR Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Scan to join ${widget.event.title}',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: QrImageView(
                    data: 'ourmoment://join?code=WED24&event=${widget.event.title}',
                    version: QrVersions.auto,
                    size: 220,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('JOIN CODE: WED24', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: downloadQr,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () async {
                          try {
                            final boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                            final image = await boundary.toImage(pixelRatio: 3.0);
                            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                            final bytes = byteData!.buffer.asUint8List();
                            final dir = await getTemporaryDirectory();
                            final file = File('${dir.path}/qr_code.png');
                            await file.writeAsBytes(bytes);
                            await SharePlus.instance.share(
                              ShareParams(
                                files: [XFile(file.path)],
                                text: 'Join ${widget.event.title} with code WED24!',
                              ),
                            );
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _guests = [
    {
      'name': 'Krittanai Ngampanja',
      'email': 'krittanai@gmail.com',
      'time': 'Joined 0 minutes ago.',
      'avatar': 'https://i.pravatar.cc/150?u=k1',
      'inEvent': false,
    },
    {
      'name': 'Cheewanon Srisawadwattana',
      'email': 'sn.cheewa@gmail.com',
      'time': 'Joined 9 minutes ago.',
      'avatar': 'https://i.pravatar.cc/150?u=k2',
      'inEvent': true,
    },
    {
      'name': 'Cameron Williamson',
      'email': 'cameron@gmail.com',
      'time': 'Joined 10 minutes ago.',
      'avatar': 'https://i.pravatar.cc/150?u=k3',
      'inEvent': false,
    },
    {
      'name': 'Darrell Steward',
      'email': 'darrell@gmail.com',
      'time': 'Joined 10 minutes ago.',
      'avatar': 'https://i.pravatar.cc/150?u=k4',
      'inEvent': false,
    },
    {
      'name': 'Ralph Edwards',
      'email': 'ralph@gmail.com',
      'time': 'Joined 10 minutes ago.',
      'avatar': 'https://i.pravatar.cc/150?u=k5',
      'inEvent': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Dashboard',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.buttonGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.more_vert, size: 22, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9B7FD4), Color(0xFF6B4FA0), Color(0xFF4A3578)],
                ),
              ),
              child: Stack(
                children: [
                  if (widget.event.coverImage != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Opacity(
                          opacity: 1,
                          child: Image.asset("assets/images/dashboard_background.png", fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'JOIN CODE: WED24',
                              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.copy, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _ActionChip(icon: Icons.edit, label: 'Edit event', onTap: () {}),
                            const SizedBox(width: 10),
                            _ActionChip(icon: Icons.share, label: 'Share', onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: _StatBox(value: '2,831', label: 'ผู้ลงทะเบียน')),
                            const SizedBox(width: 10),
                            const Expanded(child: _StatBox(value: '1,821', label: 'ผู้เข้าร่วมงาน')),
                            const SizedBox(width: 10),
                            const Expanded(child: _StatBox(value: '781', label: 'คำอวยพร')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Management (2x2 Grid) ──
            const Text(
              'Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MenuCard(
                  icon: Icons.people_outline,
                  title: 'Guest List',
                  subtitle: 'Manage attendees',
                  color: const Color(0xFF4CAF50),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestsScreen())),
                ),
                _MenuCard(
                  icon: Icons.photo_library_outlined,
                  title: 'Photos',
                  subtitle: 'Review & manage',
                  color: const Color(0xFFFF9800),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoManagementPage())),
                ),
                _MenuCard(
                  icon: Icons.qr_code_rounded,
                  title: 'QR Code',
                  subtitle: 'Share event code',
                  color: const Color(0xFF2196F3),
                  onTap: _showQrCode,
                ),
                _MenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Analytics',
                  subtitle: 'View insights',
                  color: const Color(0xFFE91E63),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsPage(event: widget.event))),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Host Setting ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOST SETTING',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Share photos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Accepting photos from guests', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      AppSwitch(
                        value: _sharePhotos,
                        onChanged: (v) => setState(() => _sharePhotos = v),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Announcement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Send notification to everyone', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.add, size: 24, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Guests ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Guests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestsScreen())),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('See all', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_guests.length > 5 ? 5 : _guests.length, (index) {
              final guest = _guests[index];
              return GuestCard(
                name: guest['name'],
                time: guest['time'],
                avatarUrl: guest['avatar'],
                inEvent: guest['inEvent'],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuestProfileScreen(
                      name: guest['name'],
                      email: guest['email'],
                      imageUrl: guest['avatar'],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Action Chip ──
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ── Stat Box ──
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

// ── Menu Card (2x2 grid) ──
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

