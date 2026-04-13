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

  // Face search state
  List<GalleryPhoto>? _faceSearchResults;
  bool _faceSearching = false;

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

  Future<void> _searchByFace() async {
    if (widget.eventId == null) return;

    // Show bottom sheet to choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Find My Photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Take a selfie or choose a photo of yourself',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take a Selfie'),
                subtitle: const Text('Use front camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Album'),
                subtitle: const Text('Select an existing photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final image = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (image == null) return;

    setState(() => _faceSearching = true);

    try {
      final results = await _photoRepo.searchByFace(widget.eventId!, image.path);
      if (mounted) {
        setState(() {
          _faceSearchResults = results;
          _faceSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _faceSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Face search failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearFaceSearch() {
    setState(() => _faceSearchResults = null);
  }

  @override
  Widget build(BuildContext context) {
    final displayPhotos = _faceSearchResults ?? _photos;
    final showingFaceResults = _faceSearchResults != null;

    return AppDetailScaffold(
      title: showingFaceResults ? 'My Photos' : 'Live Gallery',
      floatingActionButton: (widget.isMember && (widget.isHost || widget.acceptPhotos))
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isMember)
                  FloatingActionButton(
                    heroTag: 'face_search',
                    onPressed: _faceSearching ? null : (showingFaceResults ? _clearFaceSearch : _searchByFace),
                    backgroundColor: showingFaceResults ? Colors.grey : AppColors.primary,
                    shape: const CircleBorder(),
                    child: _faceSearching
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(
                            showingFaceResults ? Icons.close : Icons.face,
                            color: Colors.white, size: 28,
                          ),
                  ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'add_photo',
                  onPressed: _pickImage,
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ],
            )
          : (widget.isMember
              ? FloatingActionButton(
                  heroTag: 'face_search_only',
                  onPressed: _faceSearching ? null : (showingFaceResults ? _clearFaceSearch : _searchByFace),
                  backgroundColor: showingFaceResults ? Colors.grey : AppColors.primary,
                  shape: const CircleBorder(),
                  child: _faceSearching
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          showingFaceResults ? Icons.close : Icons.face,
                          color: Colors.white, size: 28,
                        ),
                )
              : null),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (showingFaceResults)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.face, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Found ${displayPhotos.length} photo${displayPhotos.length == 1 ? '' : 's'} of you',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearFaceSearch,
                    child: const Text(
                      'Show All',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: displayPhotos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showingFaceResults ? Icons.face_retouching_off : Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          showingFaceResults
                              ? 'No photos of you found'
                              : 'No photos yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
              ),
              itemCount: displayPhotos.length,
              itemBuilder: (context, index) {
                final photo = displayPhotos[index];

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