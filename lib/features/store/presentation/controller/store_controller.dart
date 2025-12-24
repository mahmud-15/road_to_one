
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/store_collection_model.dart';
import '../../data/store_product_model.dart';

class StoreController extends GetxController {
  var selectedCategory = 'All'.obs;
  var selectedHandle = 'all'.obs;
  var cartItems = <Map<String, dynamic>>[].obs;
  var favoriteIds = <String>[].obs;

  final isCategoryLoading = false.obs;
  final collections = <StoreCollectionModel>[].obs;

  var categories = <String>[].obs;

  var products = <Map<String, dynamic>>[].obs;
  final isProductLoading = false.obs;

  bool get isLoading => isCategoryLoading.value || isProductLoading.value;

  @override
  void onInit() {
    super.onInit();
    selectedCategory.value = 'All';
    fetchCollections();
    fetchProductsByHandle('all');
  }

  Future<void> fetchCollections() async {
    isCategoryLoading.value = true;
    try {
      final response = await ApiService2.get(ApiEndPoint.storeCollection);
      if (response == null || response.statusCode != 200) {
        collections.clear();
        categories.assignAll(['All']);
        return;
      }

      final data = response.data;
      final list = (data is Map) ? (data['data'] as List?) : null;
      if (list == null) {
        collections.clear();
        categories.assignAll(['All']);
        return;
      }

      final mapped = list
          .whereType<Map>()
          .map((e) => StoreCollectionModel.fromJson(e.cast<String, dynamic>()))
          .toList();

      collections.assignAll(mapped);
      categories.assignAll(mapped.map((e) => e.title).toList());

      if (!categories.contains('All')) {
        categories.insert(0, 'All');
      }
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = categories.first;
      }
    } catch (_) {
      collections.clear();
      categories.assignAll(['All']);
    } finally {
      isCategoryLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    final handle = _resolveHandleForTitle(category);
    selectedHandle.value = handle;
    fetchProductsByHandle(handle);
  }

  String _resolveHandleForTitle(String title) {
    final t = title.trim().toLowerCase();
    final match = collections.firstWhereOrNull((c) => c.title.trim().toLowerCase() == t);
    if (match != null && match.handle.isNotEmpty) {
      return match.handle;
    }
    if (t == 'all') {
      return 'all';
    }
    return t;
  }

  Future<void> fetchProductsByHandle(String handle) async {
    final h = handle.isEmpty ? 'all' : handle;
    isProductLoading.value = true;
    try {
      final url = '${ApiEndPoint.storeProducts}/$h';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        products.clear();
        return;
      }

      final data = response.data;
      final list = (data is Map) ? (data['data'] as List?) : null;
      if (list == null) {
        products.clear();
        return;
      }

      final mapped = list
          .whereType<Map>()
          .map((e) => StoreProductModel.fromJson(e.cast<String, dynamic>()))
          .map((p) => <String, dynamic>{
                'id': p.extendId.isNotEmpty ? p.extendId : p.id,
                'extendId': p.extendId.isNotEmpty ? p.extendId : p.id,
                'name': p.title,
                'price': p.price,
                'image': p.image,
                'category': selectedCategory.value,
                'handle': p.handle,
                'isFavorite': p.isFavorite,
              })
          .toList();

      products.assignAll(mapped);
    } catch (_) {
      products.clear();
    } finally {
      isProductLoading.value = false;
    }
  }

  bool isFavorite(String extendId) {
    final id = extendId.toString();
    final idx = products.indexWhere((p) => (p['extendId'] ?? '').toString() == id);
    if (idx == -1) {
      return false;
    }
    return products[idx]['isFavorite'] == true;
  }

  Future<void> toggleFavorite(String extendId) async {
    final id = extendId.toString();
    if (id.isEmpty) {
      return;
    }

    final idx = products.indexWhere((p) => (p['extendId'] ?? '').toString() == id);
    if (idx == -1) {
      return;
    }

    final previous = products[idx]['isFavorite'] == true;
    products[idx]['isFavorite'] = !previous;
    products.refresh();

    try {
      final url = '${ApiEndPoint.favouriteToggle}/$id';
      final response = await ApiService2.post(url, body: {});
      if (response == null || response.statusCode != 200) {
        products[idx]['isFavorite'] = previous;
        products.refresh();
        Get.snackbar(
          'Failed',
          'Could not update favourite status.',
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (_) {
      products[idx]['isFavorite'] = previous;
      products.refresh();
      Get.snackbar(
        'Failed',
        'Could not update favourite status.',
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool isInCart(String productId) {
    return cartItems.any((item) => item['id'] == productId);
  }

  void addToCart(Map<String, dynamic> product) {
    if (!isInCart(product['id'])) {
      cartItems.add(product);
      Get.snackbar(
        'Added to Cart',
        '${product['name']} has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Already in Cart',
        '${product['name']} is already in your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item['id'] == productId);
  }

  void openProductDetail(Map<String, dynamic> product) {
    // Navigate to product detail screen
    Get.toNamed('/product-detail', arguments: product);
    // Or use: Get.to(() => ProductDetailScreen(product: product));
  }

  double getTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += double.parse(item['price']);
    }
    return total;
  }
}