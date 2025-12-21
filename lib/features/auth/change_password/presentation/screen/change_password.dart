import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/button/common_button.dart';
import 'package:road_project_flutter/features/auth/change_password/presentation/controller/change_password_controller_here.dart';
import 'package:road_project_flutter/utils/app_bar/custom_appbars.dart';
import 'package:road_project_flutter/utils/app_utils.dart';

import '../../../../../component/text/common_text.dart';
import '../../../../../utils/constants/app_colors.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _isPasswordVisible = ValueNotifier(false);
  final _isConfirmPasswordVisible = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: ""),
                SizedBox(height: 20.h),

                const CommonText(
                  text: "Set New Password",
                  fontSize: 36,
                  color: AppColors.white50,
                  fontWeight: FontWeight.w500,
                ),

                SizedBox(height: 8.h),

                const CommonText(
                  text: "Please Set Your New Password",
                  fontSize: 14,
                  color: AppColors.white400,
                  fontWeight: FontWeight.w400,
                ),

                SizedBox(height: 30.h),

                /// Password Field
                CommonText(
                  text: "New Password",
                  fontSize: 14.sp,
                  color: AppColors.white50,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 8.h),

                ValueListenableBuilder(
                  valueListenable: _isPasswordVisible,
                  builder: (context, value, child) => _buildTextField(
                    controller: _newPasswordController,
                    hintText: "Enter Password",
                    obscureText: !value,
                    validator: (value) {
                      return Utils.passwordValidator(value);
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF757575),
                        size: 20.sp,
                      ),
                      onPressed: () =>
                          _isPasswordVisible.value = !_isPasswordVisible.value,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                /// Confirm Password Field
                CommonText(
                  text: "Confirm New Password",
                  fontSize: 14.sp,
                  color: AppColors.white50,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 8.h),

                ValueListenableBuilder(
                  valueListenable: _isConfirmPasswordVisible,
                  builder: (context, value, child) => _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: "Enter Password",
                    obscureText: !value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the password again";
                      } else if (value != _newPasswordController.text.trim()) {
                        return "Passwords do not match";
                      } else {
                        return null;
                      }
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF757575),
                        size: 20.sp,
                      ),
                      onPressed: () => _isConfirmPasswordVisible.value =
                          !_isConfirmPasswordVisible.value,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                GetBuilder(
                  init: SetPasswordController(),
                  builder: (controller) => CommonButton(
                    titleText: "Change Password",
                    onTap: () {
                      controller.verifyPassword(
                        context,
                        newPassword: _newPasswordController.text.trim(),
                        confirmPassword: _confirmPasswordController.text.trim(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.roboto(
        color: AppColors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.roboto(
          color: const Color(0xFF757575),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF424242), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF424242), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF757575), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: validator,
    );
  }
}
