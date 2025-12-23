import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/component/button/common_button.dart';
import 'package:road_project_flutter/component/text/common_text.dart';
import 'package:road_project_flutter/features/auth/signin/presentation/controller/sign_in_controller.dart';
import 'package:road_project_flutter/utils/app_bar/custom_appbars.dart';
import 'package:road_project_flutter/utils/app_utils.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';

import '../../../../../config/route/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _isRemeberMe = ValueNotifier(false);

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Back Button
              CustomAppBar(title: "", showBackButton: true),

              SizedBox(height: 20.h),

              /// Title
              Text(
                "Let's sign you in",
                style: TextStyle(
                  fontSize: 36.sp,
                  color: AppColors.white50,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 8.h),

              /// Subtitle
              Text(
                "Sign in and elevate your fitness journey with us",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.white700,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 40.h),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Email Label
                    Text(
                      "Email address",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.white50,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    /// Email Input
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: "Enter email address",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A1A),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 0,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade800),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade800),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFD4FF00),
                            width: 2,
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      validator: (value) {
                        return Utils.emailValidator(value);
                      },
                    ),

                    SizedBox(height: 24.h),

                    /// Password Label
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.white50,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    /// Password Input
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A1A),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 0,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade800),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade800),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFD4FF00),
                            width: 2,
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      validator: (value) {
                        return Utils.passwordValidator(value);
                      },
                    ),

                    SizedBox(height: 16.h),

                    /// Remember me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Theme(
                              data: ThemeData(
                                checkboxTheme: CheckboxThemeData(
                                  fillColor: WidgetStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.transparent;
                                    }
                                    return Colors.transparent;
                                  }),
                                  checkColor: WidgetStateProperty.all(
                                    Color(0xFFD4FF00),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade700,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: _isRemeberMe,
                                builder: (context, value, child) => Checkbox(
                                  value: value,
                                  checkColor: AppColors.primaryColor,
                                  side: BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                  onChanged: (value) {
                                    _isRemeberMe.value = value!;
                                  },
                                ),
                              ),
                            ),
                            Text(
                              "Remember me",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.white50,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.forgetPasswordScreen);
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    /// Sign In Button
                    GetBuilder(
                      init: SignInController(),
                      builder: (controller) => controller.isLoading.value
                          ? Center(child: CircularProgressIndicator())
                          : CommonButton(
                              titleText: "Sign In",
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  controller.signInUser(
                                    context,
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    isRememberMe: _isRemeberMe.value,
                                  );
                                  // Get.toNamed(AppRoutes.homeNav);
                                }
                              },
                            ),
                    ),

                    SizedBox(height: 30.h),

                    /// OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFFA1A1A1),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xFFA1A1A1),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color(0xFFA1A1A1),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    /// Continue with Google Button
                    _SocialButton(
                      icon: "assets/images/google_image.png",
                      text: "Continue with Google",
                      iconColor: Colors.white,
                      onTap: () {
                        print("Google sign in tapped");
                      },
                    ),

                    SizedBox(height: 16.h),

                    /// Continue with Phone Button
                    _SocialButton(
                      icon: "assets/images/call.png",
                      text: "Continue with Phone",
                      iconColor: Color(0xFF4A9EFF),
                      onTap: () {
                        Get.toNamed(AppRoutes.phoneSignupScreen);
                      },
                    ),

                    SizedBox(height: 30.h),

                    /// Sign Up Text
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: "Sign up",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed(AppRoutes.signUp);
                                },
                              style: TextStyle(
                                color: Color(0xFFD4FF00),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Social Sign In Button Widget
class _SocialButton extends StatelessWidget {
  final String icon;
  final String text;
  final Color iconColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.grey.shade800, width: 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, height: 24.h, width: 24.w),
              SizedBox(width: 12.w),
              CommonText(
                text: text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
