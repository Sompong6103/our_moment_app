import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../domain/models/event_model.dart';

class AnalyticsPage extends StatelessWidget {
  final EventModel event;
  const AnalyticsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Analytics',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overview Cards ──
            Row(
              children: [
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.people_outline,
                    value: '2,831',
                    label: 'Registered',
                    trend: '+12%',
                    trendUp: true,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.login_rounded,
                    value: '1,821',
                    label: 'Checked In',
                    trend: '64%',
                    trendUp: true,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.photo_library_outlined,
                    value: '582',
                    label: 'Photos',
                    trend: '+48',
                    trendUp: true,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.favorite_border,
                    value: '781',
                    label: 'Wishes',
                    trend: '+23',
                    trendUp: true,
                    color: const Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Check-in Chart ──
            const Text('Check-in Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Guests checked in over time', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _BarChart(),
            const SizedBox(height: 28),

            // ── Engagement Stats ──
            const Text('Engagement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            _EngagementTile(
              icon: Icons.camera_alt_outlined,
              title: 'Photos per guest',
              value: '3.2',
              color: const Color(0xFFFF9800),
            ),
            _EngagementTile(
              icon: Icons.chat_bubble_outline,
              title: 'Avg. wish length',
              value: '24 words',
              color: const Color(0xFF9C27B0),
            ),
            _EngagementTile(
              icon: Icons.access_time,
              title: 'Avg. time in event',
              value: '2h 15m',
              color: const Color(0xFF2196F3),
            ),
            _EngagementTile(
              icon: Icons.trending_up,
              title: 'Peak check-in',
              value: '18:00 - 18:30',
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 28),

            // ── Top Contributors ──
            const Text('Top Contributors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            ...List.generate(3, (i) {
              final names = ['Krittanai N.', 'Cheewanon S.', 'Somchai P.'];
              final photos = [24, 18, 12];
              return _ContributorTile(
                rank: i + 1,
                name: names[i],
                photoCount: photos[i],
                avatarUrl: 'https://i.pravatar.cc/150?u=top$i',
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Overview Card ──
class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trendUp ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: trendUp ? const Color(0xFF4CAF50) : AppColors.danger,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: trendUp ? const Color(0xFF4CAF50) : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Simple Bar Chart ──
class _BarChart extends StatelessWidget {
  final List<double> _data = const [0.3, 0.5, 0.85, 1.0, 0.7, 0.45, 0.2];
  final List<String> _labels = const ['16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'];

  const _BarChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_data.length, (i) {
                final isMax = _data[i] == 1.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isMax)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${(_data[i] * 680).toInt()}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: _data[i] * 110,
                          decoration: BoxDecoration(
                            color: isMax ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_labels.length, (i) {
              return Expanded(
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Engagement Tile ──
class _EngagementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _EngagementTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ── Contributor Tile ──
class _ContributorTile extends StatelessWidget {
  final int rank;
  final String name;
  final int photoCount;
  final String avatarUrl;

  const _ContributorTile({
    required this.rank,
    required this.name,
    required this.photoCount,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final rankColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rankColors[rank - 1].withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: rankColors[rank - 1]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('$photoCount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
