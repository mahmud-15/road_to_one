import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/store_product_detail_model.dart';

class ProductDetailApiController extends GetxController {
  final isLoading = false.obs;
  final detail = Rxn<StoreProductDetailModel>();

  final isFavorite = false.obs;

  final selectedColor = ''.obs;
  final selectedSize = ''.obs;

  String handle = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      handle = args.toString();
    }
    fetchDetail();
  }

  Future<void> setHandle(String newHandle) async {
    final h = newHandle.trim();
    if (h.isEmpty) {
      handle = '';
      detail.value = null;
      selectedColor.value = '';
      selectedSize.value = '';
      isFavorite.value = false;
      return;
    }
    if (h == handle && detail.value != null) {
      return;
    }
    handle = h;
    detail.value = null;
    selectedColor.value = '';
    selectedSize.value = '';
    isFavorite.value = false;
    await fetchDetail();
  }

  Future<void> fetchDetail() async {
    if (handle.isEmpty) {
      detail.value = null;
      return;
    }

    isLoading.value = true;
    try {
      final url = '${ApiEndPoint.storeProductDetail}/$handle';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        detail.value = null;
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      if (payload == null) {
        detail.value = null;
        return;
      }

      final parsed = StoreProductDetailModel.fromJson(payload.cast<String, dynamic>());
      detail.value = parsed;
      isFavorite.value = parsed.isFavorite;

      final colorOpt = parsed.options.firstWhereOrNull(
        (o) => o.name.toLowerCase() == 'color',
      );
      final sizeOpt = parsed.options.firstWhereOrNull(
        (o) => o.name.toLowerCase() == 'size',
      );

      if (colorOpt != null && colorOpt.values.isNotEmpty) {
        selectedColor.value = colorOpt.values.first;
      }
      if (sizeOpt != null && sizeOpt.values.isNotEmpty) {
        selectedSize.value = sizeOpt.values.first;
      }
    } catch (_) {
      detail.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    final d = detail.value;
    final id = d?.extendId.trim().isNotEmpty == true
        ? d!.extendId.trim()
        : (d?.id.trim() ?? '');
    if (id.isEmpty) {
      return;
    }

    final previous = isFavorite.value;
    isFavorite.value = !previous;

    try {
      final url = '${ApiEndPoint.favouriteToggle}/$id';
      final response = await ApiService2.post(url, body: {});
      if (response == null || response.statusCode != 200) {
        isFavorite.value = previous;
        Get.snackbar(
          'Failed',
          'Could not update favourite status.',
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (_) {
      isFavorite.value = previous;
      Get.snackbar(
        'Failed',
        'Could not update favourite status.',
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void setColor(String value) {
    selectedColor.value = value;
  }

  void setSize(String value) {
    selectedSize.value = value;
  }

  StoreProductVariant? get selectedVariant {
    final d = detail.value;
    if (d == null) {
      return null;
    }
    final color = selectedColor.value.trim();
    final size = selectedSize.value.trim();
    final expected = '$color / $size';

    final exact = d.variants.firstWhereOrNull(
      (v) => v.title.trim().toLowerCase() == expected.trim().toLowerCase(),
    );
    if (exact != null) {
      return exact;
    }

    return d.variants.firstWhereOrNull((v) => v.availableForSale == true) ??
        (d.variants.isNotEmpty ? d.variants.first : null);
  }
}
