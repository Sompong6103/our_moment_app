import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/photo_repository.dart';

class GalleryPhoto {
  final String? id;
  final String? imageUrl;
  final File? imageFile;
  final String uploaderName;
  final String uploaderAvatar;
  final String uploadTime;

  const GalleryPhoto({
    this.id,
    this.imageUrl,
    this.imageFile,
    required this.uploaderName,
    required this.uploaderAvatar,
    required this.uploadTime,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    String uploaderName = 'Unknown';
    String uploaderAvatar = '';
    if (json['uploader'] is Map) {
      uploaderName = json['uploader']['fullName'] ?? 'Unknown';
      final rawAvatar = json['uploader']['avatarUrl'] ?? '';
      if (rawAvatar.isNotEmpty) {
        uploaderAvatar = rawAvatar.startsWith('http') ? rawAvatar : '${ApiConfig.uploadsUrl}/$rawAvatar';
      }
    }

    String? imageUrl;
    final rawUrl = json['imageUrl'] ?? json['url'];
    if (rawUrl != null) {
      final url = rawUrl as String;
      imageUrl = url.startsWith('http') ? url : '${ApiConfig.uploadsUrl}/$url';
    }

    String uploadTime = '';
    final timeStr = json['uploadedAt'] ?? json['createdAt'];
    if (timeStr != null) {
      final dt = DateTime.tryParse(timeStr);
      if (dt != null) {
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 1) {
          uploadTime = 'Just now';
        } else if (diff.inHours < 1) {
          uploadTime = '${diff.inMinutes}m ago';
        } else if (diff.inDays < 1) {
          uploadTime = '${diff.inHours}h ago';
        } else {
          uploadTime = '${diff.inDays}d ago';
        }
      }
    }

    return GalleryPhoto(
      id: json['id'],
      imageUrl: imageUrl,
      uploaderName: uploaderName,
      uploaderAvatar: uploaderAvatar,
      uploadTime: uploadTime,
    );
  }
}

class PhotoViewerPage extends StatefulWidget {
  final GalleryPhoto photo;
  final bool isHost;
  final String? eventId;

  const PhotoViewerPage({super.key, required this.photo, this.isHost = false, this.eventId});

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  bool _saving = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        if (widget.eventId != null && widget.photo.id != null) {
          await PhotoRepository().delete(widget.eventId!, widget.photo.id!);
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadImage() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final photo = widget.photo;

      if (photo.imageFile != null) {
        await Gal.putImage(photo.imageFile!.path);
      } else if (photo.imageUrl != null) {
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(Uri.parse(photo.imageUrl!));
        final response = await request.close();
        final bytes = await response.fold<List<int>>(
          [],
          (prev, chunk) => prev..addAll(chunk),
        );
        httpClient.close();

        final dir = await getTemporaryDirectory();
        final fileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Gal.putImage(file.path);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to gallery'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save image'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Photo (pinch-to-zoom) ──
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: photo.imageFile != null
                  ? Image.file(photo.imageFile!, fit: BoxFit.contain)
                  : Image.network(photo.imageUrl!, fit: BoxFit.contain),
            ),
          ),

          // ── Top bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(8, topPadding + 8, 8, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  if (widget.isHost)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: _confirmDelete,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _saving ? null : _downloadImage,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _saving
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom uploader info ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: photo.uploaderAvatar.isNotEmpty
                        ? NetworkImage(photo.uploaderAvatar)
                        : null,
                    child: photo.uploaderAvatar.isEmpty
                        ? const Icon(Icons.person, size: 20, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        photo.uploaderName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        photo.uploadTime,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
