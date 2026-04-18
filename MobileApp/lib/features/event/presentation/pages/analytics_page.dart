import 'package:flutter/material.dart';
import '../../../../core/services/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_model.dart';

class AnalyticsPage extends StatefulWidget {
  final EventModel event;
  const AnalyticsPage({super.key, required this.event});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _eventRepo = EventRepository();
  bool _loading = true;
  int _registeredCount = 0;
  int _checkedInCount = 0;
  int _photoCount = 0;
  int _wishCount = 0;
  List<Map<String, dynamic>> _topContributors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final eventId = widget.event.id;
      final results = await Future.wait([
        _eventRepo.getAnalytics(eventId),
        _eventRepo.getTopContributors(eventId),
      ]);

      final overview = results[0] as Map<String, dynamic>;
      final contributors = results[1] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _registeredCount = overview['registeredCount'] ?? 0;
          _checkedInCount = overview['checkedInCount'] ?? 0;
          _photoCount = overview['photoCount'] ?? 0;
          _wishCount = overview['wishCount'] ?? 0;

          _topContributors = contributors;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final checkedInPct = _registeredCount > 0
        ? '${(_checkedInCount * 100 / _registeredCount).round()}%'
        : '0%';
    final photosPerGuest = _registeredCount > 0
        ? (_photoCount / _registeredCount).toStringAsFixed(1)
        : '0';

    return AppDetailScaffold(
      title: 'Analytics',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.people_outline,
                    value: _formatCount(_registeredCount),
                    label: 'Registered',
                    trend: '',
                    trendUp: true,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.login_rounded,
                    value: _formatCount(_checkedInCount),
                    label: 'Checked In',
                    trend: checkedInPct,
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
                    value: _formatCount(_photoCount),
                    label: 'Photos',
                    trend: '',
                    trendUp: true,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.favorite_border,
                    value: _formatCount(_wishCount),
                    label: 'Wishes',
                    trend: '',
                    trendUp: true,
                    color: const Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Engagement Stats
            const Text('Engagement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            _EngagementTile(
              icon: Icons.camera_alt_outlined,
              title: 'Photos per guest',
              value: photosPerGuest,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 28),

            // Top Contributors
            if (_topContributors.isNotEmpty) ...[
              const Text('Top Contributors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              ...List.generate(_topContributors.length.clamp(0, 10), (i) {
                final c = _topContributors[i];
                final user = c['user'] as Map<String, dynamic>? ?? {};
                return _ContributorTile(
                  rank: i + 1,
                  name: user['fullName'] ?? 'Unknown',
                  photoCount: c['photoCount'] ?? 0,
                  avatarUrl: user['avatarUrl'] ?? '',
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

}

// Overview Card
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
              if (trend.isNotEmpty)
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

// Engagement Tile
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

// Contributor Tile
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
    final rankColor = rank <= 3 ? rankColors[rank - 1] : AppColors.textSecondary;

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
                color: rankColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: rankColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundImage: ApiConfig.fullImageUrl(avatarUrl) != null
                  ? NetworkImage(ApiConfig.fullImageUrl(avatarUrl)!)
                  : null,
              child: ApiConfig.fullImageUrl(avatarUrl) == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : null,
            ),
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
