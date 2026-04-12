import 'package:flutter/material.dart';

import '../../../../core/services/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/guest_repository.dart';
import 'photo_viewer_page.dart';

class GuestProfileScreen extends StatefulWidget {
  final String eventId;
  final String guestId;
  final String name;
  final String email;
  final String imageUrl;

  const GuestProfileScreen({
    super.key,
    required this.eventId,
    required this.guestId,
    required this.name,
    required this.email,
    required this.imageUrl,
  });

  @override
  State<GuestProfileScreen> createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<GuestProfileScreen> {
  final _guestRepo = GuestRepository();
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _guestRepo.getDetail(widget.eventId, widget.guestId);
      if (mounted) setState(() { _detail = detail; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day}-${months[dt.month - 1]}-${dt.year}';
  }

  String _formatDateTime(String? iso) {
    if (iso == null) return '-';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}-${months[dt.month - 1]}-${dt.year} | $hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final inEvent = _detail?['status'] == 'checked_in';
    final joinDate = _formatDate(_detail?['joinedAt'] ?? _detail?['createdAt']);
    final checkInTime = _formatDateTime(_detail?['checkedInAt']);
    final wish = (_detail?['wish'] is Map) ? (_detail!['wish']['message'] as String? ?? '') : '';
    final photos = (_detail?['photos'] as List?) ?? [];

    return AppDetailScaffold(
      title: 'Guests Profile',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วน Header Profile
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(widget.imageUrl),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.email,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.person_pin,
                        size: 22,
                        color: inEvent ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        inEvent ? 'In event' : 'Registered',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: inEvent ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ฟิลด์ข้อมูลต่างๆ
            _buildInfoField('Join event date', joinDate),
            _buildInfoField('Check in time', checkInTime),
            if (wish.isNotEmpty)
              _buildInfoField('Wishes', '"$wish"', isMultiline: true),
            // Uploaded Photos
            if (photos.isNotEmpty) ...[
              Text(
                'Uploaded Photos',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${photos.length} photos',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final p = photos[index] as Map<String, dynamic>;
                  final url = p['imageUrl'] as String? ?? '';
                  final fullUrl = url.startsWith('http') ? url : '${ApiConfig.uploadsUrl}/$url';
                  final photo = GalleryPhoto(
                    id: p['id'],
                    imageUrl: fullUrl,
                    uploaderName: widget.name,
                    uploaderAvatar: widget.imageUrl,
                    uploadTime: '',
                  );
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoViewerPage(photo: photo, eventId: widget.eventId),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(fullUrl, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget ช่วยสร้างช่องแสดงข้อมูล
  Widget _buildInfoField(
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget สำหรับแถบรายชื่อในหน้าแรก
