import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/cart_item.dart';

class CartController extends GetxController {
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxInt cartCount = 0.obs;

  late final Box<CartItem> _box;
  late final StreamSubscription<BoxEvent> _sub;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box<CartItem>(CartItemAdapter.boxName);
    _syncFromBox();
    _sub = _box.watch().listen((_) {
      _syncFromBox();
    });
  }

  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }

  void _syncFromBox() {
    final items = _box.values.toList(growable: false);
    cartItems.assignAll(items);
    cartCount.value = items.fold<int>(0, (sum, e) => sum + e.quantity);
  }

  bool isInCart(String keyId) {
    return _box.containsKey(keyId);
  }

  Future<void> addOrIncrement(CartItem item) async {
    final existing = _box.get(item.keyId);
    if (existing == null) {
      await _box.put(item.keyId, item);
      return;
    }
    await _box.put(
      item.keyId,
      existing.copyWith(quantity: existing.quantity + item.quantity),
    );
  }

  Future<void> incrementQuantity(String keyId) async {
    final item = _box.get(keyId);
    if (item == null) {
      return;
    }
    await _box.put(keyId, item.copyWith(quantity: item.quantity + 1));
  }

  Future<void> decrementQuantity(String keyId) async {
    final item = _box.get(keyId);
    if (item == null) {
      return;
    }
    if (item.quantity <= 1) {
      await _box.delete(keyId);
      return;
    }
    await _box.put(keyId, item.copyWith(quantity: item.quantity - 1));
  }

  Future<void> removeItem(String keyId) async {
    await _box.delete(keyId);
  }

  Future<void> clearCart() async {
    await _box.clear();
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get taxes => 0.00;
  double get otherFees => 0.00;
  double get deliveryFees => 0.00;

  double get total => subtotal + taxes + otherFees + deliveryFees;
}