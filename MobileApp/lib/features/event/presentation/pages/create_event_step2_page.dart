import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/event_repository.dart';
import '../../domain/models/agenda_item.dart';
import '../widgets/agenda_timeline.dart';
import 'location_picker_page.dart';

class CreateEventStep2Page extends StatefulWidget {
  final String eventName;
  final String detail;
  final String dateStart;
  final String dateEnd;
  final String? themeName;
  final Color? themeColor;
  final bool acceptPhotos;
  final String? bannerImagePath;

  const CreateEventStep2Page({
    super.key,
    required this.eventName,
    required this.detail,
    required this.dateStart,
    required this.dateEnd,
    this.themeName,
    this.themeColor,
    required this.acceptPhotos,
    this.bannerImagePath,
  });

  @override
  State<CreateEventStep2Page> createState() =>
      _CreateEventStep2PageState();
}

class _CreateEventStep2PageState extends State<CreateEventStep2Page> {
  SelectedLocation? _selectedLocation;
  bool _saving = false;
  final _eventRepo = EventRepository();

  final List<AgendaItem> _agendaItems = [];

  void _addAgendaItem() {
    _showAgendaDialog();
  }

  void _editAgendaItem(int index) {
    final item = _agendaItems[index];
    _showAgendaDialog(
      editIndex: index,
      initialTitle: item.title,
      initialDesc: item.description,
      initialLocation: item.location,
      initialDateTime: item.dateTime,
    );
  }

  void _deleteAgendaItem(int index) {
    setState(() => _agendaItems.removeAt(index));
  }

  void _showAgendaDialog({
    int? editIndex,
    String initialTitle = '',
    String initialDesc = '',
    String initialLocation = '',
    String initialDateTime = '',
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        final titleCtrl = TextEditingController(text: initialTitle);
        final descCtrl = TextEditingController(text: initialDesc);
        final locationCtrl = TextEditingController(text: initialLocation);
        final dateTimeCtrl = TextEditingController(text: initialDateTime);

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
          title: Text(editIndex != null ? 'Edit Agenda' : 'Add Agenda'),
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
                  final newItem = AgendaItem(
                    dateTime: dateTimeCtrl.text,
                    title: titleCtrl.text,
                    description: descCtrl.text,
                    location: locationCtrl.text,
                  );
                  setState(() {
                    if (editIndex != null) {
                      _agendaItems[editIndex] = newItem;
                    } else {
                      _agendaItems.add(newItem);
                    }
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

  static DateTime? _parseFormattedDate(String text) {
    // Parse "Sat, 25 Oct 2025 | 18:00" to DateTime
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

  Future<void> _confirm() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final dateStart = _parseFormattedDate(widget.dateStart);
      final dateEnd = _parseFormattedDate(widget.dateEnd);

      final dateStartStr = dateStart != null ? dateStart.toUtc().toIso8601String() : '';
      final dateEndStr = dateEnd != null ? dateEnd.toUtc().toIso8601String() : '';

      String? themeColorHex;
      if (widget.themeColor != null) {
        themeColorHex = '#${widget.themeColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      }

      Map<String, dynamic>? location;
      if (_selectedLocation != null) {
        location = {
          'address': _selectedLocation!.displayName,
          'latitude': _selectedLocation!.latLng.latitude,
          'longitude': _selectedLocation!.latLng.longitude,
        };
      }

      final event = await _eventRepo.create(
        title: widget.eventName,
        type: 'ceremony',
        description: widget.detail.isNotEmpty ? widget.detail : null,
        dateStart: dateStartStr,
        dateEnd: dateEndStr,
        themeName: widget.themeName,
        themeColor: themeColorHex,
        acceptPhotos: widget.acceptPhotos,
        location: location,
      );

      // Upload banner if selected
      if (widget.bannerImagePath != null) {
        await _eventRepo.uploadCover(event.id, widget.bannerImagePath!);
      }

      // Create agenda items
      {
        for (int i = 0; i < _agendaItems.length; i++) {
          final item = _agendaItems[i];
          final agendaTime = _parseFormattedDate(item.dateTime);
          await _eventRepo.createAgendaItem(
            event.id,
            title: item.title,
            description: item.description.isNotEmpty ? item.description : null,
            location: item.location.isNotEmpty ? item.location : null,
            startTime: agendaTime != null ? agendaTime.toUtc().toIso8601String() : '',
            sortOrder: i,
          );
        }
      }

      if (mounted) {
        Navigator.of(context)
          ..pop() // step 2
          ..pop(); // step 1 → back to home
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<SelectedLocation>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationPickerPage(
                            initialLocation: _selectedLocation?.latLng,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() => _selectedLocation = result);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        color: AppColors.buttonGrey,
                        child: _selectedLocation != null
                            ? Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      'https://tile.openstreetmap.org/15/'
                                      '${_lngToTileX(_selectedLocation!.latLng.longitude, 15)}/'
                                      '${_latToTileY(_selectedLocation!.latLng.latitude, 15)}.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const SizedBox(),
                                    ),
                                  ),
                                  Container(color: Colors.white.withValues(alpha: 0.3)),
                                  Center(
                                    child: Icon(Icons.location_on, size: 36, color: AppColors.primary),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 12,
                                    right: 12,
                                    child: Text(
                                      _selectedLocation!.displayName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
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

                  AgendaTimeline(
                    items: _agendaItems,
                    trailingBuilder: (context, index) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _editAgendaItem(index),
                          child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _deleteAgendaItem(index),
                          child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: AppPrimaryButton(
              label: _saving ? 'Creating...' : 'Confirm',
              onPressed: _saving ? null : _confirm,
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
