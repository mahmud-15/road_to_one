import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/order_model.dart';
import '../screen/order_details_screen.dart';

class OrderHistoryController extends GetxController {

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    isLoading.value = true;
    try {
      final response = await ApiService2.get(ApiEndPoint.storeOrderHistory);
      if (response == null || response.statusCode != 200) {
        orders.clear();
        return;
      }

      final data = response.data;
      final list = (data is Map) ? (data['data'] as List?) : null;
      if (list == null) {
        orders.clear();
        return;
      }

      final mapped = list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map<Order>((e) {
        final currency = (e['currency'] ?? '').toString();
        final symbol = _currencySymbol(currency);
        return Order(
          id: (e['id'] ?? '').toString(),
          orderNumber: (e['name'] ?? '').toString(),
          totalPrice: double.tryParse((e['price'] ?? '').toString()) ?? 0.0,
          currencySymbol: symbol,
          itemCount: (e['totalItems'] is num)
              ? (e['totalItems'] as num).toInt()
              : int.tryParse((e['totalItems'] ?? '').toString()) ?? 0,
          date: _formatOrderDate((e['date'] ?? '').toString()),
        );
      }).toList(growable: false);

      orders.assignAll(mapped);
    } catch (_) {
      orders.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String _currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'GBP':
        return '£';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      default:
        return code;
    }
  }

  String _formatOrderDate(String iso) {
    // Input: 2025-12-24T09:43:17Z  => Output: 24/12/25
    try {
      final dt = DateTime.parse(iso).toLocal();
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yy = (dt.year % 100).toString().padLeft(2, '0');
      return '$dd/$mm/$yy';
    } catch (_) {
      return iso;
    }
  }

  void viewOrderDetails(Order order) {
    Get.to(() => OrderDetailsScreen(order: order));
  }
}