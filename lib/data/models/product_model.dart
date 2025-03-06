// lib/data/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String location;
  final double rating;
  final int sold;
  final String storeName;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.sold,
    required this.storeName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      sold: json['sold'] ?? 0,
      storeName: json['storeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'rating': rating,
      'sold': sold,
      'storeName': storeName,
    };
  }
}
