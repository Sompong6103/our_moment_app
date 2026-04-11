import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../../../core/widgets/guest_card.dart';
import '../../domain/models/event_model.dart';
import 'analytics_page.dart';
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

  final List<Map<String, dynamic>> _guests = [
    {
      'name': 'Krittanai Ngampanja',
      'time': 'Joined 0 minutes ago.',
      'avatar': 'https://i.pravatar.cc/150?u=k1',
      'inEvent': false,
    },
    {
      'name': 'Cheewanon Srisawadwattana',
      'time': 'Joined 9 minutes ago.',
      'avatar': 'https://i.pravatar.cc/150?u=k2',
      'inEvent': true,
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
              childAspectRatio: 1.55,
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
                  onTap: () {},
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
            ...List.generate(_guests.length, (index) {
              final guest = _guests[index];
              return GuestCard(
                name: guest['name'],
                time: guest['time'],
                avatarUrl: guest['avatar'],
                inEvent: guest['inEvent'],
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

