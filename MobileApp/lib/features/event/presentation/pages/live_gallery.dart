import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/photo_repository.dart';
import 'photo_viewer_page.dart';

class LiveGalleryScreen extends StatefulWidget {
  final bool isHost;
  final String? eventId;
  final bool acceptPhotos;
  final bool isMember;
  const LiveGalleryScreen({super.key, this.isHost = false, this.eventId, this.acceptPhotos = false, this.isMember = false});

  @override
  State<LiveGalleryScreen> createState() => _LiveGalleryScreenState();
}

class _LiveGalleryScreenState extends State<LiveGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final _photoRepo = PhotoRepository();

  List<GalleryPhoto> _photos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (widget.eventId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final photos = await _photoRepo.list(widget.eventId!);
      if (mounted) setState(() { _photos = photos; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    if (widget.eventId == null) return;
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      for (final img in images) {
        try {
          final photo = await _photoRepo.upload(widget.eventId!, img.path);
          if (mounted) {
            setState(() => _photos.insert(0, photo));
          }
        } catch (_) {
          // Show user-picked photo locally as fallback
          if (mounted) {
            setState(() {
              _photos.insert(0, GalleryPhoto(
                imageFile: File(img.path),
                uploaderName: 'You',
                uploaderAvatar: '',
                uploadTime: 'Just now',
              ));
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Live Gallery',
      floatingActionButton: (widget.isMember && (widget.isHost || widget.acceptPhotos))
          ? FloatingActionButton(
              onPressed: _pickImage,
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];

                return GestureDetector(
                  onTap: () async {
                    final deleted = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoViewerPage(
                          photo: photo,
                          isHost: widget.isHost,
                          eventId: widget.eventId,
                        ),
                      ),
                    );
                    if (deleted == true) {
                      setState(() => _photos.remove(photo));
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: photo.imageFile != null
                        ? Image.file(photo.imageFile!, fit: BoxFit.cover)
                        : photo.imageUrl != null
                            ? Image.network(photo.imageUrl!, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
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