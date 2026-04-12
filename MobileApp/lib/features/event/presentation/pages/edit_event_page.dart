import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_switch.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/agenda_item.dart';
import '../widgets/agenda_timeline.dart';
import 'location_picker_page.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;
  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _eventRepo = EventRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _detailController;
  late final TextEditingController _dateStartController;
  late final TextEditingController _dateEndController;
  late bool _acceptPhotos;
  bool _saving = false;

  // Date
  DateTime? _dateStart;
  DateTime? _dateEnd;

  // Banner
  File? _bannerImage;
  String? _existingCoverUrl;

  // Theme
  String? _themeName;
  Color? _themeColor;

  // Location
  SelectedLocation? _selectedLocation;

  // Agenda
  List<AgendaItem> _agendaItems = [];
  final Set<String> _deletedAgendaIds = {};
  bool _loadingAgenda = true;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _nameController = TextEditingController(text: e.title);
    _detailController = TextEditingController(text: e.description ?? '');
    _acceptPhotos = e.acceptPhotos;
    _existingCoverUrl = e.coverImageUrl;
    _themeName = e.themeName;
    _themeColor = e.themeColor;

    // Dates
    _dateStart = e.eventDateTime;
    _dateStartController = TextEditingController(
      text: _dateStart != null ? _formatDateTime(_dateStart!) : '',
    );
    if (_dateStart != null && e.time != null && e.time!.contains(' - ')) {
      final endPart = e.time!.split(' - ').last.trim();
      final parts = endPart.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          _dateEnd = DateTime(_dateStart!.year, _dateStart!.month, _dateStart!.day, h, m);
        }
      }
    }
    _dateEndController = TextEditingController(
      text: _dateEnd != null ? _formatDateTime(_dateEnd!) : '',
    );

    // Location
    if (e.latitude != null && e.longitude != null) {
      _selectedLocation = SelectedLocation(
        latLng: LatLng(e.latitude!, e.longitude!),
        displayName: e.location ?? '',
      );
    }

    // Load agenda
    _loadAgenda();
  }

  Future<void> _loadAgenda() async {
    try {
      final items = await _eventRepo.getAgenda(widget.event.id);
      if (mounted) setState(() { _agendaItems = items; _loadingAgenda = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingAgenda = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year} | $h:$m';
  }

  static DateTime? _parseFormattedDate(String text) {
    const months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};
    final match = RegExp(r'(\d+)\s+(\w+)\s+(\d+)\s*\|\s*(\d+):(\d+)').firstMatch(text);
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!) ?? 1;
    final month = months[match.group(2)] ?? 1;
    final year = int.tryParse(match.group(3)!) ?? 2025;
    final hour = int.tryParse(match.group(4)!) ?? 0;
    final minute = int.tryParse(match.group(5)!) ?? 0;
    return DateTime(year, month, day, hour, minute);
  }

  Future<void> _pickDateTime(TextEditingController controller, {required bool isStart}) async {
    final initial = isStart ? _dateStart : _dateEnd;
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay(hour: initial.hour, minute: initial.minute)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) _dateStart = dt; else _dateEnd = dt;
      controller.text = _formatDateTime(dt);
    });
  }

  // ── Banner ──
  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Banner',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Banner',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped != null) {
      setState(() {
        _bannerImage = File(cropped.path);
        _existingCoverUrl = null;
      });
    }
  }

  // ── Theme Picker ──
  void _addTheme() {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = _themeName ?? '';
        Color picked = _themeColor ?? const Color(0xFF001F54);
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
                        Text(category.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: category.value.map((e) {
                            final isSelected = !isCustom && picked == e.value && name == e.key;
                            return GestureDetector(
                              onTap: () => setDialogState(() { picked = e.value; name = e.key; isCustom = false; }),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: e.value, shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(color: AppColors.primary, width: 3)
                                          : Border.all(color: Colors.grey.withAlpha(60), width: 0.5),
                                      boxShadow: isSelected ? [BoxShadow(color: e.value.withAlpha(100), blurRadius: 6)] : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    width: 50,
                                    child: Text(e.key, style: TextStyle(fontSize: 8, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                        const Text('Custom Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Switch(value: isCustom, onChanged: (v) => setDialogState(() => isCustom = v), activeTrackColor: AppColors.primary),
                      ],
                    ),
                    if (isCustom) ...[
                      const SizedBox(height: 8),
                      ColorPicker(
                        pickerColor: picked,
                        onColorChanged: (color) => setDialogState(() { picked = color; isCustom = true; }),
                        enableAlpha: false, hexInputBar: true, labelTypes: const [], pickerAreaHeightPercent: 0.5,
                      ),
                      const SizedBox(height: 8),
                      TextField(controller: customNameCtrl, decoration: const InputDecoration(labelText: 'Color name', hintText: 'e.g. My Custom Blue', isDense: true), onChanged: (v) => setDialogState(() => name = v)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (name.isNotEmpty) setState(() { _themeName = name; _themeColor = picked; });
                },
                child: const Text('Select'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Agenda ──
  void _addAgendaItem() => _showAgendaDialog();

  void _editAgendaItem(int index) {
    final item = _agendaItems[index];
    _showAgendaDialog(editIndex: index, initialTitle: item.title, initialDesc: item.description, initialLocation: item.location, initialDateTime: item.dateTime);
  }

  void _deleteAgendaItem(int index) {
    final item = _agendaItems[index];
    if (item.id != null) _deletedAgendaIds.add(item.id!);
    setState(() => _agendaItems.removeAt(index));
  }

  void _showAgendaDialog({int? editIndex, String initialTitle = '', String initialDesc = '', String initialLocation = '', String initialDateTime = ''}) {
    showDialog(
      context: context,
      builder: (ctx) {
        final titleCtrl = TextEditingController(text: initialTitle);
        final descCtrl = TextEditingController(text: initialDesc);
        final locationCtrl = TextEditingController(text: initialLocation);
        final dateTimeCtrl = TextEditingController(text: initialDateTime);

        Future<void> pickDateTime() async {
          final date = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
          if (date == null || !ctx.mounted) return;
          final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
          if (time == null) return;
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final h = time.hour.toString().padLeft(2, '0');
          final m = time.minute.toString().padLeft(2, '0');
          dateTimeCtrl.text = '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year} | $h:$m';
        }

        return AlertDialog(
          title: Text(editIndex != null ? 'Edit Agenda' : 'Add Agenda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(onTap: pickDateTime, child: AbsorbPointer(child: TextField(controller: dateTimeCtrl, decoration: const InputDecoration(labelText: 'Date & Time', hintText: 'Tap to select', suffixIcon: Icon(Icons.calendar_today, size: 18))))),
                const SizedBox(height: 8),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 8),
                TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  final existingId = editIndex != null ? _agendaItems[editIndex].id : null;
                  final newItem = AgendaItem(id: existingId, dateTime: dateTimeCtrl.text, title: titleCtrl.text, description: descCtrl.text, location: locationCtrl.text);
                  setState(() {
                    if (editIndex != null) { _agendaItems[editIndex] = newItem; } else { _agendaItems.add(newItem); }
                  });
                }
                Navigator.pop(ctx);
              },
              child: Text(editIndex != null ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  // ── Save ──
  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event name is required'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _saving = true);

    try {
      // 1. Update event fields
      final body = <String, dynamic>{
        'title': _nameController.text.trim(),
        'acceptPhotos': _acceptPhotos,
      };
      if (_detailController.text.trim().isNotEmpty) body['description'] = _detailController.text.trim();
      if (_dateStart != null) {
        final ds = _dateStart!.toUtc().toIso8601String();
        body['dateStart'] = ds.endsWith('Z') ? ds : '${ds}Z';
      }
      if (_dateEnd != null) {
        final de = _dateEnd!.toUtc().toIso8601String();
        body['dateEnd'] = de.endsWith('Z') ? de : '${de}Z';
      }
      if (_themeName != null) body['themeName'] = _themeName;
      if (_themeColor != null) {
        body['themeColor'] = '#${_themeColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      }
      if (_selectedLocation != null) {
        body['location'] = {
          'address': _selectedLocation!.displayName,
          'latitude': _selectedLocation!.latLng.latitude,
          'longitude': _selectedLocation!.latLng.longitude,
        };
      }
      await _eventRepo.update(widget.event.id, body);

      // 2. Upload new banner
      if (_bannerImage != null) {
        await _eventRepo.uploadCover(widget.event.id, _bannerImage!.path);
      }

      // 3. Delete removed agenda items
      for (final id in _deletedAgendaIds) {
        await _eventRepo.deleteAgendaItem(widget.event.id, id);
      }

      // 4. Create / update agenda items
      for (int i = 0; i < _agendaItems.length; i++) {
        final item = _agendaItems[i];
        final agendaTime = _parseFormattedDate(item.dateTime);
        final timeStr = agendaTime != null ? '${agendaTime.toIso8601String()}Z' : '';

        if (item.id != null) {
          // Existing item → update
          await _eventRepo.updateAgendaItem(
            widget.event.id, item.id!,
            title: item.title,
            description: item.description.isNotEmpty ? item.description : null,
            location: item.location.isNotEmpty ? item.location : null,
            startTime: timeStr,
            sortOrder: i,
          );
        } else {
          // New item → create
          await _eventRepo.createAgendaItem(
            widget.event.id,
            title: item.title,
            description: item.description.isNotEmpty ? item.description : null,
            location: item.location.isNotEmpty ? item.location : null,
            startTime: timeStr,
            sortOrder: i,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated'), backgroundColor: AppColors.primary));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Edit Event',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Banner Image ──
                  GestureDetector(
                    onTap: _pickBannerImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _bannerImage != null
                          ? Stack(
                              children: [
                                Image.file(_bannerImage!, height: 160, width: double.infinity, fit: BoxFit.cover),
                                Positioned(
                                  top: 8, right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(() { _bannerImage = null; }),
                                    child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                          : _existingCoverUrl != null
                              ? Stack(
                                  children: [
                                    Image.network(_existingCoverUrl!, height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 160, color: AppColors.buttonGrey, alignment: Alignment.center, child: const Icon(Icons.broken_image, color: Colors.grey))),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _existingCoverUrl = null),
                                        child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8, right: 8,
                                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)), child: const Text('Tap to change', style: TextStyle(fontSize: 11, color: Colors.white))),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: 160, width: double.infinity,
                                  decoration: BoxDecoration(color: AppColors.buttonGrey, borderRadius: BorderRadius.circular(16)),
                                  alignment: Alignment.center,
                                  child: Text('Tap to choose img banner', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Event Name ──
                  AppTextField(label: 'Event name', hintText: "Event name", controller: _nameController),
                  const SizedBox(height: 16),

                  // ── Detail ──
                  AppTextField(label: 'Detail', hintText: 'Describe your event...', controller: _detailController, maxLines: 5),
                  const SizedBox(height: 16),

                  // ── Date Start ──
                  GestureDetector(
                    onTap: () => _pickDateTime(_dateStartController, isStart: true),
                    child: AbsorbPointer(child: AppTextField(label: 'Date start', hintText: 'Sat, 25 Oct 2025 | 18:00', controller: _dateStartController)),
                  ),
                  const SizedBox(height: 16),

                  // ── Date End ──
                  GestureDetector(
                    onTap: () => _pickDateTime(_dateEndController, isStart: false),
                    child: AbsorbPointer(child: AppTextField(label: 'Date end', hintText: 'Sat, 25 Oct 2025 | 22:00', controller: _dateEndController)),
                  ),
                  const SizedBox(height: 20),

                  // ── Theme ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Add a color theme for the event.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _addTheme,
                        child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 20)),
                      ),
                    ],
                  ),
                  if (_themeName != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(width: 28, height: 28, decoration: BoxDecoration(color: _themeColor, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Text(_themeName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        const Spacer(),
                        GestureDetector(onTap: () => setState(() { _themeName = null; _themeColor = null; }), child: Icon(Icons.cancel, color: AppColors.danger, size: 22)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),

                  // ── Host Settings ──
                  const Text('Host Setting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Setting your event', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Accepting photos from guests', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      AppSwitch(value: _acceptPhotos, onChanged: (v) => setState(() => _acceptPhotos = v)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Location ──
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Selection location your events', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<SelectedLocation>(
                        context,
                        MaterialPageRoute(builder: (_) => LocationPickerPage(initialLocation: _selectedLocation?.latLng)),
                      );
                      if (result != null) setState(() => _selectedLocation = result);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 140, width: double.infinity, color: AppColors.buttonGrey,
                        child: _selectedLocation != null
                            ? Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      'https://tile.openstreetmap.org/15/${_lngToTileX(_selectedLocation!.latLng.longitude, 15)}/${_latToTileY(_selectedLocation!.latLng.latitude, 15)}.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const SizedBox(),
                                    ),
                                  ),
                                  Container(color: Colors.white.withValues(alpha: 0.3)),
                                  Center(child: Icon(Icons.location_on, size: 36, color: AppColors.primary)),
                                  Positioned(
                                    bottom: 8, left: 12, right: 12,
                                    child: Text(_selectedLocation!.displayName, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                  ),
                                ],
                              )
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.map_outlined, size: 48, color: AppColors.textSecondary.withAlpha(100)),
                                  Positioned(bottom: 8, child: Text('Tap to select location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Agenda ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Edit schedule or add new items.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _addAgendaItem,
                        child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_loadingAgenda)
                    const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                  else
                    AgendaTimeline(
                      items: _agendaItems,
                      trailingBuilder: (context, index) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(onTap: () => _editAgendaItem(index), child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary)),
                          const SizedBox(height: 12),
                          GestureDetector(onTap: () => _deleteAgendaItem(index), child: const Icon(Icons.delete_outline, size: 18, color: Colors.red)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Save Button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: AppPrimaryButton(
              label: _saving ? 'Saving...' : 'Save Changes',
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }

  static int _lngToTileX(double lng, int zoom) => (((lng + 180) / 360) * (1 << zoom)).floor();
  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    return ((1 - (log(tan(latRad) + 1 / cos(latRad)) / pi)) / 2 * (1 << zoom)).floor();
  }
}
