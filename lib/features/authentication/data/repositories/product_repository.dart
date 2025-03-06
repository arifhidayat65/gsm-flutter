// lib/data/repositories/product_repository.dart
import 'package:gsmpromo/data/services/api_service.dart';
import 'package:gsmpromo/features/product/data/models/product_model.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<ProductModel>> getProducts() async {
    final response = await _apiService.get('/products');
    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
}
