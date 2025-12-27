// Path: lib/screens/store/controller/shipping_information_controller.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';

class ShippingInformationUpdateController extends GetxController {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postCodeController = TextEditingController();

  final RxString selectedCountry = 'United States'.obs;
  final List<String> countries = const [
    'United States',
    'Bangladesh',
    'United Kingdom',
    'Canada',
    'Australia',
  ];

  final RxBool isLoadingProfile = false.obs;
  final RxBool isSaving = false.obs;

  var totalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get total amount from arguments or calculate from cart
    if (Get.arguments != null && Get.arguments['total'] != null) {
      totalAmount.value = Get.arguments['total'];
    } else {
      // Calculate from cart items if needed
      totalAmount.value = 87.00; // Default value
    }

    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoadingProfile.value = true;
    try {
      final response = await ApiService2.get(ApiEndPoint.user);
      if (response == null || response.statusCode != 200) {
        loadSavedData();
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      final shipping = (payload is Map) ? (payload['shipping_address'] as Map?) : null;

      addressController.text = (shipping?['address'] ?? '').toString();
      contactController.text = (shipping?['contact_number'] ?? '').toString();
      cityController.text = (shipping?['city'] ?? '').toString();
      postCodeController.text = (shipping?['zip'] ?? '').toString();

      final country = (shipping?['country'] ?? '').toString().trim();
      if (country.isNotEmpty) {
        final normalized = countries.firstWhere(
          (c) => c.toLowerCase() == country.toLowerCase(),
          orElse: () => '',
        );
        selectedCountry.value = normalized;
      }
    } catch (_) {
      loadSavedData();
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<bool> updateShippingInfo() async {
    if (addressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your address');
      return false;
    }
    if (contactController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your contact number');
      return false;
    }

    isSaving.value = true;
    try {
      final shippingAddress = {
        'address': addressController.text.trim(),
        'contact_number': contactController.text.trim(),
        'country': selectedCountry.value.trim(),
        'city': cityController.text.trim(),
        'zip': postCodeController.text.trim(),
      };

      final response = await ApiService2.multipart(
        ApiEndPoint.user,
        body: {
          'shipping_address': jsonEncode(shippingAddress),
        },
        isPost: false,
      );

      if (response == null || response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void loadSavedData() {
    // Load from local storage or user profile
    if (addressController.text.isEmpty) {
      addressController.text =
          'House C17/A, B Block, Dhanmondi Dhaka Bangladesh';
    }
    if (contactController.text.isEmpty) {
      contactController.text = '+61 1234 5678 910';
    }
    if (cityController.text.isEmpty) {
      cityController.text = 'New York';
    }
    if (postCodeController.text.isEmpty) {
      postCodeController.text = '12456';
    }
    if (selectedCountry.value.trim().isEmpty) {
      selectedCountry.value = 'United States';
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    contactController.dispose();
    cityController.dispose();
    postCodeController.dispose();
    super.onClose();
  }

}