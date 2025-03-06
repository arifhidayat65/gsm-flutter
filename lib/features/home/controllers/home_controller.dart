// lib/features/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:gsmpromo/features/product/data/models/product_model.dart';

class HomeController extends ChangeNotifier {
  List<ProductModel> products = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Fetch products from repository
      products = await productRepository.getProducts();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
