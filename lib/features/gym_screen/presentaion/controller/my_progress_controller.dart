import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';

class ProgressData {
  int workouts;
  List<PictureItem> pictures;

  ProgressData({
    required this.workouts,
    required this.pictures,
  });
}

class PictureItem {
  String imageUrl;
  String caption;
  DateTime dateAdded;

  PictureItem({
    required this.imageUrl,
    this.caption = '',
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'caption': caption,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory PictureItem.fromJson(Map<String, dynamic> json) => PictureItem(
    imageUrl: json['imageUrl'],
    caption: json['caption'] ?? '',
    dateAdded: DateTime.parse(json['dateAdded']),
  );
}
class MyProgressController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  // Reactive variables
  final _selectedTab = 0.obs;
  final _workoutCount = 0.obs;
  final _pictures = <PictureItem>[].obs;
  final isUploading = false.obs;
  final isProgressLoading = false.obs;
  final _currentGetBy = 'weekly'.obs;

  // Getters (proper encapsulation)
  int get selectedTab => _selectedTab.value;
  int get workoutCount => _workoutCount.value;
  List<PictureItem> get pictures => _pictures;
  String get currentGetBy => _currentGetBy.value;

  @override
  void onInit() {
    super.onInit();
    fetchWorkoutProgress(getBy: 'weekly');
  }

  void selectTab(int index) {
    _selectedTab.value = index;

    final getBy = switch (index) {
      0 => 'weekly',
      1 => 'monthly',
      2 => 'yearly',
      _ => 'all',
    };
    fetchWorkoutProgress(getBy: getBy);
  }

  Future<void> fetchWorkoutProgress({
    required String getBy,
    bool showLoader = true,
  }) async {
    if (isProgressLoading.value) return;
    if (showLoader) {
      isProgressLoading.value = true;
    }
    _currentGetBy.value = getBy;

    try {
      final url = '${ApiEndPoint.workoutProgress}?getBy=$getBy';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        _workoutCount.value = 0;
        _pictures.clear();
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      if (payload == null) {
        _workoutCount.value = 0;
        _pictures.clear();
        return;
      }

      final picturesCount = payload['pictures'];
      if (picturesCount is num) {
        _workoutCount.value = picturesCount.toInt();
      } else if (picturesCount is String) {
        _workoutCount.value = int.tryParse(picturesCount) ?? 0;
      } else {
        _workoutCount.value = 0;
      }

      final workoutPictures = payload['workoutPictures'];
      final list = <PictureItem>[];
      if (workoutPictures is List) {
        for (final item in workoutPictures) {
          if (item is! Map) continue;
          final rawImage = item['image']?.toString() ?? '';
          if (rawImage.isEmpty) continue;
          final imageUrl = rawImage.startsWith('http')
              ? rawImage
              : '${ApiEndPoint.imageUrl}$rawImage';
          final caption = item['caption']?.toString() ?? '';
          final dateStr = item['date']?.toString();
          DateTime? date;
          if (dateStr != null && dateStr.isNotEmpty) {
            date = DateTime.tryParse(dateStr);
          }
          list.add(
            PictureItem(
              imageUrl: imageUrl,
              caption: caption,
              dateAdded: date,
            ),
          );
        }
      }

      list.sort((a, b) {
        final ad = a.dateAdded;
        final bd = b.dateAdded;
        if (ad.isAtSameMomentAs(bd)) return 0;
        return bd.compareTo(ad);
      });

      _pictures.assignAll(list);
    } catch (_) {
      _workoutCount.value = 0;
      _pictures.clear();
    } finally {
      if (showLoader) {
        isProgressLoading.value = false;
      }
    }
  }

  Future<void> uploadWorkoutPicture({
    required String imagePath,
    required String caption,
  }) async {
    if (isUploading.value) return;

    isUploading.value = true;
    try {
      final response = await ApiService.multipart(
        ApiEndPoint.uploadWorkoutPicture,
        method: 'POST',
        imageName: 'image',
        imagePath: imagePath,
        body: {
          'caption': caption,
        },
        header: {
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String? imageUrl;
        final payload = data['data'];
        if (payload is Map) {
          final raw = payload['image']?.toString();
          if (raw != null && raw.isNotEmpty) {
            imageUrl = raw.startsWith('http')
                ? raw
                : '${ApiEndPoint.imageUrl}$raw';
          }
        }

        final newPicture = PictureItem(
          imageUrl: imageUrl ?? imagePath,
          caption: caption,
        );
        _pictures.insert(0, newPicture);

        Get.snackbar(
          'Success',
          'Workout picture uploaded successfully',
          backgroundColor: const Color(0xFFb4ff39),
          colorText: const Color(0xFF000000),
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );

        await fetchWorkoutProgress(getBy: currentGetBy, showLoader: false);
      } else {
        Get.snackbar(
          'Failed',
          'Upload failed',
          backgroundColor: const Color(0xFF424242),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Failed',
        'Upload failed: ${e.toString()}',
        backgroundColor: const Color(0xFF424242),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> addPicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Show dialog to add caption
        _showAddCaptionDialog(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        backgroundColor: const Color(0xFFFF0000),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showAddCaptionDialog(String imagePath) {
    final TextEditingController captionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text(
          'Add Caption',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: captionController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter a caption for your picture...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFb4ff39)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              final caption = captionController.text.trim();
              Get.back();
              uploadWorkoutPicture(imagePath: imagePath, caption: caption);
            },
            child: const Text(
              'Upload',
              style: TextStyle(color: Color(0xFFb4ff39)),
            ),
          ),
        ],
      ),
    );
  }

  void editCaption(int index) {
    if (index >= 0 && index < _pictures.length) {
      final TextEditingController captionController = TextEditingController(
        text: _pictures[index].caption,
      );

      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF2d2d2d),
          title: const Text(
            'Edit Caption',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: captionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter a caption for your picture...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFb4ff39)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                _pictures[index].caption = captionController.text.trim();
                _pictures.refresh();
                Get.back();
                Get.snackbar(
                  'Success',
                  'Caption updated successfully',
                  backgroundColor: const Color(0xFFb4ff39),
                  colorText: const Color(0xFF000000),
                  duration: const Duration(seconds: 2),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFFb4ff39)),
              ),
            ),
          ],
        ),
      );
    }
  }

  void deletePicture(int index) {
    if (index >= 0 && index < _pictures.length) {
      _pictures.removeAt(index);

      Get.snackbar(
        'Deleted',
        'Picture deleted successfully',
        backgroundColor: const Color(0xFF424242),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}