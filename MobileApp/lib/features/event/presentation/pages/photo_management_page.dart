import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../../../core/widgets/segment_button.dart';

class PhotoManagementPage extends StatefulWidget {
  const PhotoManagementPage({super.key});

  @override
  State<PhotoManagementPage> createState() => _PhotoManagementPageState();
}

class _PhotoManagementPageState extends State<PhotoManagementPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Pending', 'Approved'];

  // Mock photo data
  final List<Map<String, dynamic>> _photos = List.generate(12, (i) => {
    'url': 'https://picsum.photos/seed/${i + 100}/400',
    'uploader': 'Guest ${i + 1}',
    'time': '${i + 1}m ago',
    'approved': i % 3 != 1,
  });

  final Set<int> _selected = {};

  void _toggleSelect(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  List<Map<String, dynamic>> get _filteredPhotos {
    if (_selectedTab == 1) return _photos.where((p) => !p['approved']).toList();
    if (_selectedTab == 2) return _photos.where((p) => p['approved']).toList();
    return _photos;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPhotos;

    return AppDetailScaffold(
      title: 'Photos',
      actions: _selected.isNotEmpty
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () => setState(() => _selected.clear()),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.buttonGrey,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ]
          : null,
      child: Column(
        children: [
          // Stats bar
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatLabel(value: '${_photos.length}', label: 'Total'),
                Container(width: 1, height: 28, color: AppColors.primary.withValues(alpha: 0.2)),
                _StatLabel(value: '${_photos.where((p) => p['approved']).length}', label: 'Approved'),
                Container(width: 1, height: 28, color: AppColors.primary.withValues(alpha: 0.2)),
                _StatLabel(value: '${_photos.where((p) => !p['approved']).length}', label: 'Pending'),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.segmentBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  return Expanded(
                    child: SegmentButton(
                      title: _tabs[i],
                      selected: _selectedTab == i,
                      onTap: () => setState(() => _selectedTab = i),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Action bar when selected
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text(
                    '${_selected.length} selected',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Approve',
                    color: const Color(0xFF4CAF50),
                    onTap: () => setState(() => _selected.clear()),
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: AppColors.danger,
                    onTap: () => setState(() => _selected.clear()),
                  ),
                ],
              ),
            ),

          // Photo grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 64, color: AppColors.iconInactive),
                        const SizedBox(height: 12),
                        Text('No photos yet', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final photo = filtered[index];
                      final originalIndex = _photos.indexOf(photo);
                      final isSelected = _selected.contains(originalIndex);

                      return GestureDetector(
                        onTap: () {
                          if (_selected.isNotEmpty) {
                            _toggleSelect(originalIndex);
                          }
                        },
                        onLongPress: () => _toggleSelect(originalIndex),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(photo['url'], fit: BoxFit.cover),
                            ),

                            // Pending badge
                            if (!photo['approved'])
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Pending', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ),

                            // Selected overlay
                            if (isSelected)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  child: const Center(
                                    child: Icon(Icons.check_circle, size: 32, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String value;
  final String label;
  const _StatLabel({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
