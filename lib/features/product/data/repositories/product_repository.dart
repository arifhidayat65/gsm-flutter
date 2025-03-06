// lib/data/repositories/product_repository.dart
import '../models/product_model.dart';
import '../services/api_service.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10});
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getPromotedProducts();
}

class ProductRepository implements IProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/products',
        params: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final List<dynamic> productsJson = response.data['data'];
        return productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch products');
      }
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiService.get('/products/$id');

      if (response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch product');
      }
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _apiService.get(
        '/products/search',
        params: {'q': query},
      );

      if (response.data['success'] == true) {
        final List<dynamic> productsJson = response.data['data'];
        return productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search products');
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getPromotedProducts() async {
    try {
      final response = await _apiService.get('/products/promoted');

      if (response.data['success'] == true) {
        final List<dynamic> productsJson = response.data['data'];
        return productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch promoted products');
      }
    } catch (e) {
      throw Exception('Failed to fetch promoted products: $e');
    }
  }
}
