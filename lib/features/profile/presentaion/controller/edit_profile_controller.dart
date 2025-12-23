import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/features/profile/data/profile_model.dart';
import 'package:road_project_flutter/features/profile/presentaion/controller/profile_controller.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';
import 'package:road_project_flutter/utils/log/app_log.dart';

class EditProfileController extends GetxController {
  // Profile data

  final user = Rxn<ProfileModel>();

  String profileImageUrl =
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop";
  final aboutMe = "".obs;
  String userName = "New Jack";
  String email = "Gabriel01@gmail.com";
  String contactNo = "+8801050000000";
  String location = "Dhaka, Bangladesh";
  String occupation = "Business";
  String dreamJob = "Pilot";
  String education = "Graduated";
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

  void updateProfileImage(File image) {
    selectedProfileImage = image;
    update();
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

  void removeProfileImage() {
    selectedProfileImage = null;
    update();
  }

  EditProfileController() {
    // Initialize controllers with current values
    aboutMeController.text = aboutMe.value;
    userNameController.text = userName;
    emailController.text = email;
    contactNoController.text = contactNo;
    locationController.text = location;
    occupationController.text = occupation;
    dreamJobController.text = dreamJob;
    educationController.text = education;
    interestedInController.text = interestedIn;
  }

  void saveProfile() {
    // Update values from controllers
    aboutMe.value = aboutMeController.text;
    userName = userNameController.text;
    email = emailController.text;
    contactNo = contactNoController.text;
    location = locationController.text;
    occupation = occupationController.text;
    dreamJob = dreamJobController.text;
    education = educationController.text;
    interestedIn = interestedInController.text;

    print("Profile saved successfully!");
  }

  void dispose() {
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

  void initial() {
    aboutMeController.text = user.value!.about;
    userNameController.text = user.value!.name;
    emailController.text = user.value!.email;
    contactNoController.text = user.value!.mobile;
    locationController.text = user.value!.location;

    // write all the field of user to controller
  }

  void updateProfile(
    BuildContext context, {
    String? name,
    String? mobile,
    String? location,
    String? occupation,
    String? dreamJob,
    String? education,
    String? image,
    String? about,
    String? preferences1,
    String? preferences2,
    String? profileMode,
    Map<String?, dynamic>? shippingAddress,
  }) async {
    final body = {
      'name': name,
      'mobile': mobile,
      'location': location,
      'occupation': occupation,
      'dreamJob': dreamJob,
      'education': education,
      'image': image,
      'about': about,
      'preferences[0]': preferences1,
      'preferences[1]': preferences2,
      'profileMode': profileMode,
      'shipping_address': shippingAddress,
    };

    final header = {
      'Content-Type': "multipart/form-data",
      'Authorization': "Bearer ${LocalStorage.token}",
    };

    final response = await ApiService.patch(
      ApiEndPoint.user,
      body: body,
      header: header,
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(response.message)));
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(response.message)));
    }
  }
}
