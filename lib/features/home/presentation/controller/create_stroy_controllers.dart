import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';

class CreateStoryController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  Rx<String?> selectedImage = Rx<String?>(null);

  // Text editor variables
  RxBool textWidgetVisible = false.obs;
  RxBool isEditing = false.obs;
  RxString editedText = "Double tap to edit".obs;
  Rx<Offset> textPosition = Offset(100, 100).obs;
  TextEditingController textController = TextEditingController();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void onTextEditTap() {
    textWidgetVisible.value = true;
    isEditing.value = true;
  }

  void enableTextEditing() {
    textController.text = editedText.value;
    isEditing.value = true;
  }

  void saveEditedText(String value) {
    editedText.value = value.isEmpty ? "Tap to edit" : value;
    isEditing.value = false;
  }

  void updateTextPosition(Offset delta) {
    textPosition.value = Offset(
      textPosition.value.dx + delta.dx,
      textPosition.value.dy + delta.dy,
    );
  }

  void createStory(BuildContext context) async {
    if (selectedImage.value == null) {
      Get.offNamed(AppRoutes.homeNav);
    }
    final body = {'caption': editedText.value, 'type': 'image'};
    final response = await ApiService2.multipart(
      ApiEndPoint.story,
      body: body,
      image: selectedImage.value,
      isPost: true,
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
          ..showSnackBar(SnackBar(content: Text(data['message'])));
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(data['message'])));
        Get.offNamed(AppRoutes.homeNav);
      }
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
