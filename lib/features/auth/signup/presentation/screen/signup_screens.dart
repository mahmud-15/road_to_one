import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/features/auth/signup/presentation/controller/sign_up_controller.dart';
import 'package:road_project_flutter/utils/app_bar/custom_appbars.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../widgets/already_accunt_rich_text.dart';
import '../widgets/sign_up_all_filed.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(title: "", showBackButton: true),

              SizedBox(height: 20.h),

              /// Sign up Title
              const CommonText(
                text: "Sign up",
                fontSize: 36,
                color: AppColors.white50,
                fontWeight: FontWeight.w500,
              ),

              SizedBox(height: 8.h),

              /// Subtitle
              const CommonText(
                text: "Sign up and elevate your fitness journey with us",
                fontSize: 14,
                color: AppColors.white700,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.start,
                maxLines: 2,
              ),

              SizedBox(height: 32.h),

              /// Form Fields
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// All Text Fields here
                    SignUpAllField(
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmController: _confirmPasswordController,
                    ),

                    SizedBox(height: 32.h),

                    /// Sign Up Button
                    GetBuilder(
                      init: SignUpController(),
                      builder: (controller) => CommonButton(
                        titleText: "Sign up",
                        isLoading: controller.isLoading.value,
                        buttonColor: AppColors.primaryColor,
                        titleColor: AppColors.black,
                        buttonRadius: 500,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            controller.signUpUser(
                              context,
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              confirmPassword: _confirmPasswordController.text
                                  .trim(),
                            );
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 24.h),

                    /// Already have an account
                    const AlreadyAccountRichText(),

                    SizedBox(height: 30.h),
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
