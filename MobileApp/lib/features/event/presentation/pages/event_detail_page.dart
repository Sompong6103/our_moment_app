import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../domain/models/event_model.dart';
import '../widgets/event_detail_header.dart';
import '../widgets/event_feature_grid.dart';
import 'dashboard_page.dart';
import 'guest_details_page.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;
  final bool showJoinButton;

  const EventDetailPage({super.key, required this.event, this.showJoinButton = false});

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Detail Event',
      actions: event.isHost
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardPage(event: event),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.dashboard_outlined,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ]
          : null,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventDetailHeader(event: event),
                  const SizedBox(height: 20),

                  EventFeatureGrid(isHost: event.isHost),
                  const SizedBox(height: 24),

                  const Text(
                    'Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: event.themeColor ?? AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        event.themeName ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showJoinButton)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuestDetailsPage(event: event),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Join Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
