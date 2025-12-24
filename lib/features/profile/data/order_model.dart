class Order {
  final String id;
  final String orderNumber;
  final int itemCount;
  final double totalPrice;
  final String currencySymbol;
  final String date;
  final List<OrderLineItem> items;

  Order({
    required this.id,
    required this.itemCount,
    required this.orderNumber,
    required this.totalPrice,
    required this.currencySymbol,
    required this.date,
    this.items = const <OrderLineItem>[],
  });
}

class OrderLineItem {
  final String name;
  final String image;
  final int quantity;
  final double price;

  OrderLineItem({
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });
}