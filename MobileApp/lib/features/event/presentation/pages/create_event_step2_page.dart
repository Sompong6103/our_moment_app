import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../domain/models/agenda_item.dart';
import '../widgets/agenda_timeline.dart';

class CreateEventStep2Page extends StatefulWidget {
  final String eventName;
  final String detail;
  final String dateStart;
  final String dateEnd;
  final String? themeName;
  final Color? themeColor;
  final bool acceptPhotos;

  const CreateEventStep2Page({
    super.key,
    required this.eventName,
    required this.detail,
    required this.dateStart,
    required this.dateEnd,
    this.themeName,
    this.themeColor,
    required this.acceptPhotos,
  });

  @override
  State<CreateEventStep2Page> createState() =>
      _CreateEventStep2PageState();
}

class _CreateEventStep2PageState extends State<CreateEventStep2Page> {
  final List<AgendaItem> _agendaItems = [
    const AgendaItem(
      dateTime: 'Sat, 25 Oct 2025 | 18:00',
      title: 'Buddhist ceremony',
      description: 'Offering food to nine monks.',
      location: 'Rao Grand 2',
    ),
    const AgendaItem(
      dateTime: 'Sat, 25 Oct 2025 | 18:00',
      title: 'Buddhist ceremony',
      description: 'Offering food to nine monks.',
      location: 'Rao Grand 2',
    ),
    const AgendaItem(
      dateTime: 'Sat, 25 Oct 2025 | 18:00',
      title: 'Buddhist ceremony',
      description: 'Offering food to nine monks.',
      location: 'Rao Grand 2',
    ),
    const AgendaItem(
      dateTime: 'Sat, 25 Oct 2025 | 18:00',
      title: 'Buddhist ceremony',
      description: 'Offering food to nine monks.',
      location: 'Rao Grand 2',
    ),
  ];

  void _addAgendaItem() {
    showDialog(
      context: context,
      builder: (ctx) {
        final titleCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        final locationCtrl = TextEditingController();
        final dateTimeCtrl = TextEditingController();

        Future<void> pickDateTime() async {
          final date = await showDatePicker(
            context: ctx,
            initialDate: DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
          );
          if (date == null || !ctx.mounted) return;

          final time = await showTimePicker(
            context: ctx,
            initialTime: TimeOfDay.now(),
          );
          if (time == null) return;

          final months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
          ];
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final dayName = days[date.weekday - 1];
          final monthName = months[date.month - 1];
          final h = time.hour.toString().padLeft(2, '0');
          final m = time.minute.toString().padLeft(2, '0');

          dateTimeCtrl.text =
              '$dayName, ${date.day} $monthName ${date.year} | $h:$m';
        }

        return AlertDialog(
          title: const Text('Add Agenda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: pickDateTime,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: dateTimeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Date & Time',
                        hintText: 'Tap to select',
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Location'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  setState(() {
                    _agendaItems.add(AgendaItem(
                      dateTime: dateTimeCtrl.text,
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      location: locationCtrl.text,
                    ));
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirm() {
    // TODO: save event logic
    Navigator.of(context)
      ..pop() // step 2
      ..pop(); // step 1 → back to home
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Create Event',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Selection location your events',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: AppColors.buttonGrey,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: AppColors.textSecondary.withAlpha(100),
                          ),
                          Positioned(
                            bottom: 8,
                            child: Text(
                              'Tap to select location',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Agenda',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Add to the schedule or add later.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _addAgendaItem,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                              Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AgendaTimeline(items: _agendaItems),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: AppPrimaryButton(
              label: 'Confirm',
              onPressed: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}
