// lib/providers/products_provider.dart
// مزود المنتجات: يدير حالة قائمة المنتجات ويتواصل مع API

import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum LoadingState { idle, loading, success, error }

class ProductsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<String> _categories = [];
  LoadingState _loadingState = LoadingState.idle;
  String _errorMessage = '';

  // ── Getters ──────────────────────────────────
  List<Product> get products => _products;
  List<String> get categories => _categories;
  LoadingState get loadingState => _loadingState;
  String get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;

  // ────────────────────────────────────────────
  // جلب جميع المنتجات من API
  // ────────────────────────────────────────────
  Future<void> fetchProducts() async {
    _setLoadingState(LoadingState.loading);
    try {
      _products = await _apiService.fetchProducts();
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoadingState(LoadingState.error);
    }
  }

  // ────────────────────────────────────────────
  // جلب الفئات
  // ────────────────────────────────────────────
  Future<void> fetchCategories() async {
    try {
      _categories = await _apiService.fetchCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // ────────────────────────────────────────────
  // جلب منتجات حسب الفئة
  // ────────────────────────────────────────────
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      return await _apiService.fetchProductsByCategory(category);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // ────────────────────────────────────────────
  // POST: إضافة منتج جديد
  // ────────────────────────────────────────────
  Future<bool> addProduct(Product product) async {
    try {
      final newProduct = await _apiService.addProduct(product);
      // FakeStoreAPI لا يحفظ فعلياً، نضيف محلياً
      _products.insert(0, newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // ────────────────────────────────────────────
  // PUT: تحديث منتج كاملاً
  // ────────────────────────────────────────────
  Future<bool> updateProduct(int id, Product product) async {
    try {
      final updated = await _apiService.updateProduct(id, product);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated.copyWith(id: id);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // ────────────────────────────────────────────
  // PATCH: تحديث جزئي للمنتج
  // ────────────────────────────────────────────
  Future<bool> patchProduct(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.patchProduct(id, data);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        final current = _products[index];
        _products[index] = current.copyWith(
          title: data['title'] ?? current.title,
          price: data['price'] != null
              ? (data['price'] as num).toDouble()
              : current.price,
          description: data['description'] ?? current.description,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // ────────────────────────────────────────────
  // DELETE: حذف منتج
  // ────────────────────────────────────────────
  Future<bool> deleteProduct(int id) async {
    try {
      await _apiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // ── Helper ───────────────────────────────────
  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
