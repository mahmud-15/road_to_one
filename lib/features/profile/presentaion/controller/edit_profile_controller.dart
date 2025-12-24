import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/features/profile/data/profile_model.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/app_log.dart';

class EditProfileController extends GetxController {
  // Profile data

  final user = Rxn<ProfileModel>();

  String interestedIn = "Socializing, Adventure, Travelling";

  // Text editing controllers
  final TextEditingController aboutMeController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController dreamJobController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController interestedInController = TextEditingController();

  File? selectedProfileImage; // Selected local image

  final allPreferences = <Preferences>[].obs;
  final selectedPref = <Preferences>[].obs;

  void updateProfileImage(BuildContext context, File image) async {
    selectedProfileImage = image;
    update();
    final response = await ApiService2.formDataImage(
      ApiEndPoint.user,
      isPost: false,
      image: image.path,
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
          ..showSnackBar(
            SnackBar(content: Text(data['message'] ?? response.statusMessage)),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(data['message'])));
      }
    }
  }

  void updateAboutMe(BuildContext context) async {
    final value = aboutMeController.text;
    user.value!.about = value;
    update();
    final response = await ApiService.patch(
      ApiEndPoint.user,
      body: {'about': value},
    );
    if (response.isSuccess) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(response.message)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  void removeProfileImage() async {
    selectedProfileImage = null;
    update();
  }

  void disposeController() {
    aboutMeController.dispose();
    userNameController.dispose();
    emailController.dispose();
    contactNoController.dispose();
    locationController.dispose();
    occupationController.dispose();
    dreamJobController.dispose();
    educationController.dispose();
    interestedInController.dispose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    user.value = Get.arguments;
    appLog("username: ${user.value?.name ?? "Not found"}");
    initial();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    disposeController();
  }

  void initial() {
    aboutMeController.text = user.value!.about;
    userNameController.text = user.value!.name;
    emailController.text = user.value!.email;
    contactNoController.text = user.value!.mobile;
    locationController.text = user.value!.location;
    occupationController.text = user.value!.occupation;
    dreamJobController.text = user.value!.dreamJob;
    educationController.text = user.value!.education;

    // write all the field of user to controller
  }

  void updateDetails(BuildContext context) async {
    user.value!.name = userNameController.text.trim();
    user.value!.email = emailController.text.trim();
    user.value!.mobile = contactNoController.text.trim();
    user.value!.location = locationController.text.trim();
    user.value!.occupation = occupationController.text.trim();
    user.value!.dreamJob = dreamJobController.text.trim();
    user.value!.education = educationController.text.trim();
    update();
    final body = {
      'name': user.value!.name,
      'mobile': user.value!.mobile,
      'location': user.value!.location,
      'occupation': user.value!.occupation,
      'dreamJob': user.value!.dreamJob,
      'education': user.value!.education,
    };
    final response = await ApiService.patch(ApiEndPoint.user, body: body);
    if (response.isSuccess) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(response.message)));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  void fetchAllPref() async {
    final url = ApiEndPoint.preferences;
    final response = await ApiService2.get(url);

    if (response != null && response.statusCode == 200) {
      allPreferences.value = (response.data['data'] as List)
          .map((e) => Preferences.fromJson(e))
          .toList();
      update();
    }
  }

  void updatePreference(BuildContext context) async {
    final body = {'preferences': user.value!.preferences};
    final response = await ApiService.patch(ApiEndPoint.user, body: body);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(response.message)));
  }
}
