import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/agenda_item.dart';

class AgendaTimeline extends StatelessWidget {
  final List<AgendaItem> items;
  final Widget Function(BuildContext context, int index)? trailingBuilder;

  const AgendaTimeline({
    super.key,
    required this.items,
    this.trailingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Sort: upcoming items first (by nearest time), then past items
    final sorted = List<AgendaItem>.from(items);
    sorted.sort((a, b) {
      if (a.rawDateTime == null && b.rawDateTime == null) return 0;
      if (a.rawDateTime == null) return 1;
      if (b.rawDateTime == null) return -1;
      final now = DateTime.now();
      final aIsPast = a.rawDateTime!.isBefore(now);
      final bIsPast = b.rawDateTime!.isBefore(now);
      if (aIsPast != bIsPast) return aIsPast ? 1 : -1; // upcoming first
      return a.rawDateTime!.compareTo(b.rawDateTime!);
    });

    return Column(
      children: List.generate(sorted.length, (index) {
        final item = sorted[index];
        final isLast = index == sorted.length - 1;
        final isPast = item.isPast;
        final dotColor = isPast ? Colors.grey[400]! : AppColors.primary;
        final lineColor = isPast ? Colors.grey[300]! : AppColors.primary.withValues(alpha: 0.3);
        final dateColor = isPast ? Colors.grey[400]! : AppColors.primary;

        return IntrinsicHeight(
          child: Row(
            children: [
              // Timeline dot & line
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: lineColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),

              // Card
              Expanded(
                child: Opacity(
                  opacity: isPast ? 0.55 : 1.0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isPast ? Colors.grey[300]! : AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 14, color: dateColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    item.dateTime,
                                    style: TextStyle(
                                        color: dateColor, fontSize: 12),
                                  ),
                                  if (isPast) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('Past', style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                item.description,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 13),
                              ),
                              if (item.location.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 12, color: AppColors.iconInactive),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.location,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailingBuilder != null)
                          trailingBuilder!(context, index),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
