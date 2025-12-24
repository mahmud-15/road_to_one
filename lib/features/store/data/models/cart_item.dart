import 'package:hive/hive.dart';

class CartItem {
  final String keyId;
  final String productId;
  final String name;
  final String image;
  final String color;
  final String size;
  final String currencyCode;
  final double price;
  final int quantity;

  const CartItem({
    required this.keyId,
    required this.productId,
    required this.name,
    required this.image,
    required this.color,
    required this.size,
    required this.currencyCode,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({
    String? keyId,
    String? productId,
    String? name,
    String? image,
    String? color,
    String? size,
    String? currencyCode,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      keyId: keyId ?? this.keyId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      color: color ?? this.color,
      size: size ?? this.size,
      currencyCode: currencyCode ?? this.currencyCode,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  static const String boxName = 'cart_box';
  static const int typeIdValue = 21;

  @override
  int get typeId => typeIdValue;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return CartItem(
      keyId: (fields[0] ?? '').toString(),
      productId: (fields[1] ?? '').toString(),
      name: (fields[2] ?? '').toString(),
      image: (fields[3] ?? '').toString(),
      color: (fields[4] ?? '').toString(),
      size: (fields[5] ?? '').toString(),
      currencyCode: (fields[6] ?? '').toString(),
      price: (fields[7] is num) ? (fields[7] as num).toDouble() : 0.0,
      quantity: (fields[8] is num) ? (fields[8] as num).toInt() : 1,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.keyId)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.currencyCode)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.quantity);
  }
}