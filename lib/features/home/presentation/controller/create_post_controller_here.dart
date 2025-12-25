import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'dart:io';

import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/error_log.dart';

class CreatePostController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);
  final captionController = TextEditingController();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void createPost(BuildContext context) async {
    try {
      if (selectedImage.value != null && captionController.text.isNotEmpty) {
        final body = {
          'caption': captionController.text.trim(),
          'type': 'image',
        };
        final response = await ApiService2.multipart(
          ApiEndPoint.allPost,
          isPost: true,
          body: body,
          image: selectedImage.value!.path,
        );
        if (response == null) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(AppString.someThingWrong)));
        } else {
          final data = response.data;
          if (response.statusCode != 200) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(response.data['message'])));
          } else {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(response.data['message'])));
            Get.back();
          }
        }
        // Handle post creation
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text("Please add image and caption")),
          );
      }
    } catch (e) {
      errorLog("error in create post: $e");
    }
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}
