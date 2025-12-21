import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:road_project_flutter/component/text/common_text.dart';
import 'package:road_project_flutter/utils/app_utils.dart';
import '../../../../../utils/constants/app_colors.dart';

class SignUpAllField extends StatefulWidget {
  const SignUpAllField({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
  });
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  @override
  State<SignUpAllField> createState() => _SignUpAllFieldState();
}

class _SignUpAllFieldState extends State<SignUpAllField> {
  final isPasswordVisible = ValueNotifier(false);
  final isConfirmPasswordVisible = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Name Field
        CommonText(
          text: "Name",
          fontSize: 14.sp,
          color: AppColors.white50,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: widget.nameController,
          hintText: "Enter name",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }

            return Utils.commonValidator(value);
          },
        ),

        SizedBox(height: 20.h),

        /// Email Field
        CommonText(
          text: "Email Address",
          fontSize: 14.sp,
          color: AppColors.white50,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: widget.emailController,
          hintText: "Enter email address",
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            return Utils.emailValidator(value);
          },
        ),

        SizedBox(height: 20.h),

        /// Password Field
        CommonText(
          text: "Password",
          fontSize: 14.sp,
          color: AppColors.white50,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        ValueListenableBuilder(
          valueListenable: isPasswordVisible,
          builder: (context, value, child) => _buildTextField(
            controller: widget.passwordController,
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
                color: Color(0xFF757575),
                size: 20.sp,
              ),
              onPressed: () {
                isPasswordVisible.value = !isPasswordVisible.value;
              },
            ),
          ),
        ),

        SizedBox(height: 20.h),

        /// Confirm Password Field
        CommonText(
          text: "Confirm Password",
          fontSize: 14.sp,
          color: AppColors.white50,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        ValueListenableBuilder(
          valueListenable: isConfirmPasswordVisible,
          builder: (context, value, child) => _buildTextField(
            controller: widget.confirmController,
            hintText: "Enter Password",
            obscureText: !value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != widget.passwordController.text.trim()) {
                return 'Passwords do not match';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Color(0xFF757575),
                size: 20.sp,
              ),
              onPressed: () {
                isConfirmPasswordVisible.value =
                    !isConfirmPasswordVisible.value;
              },
            ),
          ),
        ),
      ],
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
          color: Color(0xFF757575),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Color(0xFF424242), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Color(0xFF424242), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Color(0xFF757575), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: validator,
    );
  }
}
