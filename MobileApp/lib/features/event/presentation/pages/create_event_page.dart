import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/app_switch.dart';
import 'create_event_step2_page.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _dateStartController = TextEditingController();
  final _dateEndController = TextEditingController();

  File? _bannerImage;
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

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked != null) {
      setState(() => _bannerImage = File(picked.path));
    }
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
        bool isCustom = false;
        final customNameCtrl = TextEditingController();

        final themeCategories = <String, List<MapEntry<String, Color>>>{
          '💒 Wedding': [
            const MapEntry('Classic White', Color(0xFFFAF3E0)),
            const MapEntry('Rose Gold', Color(0xFFB76E79)),
            const MapEntry('Blush Pink', Color(0xFFF8A5C2)),
            const MapEntry('Champagne', Color(0xFFE8D5B7)),
            const MapEntry('Ivory Gold', Color(0xFFD4AF37)),
            const MapEntry('Dusty Blue', Color(0xFF6E8FAC)),
            const MapEntry('Sage Green', Color(0xFF9CAF88)),
            const MapEntry('Lavender', Color(0xFFB39DDB)),
          ],
          '🙏 Buddhist Ceremony': [
            const MapEntry('Saffron', Color(0xFFF4A460)),
            const MapEntry('Temple Gold', Color(0xFFDAA520)),
            const MapEntry('Lotus Pink', Color(0xFFE091AA)),
            const MapEntry('Sacred White', Color(0xFFF5F5F0)),
            const MapEntry('Monk Orange', Color(0xFFE67E22)),
            const MapEntry('Jade Green', Color(0xFF00A86B)),
          ],
          '🎉 Party & Celebration': [
            const MapEntry('Royal Purple', Color(0xFF6C3483)),
            const MapEntry('Electric Blue', Color(0xFF3498DB)),
            const MapEntry('Neon Pink', Color(0xFFFF1493)),
            const MapEntry('Sunset Orange', Color(0xFFE67E22)),
            const MapEntry('Cherry Red', Color(0xFFE74C3C)),
            const MapEntry('Gold Glam', Color(0xFFF1C40F)),
          ],
          '🤵 Formal & Corporate': [
            const MapEntry('Navy Blue', Color(0xFF001F54)),
            const MapEntry('Midnight', Color(0xFF2C3E50)),
            const MapEntry('Charcoal', Color(0xFF36454F)),
            const MapEntry('Slate Grey', Color(0xFF7F8C8D)),
            const MapEntry('Forest Green', Color(0xFF2D572C)),
            const MapEntry('Burgundy', Color(0xFF800020)),
          ],
          '🌿 Nature & Garden': [
            const MapEntry('Emerald', Color(0xFF2ECC71)),
            const MapEntry('Teal', Color(0xFF1ABC9C)),
            const MapEntry('Olive', Color(0xFF808000)),
            const MapEntry('Coral', Color(0xFFFF6F61)),
            const MapEntry('Sky Blue', Color(0xFF87CEEB)),
            const MapEntry('Terracotta', Color(0xFFCC5A47)),
          ],
        };

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Choose Theme'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...themeCategories.entries.map((category) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: category.value.map((e) {
                            final isSelected =
                                !isCustom && picked == e.value && name == e.key;
                            return GestureDetector(
                              onTap: () => setDialogState(() {
                                picked = e.value;
                                name = e.key;
                                isCustom = false;
                              }),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: e.value,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: AppColors.primary,
                                              width: 3)
                                          : Border.all(
                                              color: Colors.grey.withAlpha(60),
                                              width: 0.5),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color:
                                                    e.value.withAlpha(100),
                                                blurRadius: 6,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      e.key,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],
                    )),

                    const Divider(),
                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Custom Color',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: isCustom,
                          onChanged: (v) => setDialogState(() {
                            isCustom = v;
                          }),
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),

                    if (isCustom) ...[
                      const SizedBox(height: 8),
                      ColorPicker(
                        pickerColor: picked,
                        onColorChanged: (color) => setDialogState(() {
                          picked = color;
                          isCustom = true;
                        }),
                        enableAlpha: false,
                        hexInputBar: true,
                        labelTypes: const [],
                        pickerAreaHeightPercent: 0.5,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: customNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Color name',
                          hintText: 'e.g. My Custom Blue',
                          isDense: true,
                        ),
                        onChanged: (v) => setDialogState(() {
                          name = v;
                        }),
                      ),
                    ],
                  ],
                ),
              ),
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

  void _goToStep2() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEventStep2Page(
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
    return AppDetailScaffold(
      title: 'Create Event',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickBannerImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _bannerImage != null
                    ? Stack(
                        children: [
                          Image.file(
                            _bannerImage!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _bannerImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
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
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Event name',
              hintText: "Aom & Ton's Wedding",
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Detail',
              hintText: 'Describe your event...',
              controller: _detailController,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _pickDateTime(_dateStartController),
              child: AbsorbPointer(
                child: AppTextField(
                  label: 'Date start',
                  hintText: 'Sat, 25 Oct 2025 | 18:00',
                  controller: _dateStartController,
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _pickDateTime(_dateEndController),
              child: AbsorbPointer(
                child: AppTextField(
                  label: 'Date end',
                  hintText: 'Sat, 25 Oct 2025 | 22:00',
                  controller: _dateEndController,
                ),
              ),
            ),
            const SizedBox(height: 20),

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
                AppSwitch(
                  value: _acceptPhotos,
                  onChanged: (v) => setState(() => _acceptPhotos = v),
                ),
              ],
            ),
            const SizedBox(height: 28),

            AppPrimaryButton(
              label: 'Next',
              onPressed: _goToStep2,
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
