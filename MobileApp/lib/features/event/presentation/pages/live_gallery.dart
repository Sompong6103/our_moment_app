import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  // Multi-select state
  bool _selectMode = false;
  final Set<String> _selectedIds = {};
  bool _actionLoading = false;

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

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      _selectedIds.clear();
    });
  }

  void _togglePhotoSelection(GalleryPhoto photo) {
    if (photo.id == null) return;
    setState(() {
      if (_selectedIds.contains(photo.id)) {
        _selectedIds.remove(photo.id);
        if (_selectedIds.isEmpty) _selectMode = false;
      } else {
        _selectedIds.add(photo.id!);
      }
    });
  }

  void _selectAll(List<GalleryPhoto> photos) {
    setState(() {
      final ids = photos.where((p) => p.id != null).map((p) => p.id!).toSet();
      if (_selectedIds.length == ids.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(ids);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty || widget.eventId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text('Are you sure you want to delete ${_selectedIds.length} photo${_selectedIds.length == 1 ? '' : 's'}?'),
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

    if (confirmed != true || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      await _photoRepo.bulkDelete(widget.eventId!, _selectedIds.toList());
      if (mounted) {
        setState(() {
          _photos.removeWhere((p) => _selectedIds.contains(p.id));
          _faceSearchResults?.removeWhere((p) => _selectedIds.contains(p.id));
          _selectedIds.clear();
          _selectMode = false;
          _actionLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photos deleted'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete photos'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _downloadSelected(List<GalleryPhoto> photos) async {
    if (_selectedIds.isEmpty) return;

    setState(() => _actionLoading = true);
    int saved = 0;

    try {
      final selected = photos.where((p) => _selectedIds.contains(p.id)).toList();

      for (final photo in selected) {
        try {
          if (photo.imageFile != null) {
            await Gal.putImage(photo.imageFile!.path);
            saved++;
          } else if (photo.imageUrl != null) {
            final httpClient = HttpClient();
            final request = await httpClient.getUrl(Uri.parse(photo.imageUrl!));
            final response = await request.close();
            final bytes = await response.fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));
            httpClient.close();

            final dir = await getTemporaryDirectory();
            final fileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}_${saved}.jpg';
            final file = File('${dir.path}/$fileName');
            await file.writeAsBytes(bytes);
            await Gal.putImage(file.path);
            saved++;
          }
        } catch (_) {
          // Continue with next photo
        }
      }

      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _selectMode = false;
          _actionLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved $saved photo${saved == 1 ? '' : 's'} to gallery'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _actionLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save photos'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget? _buildFABs(bool showingFaceResults) {
    if (widget.isMember && (widget.isHost || widget.acceptPhotos)) {
      return Column(
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
      );
    } else if (widget.isMember) {
      return FloatingActionButton(
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
      );
    }
    return null;
  }

  Widget _buildSelectionBar(List<GalleryPhoto> displayPhotos) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.isHost) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _actionLoading || _selectedIds.isEmpty ? null : _deleteSelected,
                icon: _actionLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.delete_outline, size: 20),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red.withOpacity(0.4),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _actionLoading || _selectedIds.isEmpty ? null : () => _downloadSelected(displayPhotos),
              icon: _actionLoading && !widget.isHost
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download, size: 20),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPhotos = _faceSearchResults ?? _photos;
    final showingFaceResults = _faceSearchResults != null;

    return AppDetailScaffold(
      title: _selectMode
          ? '${_selectedIds.length} Selected'
          : (showingFaceResults ? 'My Photos' : 'Live Gallery'),
      leading: _selectMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectMode,
            )
          : null,
      actions: _selectMode
          ? [
              IconButton(
                icon: Icon(
                  _selectedIds.length == displayPhotos.where((p) => p.id != null).length
                      ? Icons.deselect
                      : Icons.select_all,
                ),
                onPressed: () => _selectAll(displayPhotos),
                tooltip: 'Select All',
              ),
            ]
          : null,
      floatingActionButton: _selectMode ? null : _buildFABs(showingFaceResults),
      bottomBar: _selectMode ? _buildSelectionBar(displayPhotos) : null,
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
                final isSelected = photo.id != null && _selectedIds.contains(photo.id);

                return GestureDetector(
                  onTap: () async {
                    if (_selectMode) {
                      _togglePhotoSelection(photo);
                      return;
                    }
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
                  onLongPress: () {
                    if (!_selectMode && photo.id != null) {
                      setState(() {
                        _selectMode = true;
                        _selectedIds.add(photo.id!);
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
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
                      if (_selectMode && photo.id != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : Colors.black38,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                isSelected ? Icons.check : null,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (_selectMode && isSelected)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            color: AppColors.primary.withOpacity(0.2),
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