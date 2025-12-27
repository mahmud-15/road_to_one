import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/config/route/app_routes.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';

class DeleteController extends GetxController {
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final isDeleting = false.obs;

  void _closeOverlay<T>({T? result}) {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;
    Navigator.of(ctx, rootNavigator: true).pop(result);
  }

  void _safeSnackbar(
    String title,
    String message, {
    required Color backgroundColor,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.key.currentContext ?? Get.context;
      if (context == null) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('$title: $message'),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 2),
          ),
        );
    });
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void deleteAccount() {
    if (passwordController.text.isEmpty) {
      _safeSnackbar(
        'Error',
        'Please enter your password',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Show confirmation dialog
    Get.dialog(
      Dialog(
        backgroundColor: Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Account Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Are you sure you want to delete\nyour account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _closeOverlay(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _closeOverlay();
                        _confirmDelete();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _confirmDelete() async {
    if (isDeleting.value) return;
    isDeleting.value = true;
    try {
      final password = passwordController.text.trim();
      final response = await ApiService.delete(
        ApiEndPoint.deleteAccount,
        body: {
          'password': password,
        },
      );

      debugPrint(
        'DELETE_ACCOUNT statusCode=${response.statusCode} data=${response.data}',
      );

      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok) {
        final data = response.data;
        final message = data['message'] != null
            ? data['message'].toString()
            : response.message;
        _safeSnackbar(
          'Failed',
          message,
          backgroundColor: Colors.red,
        );
        return;
      }

      _safeSnackbar(
        'Success',
        'Your account has been deleted',
        backgroundColor: Colors.green,
      );

      await LocalStorage.removeAllPrefData();
      Get.offAllNamed(AppRoutes.signIn);
    } catch (_) {
      _safeSnackbar(
        'Failed',
        'Delete failed',
        backgroundColor: Colors.red,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}