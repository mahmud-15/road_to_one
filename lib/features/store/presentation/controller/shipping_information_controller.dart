// Path: lib/screens/store/controller/shipping_information_controller.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;

import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/storage/storage_services.dart';
import '../../data/models/cart_item.dart';
import '../controller/cart_controller.dart';
import '../screen/payment_webview_screen.dart';

class ShippingInformationController extends GetxController {
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

  var totalAmount = 0.0.obs;
  final isSaving = false.obs;
  final isLoadingProfile = false.obs;
  final isProcessing = false.obs;

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

    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoadingProfile.value = true;
    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer ${LocalStorage.token}',
      };
      final response = await dio.get(
        ApiEndPoint.user,
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      if (payload == null) {
        return;
      }

      final shipping = payload['shipping_address'];
      if (shipping is Map) {
        final address = (shipping['address'] ?? '').toString();
        final contact = (shipping['contact_number'] ?? '').toString();
        final city = (shipping['city'] ?? '').toString();
        final zip = (shipping['zip'] ?? '').toString();
        final country = (shipping['country'] ?? '').toString().trim();

        if (address.trim().isNotEmpty) {
          addressController.text = address;
        }
        if (contact.trim().isNotEmpty) {
          contactController.text = contact;
        }
        if (city.trim().isNotEmpty) {
          cityController.text = city;
        }
        if (zip.trim().isNotEmpty) {
          postCodeController.text = zip;
        }
        if (country.isNotEmpty) {
          selectedCountry.value = countries.contains(country) ? country : country;
        }
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingProfile.value = false;
    }
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

    if (isProcessing.value) return;
    isProcessing.value = true;
    var navigated = false;
    try {
      final ok = await _updateShippingInfo();
      if (!ok) {
        return;
      }

      final paymentUrl = await _createCheckout();
      if (paymentUrl == null || paymentUrl.trim().isEmpty) {
        return;
      }

      navigated = true;
      Get.to(
        () => PaymentWebViewScreen(
          paymentUrl: paymentUrl,
          onSuccess: () async {
            final cartController = Get.isRegistered<CartController>()
                ? Get.find<CartController>()
                : Get.put(CartController());
            await cartController.clearCart();
            Get.offAllNamed(AppRoutes.successImageScreen);
          },
        ),
      );
    } finally {
      if (!navigated) {
        isProcessing.value = false;
      }
    }
  }

  Future<String?> _createCheckout() async {
    try {
      final cartController = Get.isRegistered<CartController>()
          ? Get.find<CartController>()
          : Get.put(CartController());

      final items = cartController.cartItems.toList(growable: false);
      if (items.isEmpty) {
        _safeSnackbar(
          'Cart',
          'Your cart is empty.',
          backgroundColor: Colors.red,
        );
        return null;
      }

      final lineItems = <Map<String, dynamic>>[];
      for (final CartItem e in items) {
        if (e.variantId.trim().isEmpty) {
          continue;
        }
        lineItems.add({
          'variantId': e.variantId,
          'quantity': e.quantity,
          'currencyCode': e.currencyCode,
        });
      }

      if (lineItems.isEmpty) {
        _safeSnackbar(
          'Cart',
          'No valid variants found in cart.',
          backgroundColor: Colors.red,
        );
        return null;
      }

      if (kDebugMode) {
        debugPrint('=== CREATE CHECKOUT REQUEST ===');
        debugPrint('url: ${ApiEndPoint.createCheckout}');
        debugPrint('lineItems: ${jsonEncode(lineItems)}');
      }

      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer ${LocalStorage.token}',
        'Content-Type': 'application/json',
      };

      final response = await dio.post(
        ApiEndPoint.createCheckout,
        data: {
          'lineItems': lineItems,
        },
        options: Options(headers: headers),
      );

      if (kDebugMode) {
        debugPrint('=== CREATE CHECKOUT RESPONSE ===');
        debugPrint('statusCode: ${response.statusCode}');
        debugPrint('data: ${jsonEncode(response.data)}');
      }

      if (response.statusCode != 200) {
        _safeSnackbar(
          'Failed',
          'Could not create checkout.',
          backgroundColor: Colors.red,
        );
        return null;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      final url = (payload?['paymentUrl'] ?? '').toString();
      if (url.trim().isEmpty) {
        _safeSnackbar(
          'Failed',
          'Payment URL missing from response.',
          backgroundColor: Colors.red,
        );
        return null;
      }

      if (kDebugMode) {
        debugPrint('paymentUrl: $url');
      }

      return url;
    } catch (_) {
      _safeSnackbar(
        'Failed',
        'Could not create checkout.',
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  Future<bool> _updateShippingInfo() async {
    isSaving.value = true;
    try {
      final shippingAddress = {
        'address': addressController.text.trim(),
        'contact_number': contactController.text.trim(),
        'country': selectedCountry.value.trim(),
        'city': cityController.text.trim(),
        'zip': postCodeController.text.trim(),
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

      // _safeSnackbar(
      //   'Success',
      //   'Shipping information updated.',
      //   backgroundColor: Colors.green,
      // );
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
    cityController.dispose();
    postCodeController.dispose();
    super.onClose();
  }
}