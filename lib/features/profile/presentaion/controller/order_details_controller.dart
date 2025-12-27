import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/order_model.dart';

class OrderDetailsController extends GetxController {
  final String orderNo;

  OrderDetailsController({required this.orderNo});











  final RxBool isLoading = false.obs;
  final RxList<OrderLineItem> items = <OrderLineItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    isLoading.value = true;
    try {
      final url = '${ApiEndPoint.storeOrderHistory}/$orderNo';
      final response = await ApiService2.get(url);
      if (response == null || response.statusCode != 200) {
        items.clear();
        return;
      }

      final data = response.data;
      final payload = (data is Map) ? (data['data'] as Map?) : null;
      final list = (payload is Map) ? (payload['lineItems'] as List?) : null;
      if (list == null) {
        items.clear();
        return;
      }

      final mapped = list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map<OrderLineItem>((e) {
        final priceRaw = (e['variantPrice'] ?? e['amount'] ?? '').toString();
        final qty = (e['quantity'] is num)
            ? (e['quantity'] as num).toInt()
            : int.tryParse((e['quantity'] ?? '').toString()) ?? 0;
        return OrderLineItem(
          name: (e['title'] ?? '').toString(),
          image: (e['productImage'] ?? '').toString(),
          quantity: qty,
          price: double.tryParse(priceRaw) ?? 0.0,
        );
      }).toList(growable: false);

      items.assignAll(mapped);
    } catch (_) {
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
