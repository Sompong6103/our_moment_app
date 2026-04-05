import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/common/app_primary_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/profile/profile_detail_scaffold.dart';
import 'create_event_page2_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _dateStartController = TextEditingController();
  final _dateEndController = TextEditingController();

  bool _acceptPhotos = false;
  String? _themeName;
  Color? _themeColor;

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');

    controller.text = '$dayName, ${date.day} $monthName ${date.year} | $h:$m';
  }

  void _addTheme() {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = '';
        Color picked = const Color(0xFF001F54);

        final presets = <MapEntry<String, Color>>[
          const MapEntry('Blue Navy', Color(0xFF001F54)),
          const MapEntry('Rose Gold', Color(0xFFB76E79)),
          const MapEntry('Emerald', Color(0xFF2ECC71)),
          const MapEntry('Royal Purple', Color(0xFF6C3483)),
          const MapEntry('Sunset Orange', Color(0xFFE67E22)),
        ];

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: presets.map((e) {
                    final isSelected = picked == e.value;
                    return GestureDetector(
                      onTap: () => setDialogState(() {
                        picked = e.value;
                        name = e.key;
                      }),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: e.value,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primary, width: 3)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(e.key,
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (name.isNotEmpty) {
                    setState(() {
                      _themeName = name;
                      _themeColor = picked;
                    });
                  }
                },
                child: const Text('Select'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToPage2() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEventPage2Screen(
          eventName: _nameController.text,
          detail: _detailController.text,
          dateStart: _dateStartController.text,
          dateEnd: _dateEndController.text,
          themeName: _themeName,
          themeColor: _themeColor,
          acceptPhotos: _acceptPhotos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: 'Create Event',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner placeholder
            GestureDetector(
              onTap: () {
                // TODO: pick image
              },
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.buttonGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Tap to choose img banner',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Event name
            AppTextField(
              label: 'Event name',
              hintText: "Aom & Ton's Wedding",
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            // Detail
            AppTextField(
              label: 'Detail',
              hintText: 'Describe your event...',
              controller: _detailController,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Date start
            AppTextField(
              label: 'Date start',
              hintText: 'Sat, 25 Oct 2025 | 18:00',
              controller: _dateStartController,
              enabled: false,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _pickDateTime(_dateStartController),
                child: const Text('Pick date & time'),
              ),
            ),
            const SizedBox(height: 8),

            // Date end
            AppTextField(
              label: 'Date end',
              hintText: 'Sat, 25 Oct 2025 | 22:00',
              controller: _dateEndController,
              enabled: false,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _pickDateTime(_dateEndController),
                child: const Text('Pick date & time'),
              ),
            ),
            const SizedBox(height: 20),

            // Theme
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Add a color theme for the event.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _CircleAddButton(onTap: _addTheme),
              ],
            ),
            if (_themeName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _themeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _themeName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _themeName = null;
                      _themeColor = null;
                    }),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.danger,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 28),

            // Host Setting
            const Text(
              'Host Setting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Setting your event',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accepting photos from guests',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Switch(
                  value: _acceptPhotos,
                  onChanged: (v) => setState(() => _acceptPhotos = v),
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Next button
            AppPrimaryButton(
              label: 'Next',
              onPressed: _goToPage2,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}
