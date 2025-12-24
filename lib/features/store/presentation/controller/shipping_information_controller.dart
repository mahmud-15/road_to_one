// Path: lib/screens/store/controller/shipping_information_controller.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;

import '../../../../config/api/api_end_point.dart';
import '../../../../services/storage/storage_services.dart';
import '../screen/pay_screen.dart';

class ShippingInformationController extends GetxController {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  var totalAmount = 0.0.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get total amount from arguments or calculate from cart
    if (Get.arguments != null && Get.arguments['total'] != null) {
      totalAmount.value = Get.arguments['total'];
    } else {
      // Calculate from cart items if needed
      totalAmount.value = 87.00; 
    }

   
    loadSavedData();
  }

  void loadSavedData() {
    // Load from local storage or user profile
    addressController.text = 'House C17/A, B Block, Dhanmondi Dhaka Bangladesh';
    contactController.text = '+61 1234 5678 910';
  }

  Future<void> proceedToPay() async {
    // Validate inputs
    if (addressController.text.trim().isEmpty) {
      _safeSnackbar(
        'Error',
        'Please enter your address',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (contactController.text.trim().isEmpty) {
      _safeSnackbar(
        'Error',
        'Please enter your contact number',
        backgroundColor: Colors.red,
      );
      return;
    }

    final ok = await _updateShippingInfo();
    if (!ok) {
      return;
    }

    Get.to(
      PaymentScreen(
        address: addressController.text,
        contact: contactController.text,
        totalAmount: totalAmount.value,
      ),
    );
  }

  Future<bool> _updateShippingInfo() async {
    isSaving.value = true;
    try {
      final shippingAddress = {
        'address': addressController.text.trim(),
        'contact_number': contactController.text.trim(),
        'country': '',
        'city': '',
        'zip': '',
      };

      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer ${LocalStorage.token}',
        'Content-Type': 'multipart/form-data',
      };

      final formData = FormData.fromMap({
        'shipping_address': jsonEncode(shippingAddress),
      });

      final response = await dio.patch(
        ApiEndPoint.user,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        _safeSnackbar(
          'Failed',
          'Could not update shipping information.',
          backgroundColor: Colors.red,
        );
        return false;
      }

      _safeSnackbar(
        'Success',
        'Shipping information updated.',
        backgroundColor: Colors.green,
      );
      return true;
    } catch (_) {
      _safeSnackbar(
        'Failed',
        'Could not update shipping information.',
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
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

  @override
  void onClose() {
    addressController.dispose();
    contactController.dispose();
    super.onClose();
  }
}