class StoreProductImage {
  final String id;
  final String url;

  StoreProductImage({required this.id, required this.url});

  factory StoreProductImage.fromJson(Map<String, dynamic> json) {
    return StoreProductImage(
      id: (json['id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
    );
  }
}

class StoreProductOption {
  final String name;
  final List<String> values;

  StoreProductOption({required this.name, required this.values});

  factory StoreProductOption.fromJson(Map<String, dynamic> json) {
    final raw = json['values'];
    final values = raw is List
        ? raw.map((e) => e.toString()).toList()
        : <String>[];

    return StoreProductOption(
      name: (json['name'] ?? '').toString(),
      values: values,
    );
  }
}

class StoreProductVariantPrice {
  final String amount;
  final String currencyCode;

  StoreProductVariantPrice({required this.amount, required this.currencyCode});

  factory StoreProductVariantPrice.fromJson(Map<String, dynamic> json) {
    return StoreProductVariantPrice(
      amount: (json['amount'] ?? '').toString(),
      currencyCode: (json['currencyCode'] ?? '').toString(),
    );
  }
}

class StoreProductVariant {
  final String id;
  final String title;
  final bool availableForSale;
  final StoreProductVariantPrice price;

  StoreProductVariant({
    required this.id,
    required this.title,
    required this.availableForSale,
    required this.price,
  });

  factory StoreProductVariant.fromJson(Map<String, dynamic> json) {
    final price = json['price'];
    return StoreProductVariant(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      availableForSale: json['availableForSale'] == true,
      price: price is Map
          ? StoreProductVariantPrice.fromJson(price.cast<String, dynamic>())
          : StoreProductVariantPrice(amount: '', currencyCode: ''),
    );
  }
}

class StoreProductDetailModel {
  final String id;
  final String extendId;
  final bool isFavorite;
  final String title;
  final String handle;
  final String description;
  final bool availableForSale;
  final List<StoreProductOption> options;
  final List<StoreProductVariant> variants;
  final List<StoreProductImage> images;

  StoreProductDetailModel({
    required this.id,
    required this.extendId,
    required this.isFavorite,
    required this.title,
    required this.handle,
    required this.description,
    required this.availableForSale,
    required this.options,
    required this.variants,
    required this.images,
  });

  factory StoreProductDetailModel.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'];
    final variantsRaw = json['variants'];
    final imagesRaw = json['images'];

    final extendId = (json['extendId'] ?? json['extend_id'] ?? json['extendedId'] ?? '')
        .toString();
    final isFavorite = json['isFavorite'] == true || json['is_favorite'] == true;

    return StoreProductDetailModel(
      id: (json['id'] ?? '').toString(),
      extendId: extendId,
      isFavorite: isFavorite,
      title: (json['title'] ?? '').toString(),
      handle: (json['handle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      availableForSale: json['availableForSale'] == true,
      options: optionsRaw is List
          ? optionsRaw
              .whereType<Map>()
              .map((e) => StoreProductOption.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <StoreProductOption>[],
      variants: variantsRaw is List
          ? variantsRaw
              .whereType<Map>()
              .map((e) => StoreProductVariant.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <StoreProductVariant>[],
      images: imagesRaw is List
          ? imagesRaw
              .whereType<Map>()
              .map((e) => StoreProductImage.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <StoreProductImage>[],
    );
  }
}
