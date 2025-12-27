import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/features/profile/data/profile_model.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'package:road_project_flutter/utils/log/app_log.dart';
import 'package:road_project_flutter/utils/log/error_log.dart';

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
  final isLoadingPref = false.obs;

  void updateProfileImage(BuildContext context, File image) async {
    selectedProfileImage = image;
    update();
    try {
      final response = await ApiService2.multipart(
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
              SnackBar(
                content: Text(data['message'] ?? response.statusMessage),
              ),
            );
        } else {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(data['message'])));
        }
      }
    } catch (e) {
      errorLog("error in update profile pic: $e");
    }
  }

  void updateAboutMe(BuildContext context) async {
    final value = aboutMeController.text;
    user.value!.about = value;
    update();
    try {
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
    } catch (e) {
      errorLog("error in update about me: $e");
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

    selectedPref
      ..clear()
      ..addAll(user.value!.preferences);

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
    try {
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
    } catch (e) {
      errorLog("error in updateDetails: $e");
    }
  }

  Future<void> fetchAllPref({int page = 1, int limit = 100}) async {
    if (isLoadingPref.value) return;
    isLoadingPref.value = true;
    try {
      final url = '${ApiEndPoint.preferences}?page=$page&limit=$limit';
      final response = await ApiService2.get(url);

      if (response != null && response.statusCode == 200) {
        allPreferences.value = (response.data['data'] as List)
            .map((e) => Preferences.fromJson(e))
            .toList();
        update();
      }
    } catch (e) {
      errorLog("error in fetch all pref: $e");
    } finally {
      isLoadingPref.value = false;
    }
  }

  List<Preferences> suggestionsFor(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allPreferences;
    return allPreferences
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  void addPreference(Preferences pref) {
    final exists = selectedPref.any((p) => p.id == pref.id);
    if (exists) return;
    selectedPref.add(pref);
    final u = user.value;
    if (u == null) return;
    u.preferences
      ..clear()
      ..addAll(selectedPref);
    update();
  }

  void removePreference(Preferences pref) {
    selectedPref.removeWhere((p) => p.id == pref.id);
    final u = user.value;
    if (u == null) return;
    u.preferences
      ..clear()
      ..addAll(selectedPref);
    update();
  }

  void updatePreference(BuildContext context) async {
    try {
      final body = {
        'preferences': selectedPref.map((e) => e.id).toList(),
      };
      final response = await ApiService.patch(ApiEndPoint.user, body: body);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(response.message)));
    } catch (e) {
      errorLog("error in update preference: $e");
    }
  }
}
