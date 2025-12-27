class StoreProductModel {
  final String id;
  final String extendId;
  final String title;
  final String handle;
  final bool availableForSale;
  final String image;
  final String variantId;
  final String variantTitle;
  final String price;
  final String currency;
  final bool isFavorite;

  StoreProductModel({
    required this.id,
    required this.extendId,
    required this.title,
    required this.handle,
    required this.availableForSale,
    required this.image,
    required this.variantId,
    required this.variantTitle,
    required this.price,
    required this.currency,
    required this.isFavorite,
  });

  factory StoreProductModel.fromJson(Map<String, dynamic> json) {
    return StoreProductModel(
      id: (json['id'] ?? '').toString(),
      extendId: (json['extendId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      handle: (json['handle'] ?? '').toString(),
      availableForSale: json['availableForSale'] == true,
      image: (json['image'] ?? '').toString(),
      variantId: (json['variantId'] ?? '').toString(),
      variantTitle: (json['variantTitle'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      isFavorite: json['isFavorite'] == true,
    );
  }

  Map<String, dynamic> toProductMap() {
    return {
      'id': extendId.isNotEmpty ? extendId : id,
      'name': title,
      'price': price,
      'image': image,
      'category': '',
    };
  }
}
