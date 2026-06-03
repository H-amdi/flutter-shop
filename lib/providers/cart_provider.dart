// lib/providers/cart_provider.dart
// مزود السلة: يدير إضافة وحذف وتحديث المنتجات في السلة

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  // Map يربط id المنتج بعنصر السلة
  final Map<int, CartItem> _items = {};

  // ── Getters ──────────────────────────────────
  Map<int, CartItem> get items => Map.unmodifiable(_items);

  /// إجمالي عدد العناصر (مجموع الكميات)
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// عدد المنتجات المختلفة في السلة
  int get uniqueItemCount => _items.length;

  /// الإجمالي الكلي للأسعار
  double get totalAmount {
    return _items.values
        .fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
  }

  // ────────────────────────────────────────────
  // إضافة منتج للسلة
  // ────────────────────────────────────────────
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // زيادة الكمية إذا كان المنتج موجوداً
      _items[product.id]!.quantity++;
    } else {
      // إضافة منتج جديد
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // إزالة عنصر واحد من الكمية
  // ────────────────────────────────────────────
  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // حذف المنتج كلياً من السلة
  // ────────────────────────────────────────────
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // تفريغ السلة بالكامل
  // ────────────────────────────────────────────
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // التحقق إذا كان المنتج في السلة
  // ────────────────────────────────────────────
  bool isInCart(int productId) => _items.containsKey(productId);

  /// الحصول على كمية منتج معين
  int getQuantity(int productId) => _items[productId]?.quantity ?? 0;
}
