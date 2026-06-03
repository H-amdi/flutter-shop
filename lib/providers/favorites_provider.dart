// lib/providers/favorites_provider.dart
// مزود المفضلة: يدير قائمة المنتجات المفضلة

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final Map<int, Product> _favorites = {};

  // ── Getters ──────────────────────────────────
  Map<int, Product> get favorites => Map.unmodifiable(_favorites);
  List<Product> get favoritesList => _favorites.values.toList();
  int get count => _favorites.length;

  // ────────────────────────────────────────────
  // إضافة/إزالة من المفضلة (toggle)
  // ────────────────────────────────────────────
  void toggleFavorite(Product product) {
    if (_favorites.containsKey(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites[product.id] = product;
    }
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // إزالة من المفضلة
  // ────────────────────────────────────────────
  void removeFromFavorites(int productId) {
    _favorites.remove(productId);
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // التحقق إذا كان المنتج في المفضلة
  // ────────────────────────────────────────────
  bool isFavorite(int productId) => _favorites.containsKey(productId);

  // ────────────────────────────────────────────
  // مسح المفضلة
  // ────────────────────────────────────────────
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}
