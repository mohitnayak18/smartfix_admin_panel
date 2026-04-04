// models/product_model.dart
class ProductModel {
  String? id;
  String brandId;
  String modelId;
  String serviceId;
  String name;
  String price;
  String discountPrice;
  String rating;
  String image;
  
  ProductModel({
    this.id,
    required this.brandId,
    required this.modelId,
    required this.serviceId,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.rating,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'brandId': brandId,
      'modelId': modelId,
      'serviceId': serviceId,
      'name': name,
      'price': price,
      'discountPrice': discountPrice,
      'rating': rating,
      'image': image,
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      brandId: map['brandId'] ?? '',
      modelId: map['modelId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      discountPrice: map['discountPrice'] ?? '',
      rating: map['rating'] ?? '',
      image: map['image'] ?? '',
    );
  }
}