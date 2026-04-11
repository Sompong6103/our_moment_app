import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import 'photo_viewer_page.dart';

class LiveGalleryScreen extends StatefulWidget {
  final bool isHost;
  const LiveGalleryScreen({super.key, this.isHost = false});

  @override
  State<LiveGalleryScreen> createState() => _LiveGalleryScreenState();
}

class _LiveGalleryScreenState extends State<LiveGalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<String> _uploaderNames = [
    'Krittanai N.',
    'Cheewanon S.',
    'Somchai P.',
    'Ploy R.',
    'Nattha K.',
    'Beam W.',
    'Fern T.',
    'Bank S.',
  ];

  late final List<GalleryPhoto> _samplePhotos = List.generate(8, (i) {
    return GalleryPhoto(
      imageUrl: 'https://picsum.photos/seed/${i + 50}/400',
      uploaderName: _uploaderNames[i],
      uploaderAvatar: 'https://i.pravatar.cc/150?u=gallery$i',
      uploadTime: '${(i % 4) + 1}h ago',
    );
  });

  final List<GalleryPhoto> _pickedPhotos = [];

  Future<void> _pickImage() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _pickedPhotos.insertAll(
          0,
          images.map((x) => GalleryPhoto(
                imageFile: File(x.path),
                uploaderName: 'You',
                uploaderAvatar: 'https://i.pravatar.cc/150?u=me',
                uploadTime: 'Just now',
              )),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Live Gallery',
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      child: Column(
        children: [
          // --- ส่วนของ Grid รูปภาพ ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 คอลัมน์ตามรูป
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1, // รูปทรงจัตุรัส
              ),
              itemCount: _pickedPhotos.length + _samplePhotos.length,
              itemBuilder: (context, index) {
                final allPhotos = [..._pickedPhotos, ..._samplePhotos];
                final photo = allPhotos[index];

                return GestureDetector(
                  onTap: () async {
                    final deleted = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoViewerPage(
                          photo: photo,
                          isHost: widget.isHost,
                        ),
                      ),
                    );
                    if (deleted == true) {
                      setState(() {
                        _pickedPhotos.remove(photo);
                        _samplePhotos.remove(photo);
                      });
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: photo.imageFile != null
                        ? Image.file(photo.imageFile!, fit: BoxFit.cover)
                        : Image.network(photo.imageUrl!, fit: BoxFit.cover),
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