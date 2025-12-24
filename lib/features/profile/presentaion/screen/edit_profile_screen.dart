import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/image/app_bar.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';
import 'package:road_project_flutter/features/home/presentation/screen/home_nav_screen.dart';
import 'package:road_project_flutter/features/profile/data/profile_model.dart';
import 'package:road_project_flutter/features/profile/presentaion/controller/profile_controller.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'dart:io';

import '../../../../component/text/common_text.dart';
import '../controller/edit_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  // List<String> interests = ['Socializing', 'Travelling', 'Adventure'];
  TextEditingController newInterestController = TextEditingController();

  @override
  void dispose() {
    newInterestController.dispose();
    super.dispose();
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(EditProfileController controller) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2d2d2d),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.white),
              title: const Text(
                'Camera',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  controller.updateProfileImage(context, File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  controller.updateProfileImage(context, File(image.path));
                }
              },
            ),
            if (controller.selectedProfileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  controller.removeProfileImage();

                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.upcolor,
      appBar: AppBarNew(
        title: "Edit Profile",
        onBackPressed: () {
          HomeNavController().changeIndex(1);
          Get.toNamed(AppRoutes.homeNav);
        },
      ),
      body: SingleChildScrollView(
        child: GetBuilder(
          init: EditProfileController(),
          builder: (controller) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, color: AppColors.backgroudColor),
              // Upload Photo Section
              Padding(
                padding: EdgeInsets.all(20),
                child: CommonText(
                  text: "Upload Photo",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white50,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: () => _pickImage(controller),
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[800],
                          ),
                          child: ClipOval(
                            child: controller.selectedProfileImage != null
                                ? Image.file(
                                    controller.selectedProfileImage!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : Image.network(
                                    ApiEndPoint.imageUrl +
                                        controller.user.value!.image,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        AppString.defaultProfilePic,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.upcolor,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(height: 20, color: AppColors.backgroudColor),

              // About Me Section
              _buildSectionHeader(
                'About me',
                () => _showAboutMeDialog(controller),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: "Update short description about your self",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white700,
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CommonText(
                        text: controller.user.value?.about ?? "",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.left,
                        color: AppColors.white700,
                        maxLines: 8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Details Section
              _buildSectionHeader(
                'Details',
                () => _showDetailsDialog(controller),
              ),
              SizedBox(height: 14.h),
              _buildDetailItem(
                'User Name',
                controller.user.value?.name ?? "N/A",
                controller.userNameController,
              ),
              SizedBox(height: 8.h),
              _buildDetailItem(
                'E-mail',
                controller.user.value?.email ?? "N/A",
                controller.emailController,
              ),
              SizedBox(height: 8.h),
              _buildDetailItem(
                'Contact no',
                controller.user.value?.mobile ?? "N/A",
                controller.contactNoController,
              ),
              SizedBox(height: 8.h),
              _buildDetailItem(
                'Location',
                controller.user.value?.location ?? "N/A",
                controller.locationController,
              ),
              SizedBox(height: 8.h),
              _buildDetailItem(
                'Occupations',
                controller.user.value?.occupation ?? "N/A",
                controller.occupationController,
              ),
              SizedBox(height: 8.h),
              _buildDetailItem(
                'Dream Job',
                controller.user.value?.dreamJob ?? "N/A",
                controller.dreamJobController,
              ),
              SizedBox(height: 8.h),
              _buildDetailItem(
                'Education',
                controller.user.value?.education ?? "N/A",
                controller.educationController,
              ),
              SizedBox(height: 24.h),

              // Interested In Section
              _buildSectionHeader(
                'Interested in',
                () => _showInterestedInDialog(controller),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    ...List.generate(controller.user.value!.preferences.length, (
                      index,
                    ) {
                      final value =
                          controller.user.value!.preferences[index].name;
                      return CommonText(
                        text:
                            "$value${index == controller.user.value!.preferences.length - 1 ? "" : ", "}",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white700,
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            text: title,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.white50,
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_calendar_rounded,
              size: 16,
              color: Colors.grey,
            ),
            label: CommonText(
              text: "Edit",
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.white700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            text: label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.white600,
          ),
          Expanded(
            child: CommonText(
              text: value,
              fontSize: 12.sp,
              textAlign: TextAlign.right,
              fontWeight: FontWeight.w400,
              color: AppColors.white600,
            ),
          ),
        ],
      ),
    );
  }

  // About Me Dialog
  void _showAboutMeDialog(EditProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'About me',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3d3d3d),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: controller.aboutMeController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Share your thoughts',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateAboutMe(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFb4ff39),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Details Dialog
  void _showDetailsDialog(EditProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Update Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailTextField('User Name', controller.userNameController),
              const SizedBox(height: 12),
              _buildDetailTextField('email', controller.emailController),
              const SizedBox(height: 12),
              _buildDetailTextField(
                'Contact no',
                controller.contactNoController,
              ),
              const SizedBox(height: 12),
              _buildDetailTextField('Location', controller.locationController),
              const SizedBox(height: 12),
              _buildDetailTextField(
                'Occupations',
                controller.occupationController,
              ),
              const SizedBox(height: 12),
              _buildDetailTextField('dream job', controller.dreamJobController),
              const SizedBox(height: 12),
              _buildDetailTextField(
                'Education',
                controller.educationController,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateDetails(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFb4ff39),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Details',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTextField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Interested In Dialog
  void _showInterestedInDialog(EditProfileController controller) {
    controller.fetchAllPref();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF2d2d2d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Interested in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.user.value!.preferences.map((interest) {
                    return Chip(
                      label: Text(interest.name),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                      onDeleted: () {
                        setDialogState(() {
                          controller.user.value!.preferences.remove(interest);
                        });
                      },
                      backgroundColor: const Color(0xFF3d3d3d),
                      labelStyle: const TextStyle(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newInterestController,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Socializing',
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (newInterestController.text.isNotEmpty) {
                            setDialogState(() {
                              // controller.user.value!.preferences.add(
                              //   newInterestController.text,
                              // );
                              newInterestController.clear();
                            });
                          }
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // controller.interestedIn = interests.join(', ');
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFb4ff39),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
