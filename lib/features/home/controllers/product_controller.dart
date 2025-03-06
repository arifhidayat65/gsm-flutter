// lib/features/home/controllers/product_controller.dart
import 'package:flutter/foundation.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  final IProductRepository _productRepository;

  ProductController(this._productRepository);

  List<ProductModel> _products = [];
  List<ProductModel> _promotedProducts = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  List<ProductModel> get promotedProducts => _promotedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productRepository.getProducts();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchPromotedProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _promotedProducts = await _productRepository.getPromotedProducts();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productRepository.searchProducts(query);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
