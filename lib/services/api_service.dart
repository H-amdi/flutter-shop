// lib/services/api_service.dart
// طبقة الخدمات: تتعامل مع جميع عمليات HTTP (GET, POST, PUT, PATCH, DELETE)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;

  // ────────────────────────────────────────────
  // GET: جلب جميع المنتجات
  // ────────────────────────────────────────────
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl${AppConstants.productsEndpoint}'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('فشل جلب المنتجات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ────────────────────────────────────────────
  // GET: جلب منتجات حسب الفئة
  // ────────────────────────────────────────────
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final encodedCategory = Uri.encodeComponent(category);
      final response = await http
          .get(Uri.parse(
              '$_baseUrl${AppConstants.productsByCategoryEndpoint}/$encodedCategory'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('فشل جلب منتجات الفئة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ────────────────────────────────────────────
  // GET: جلب الفئات
  // ────────────────────────────────────────────
  Future<List<String>> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl${AppConstants.categoriesEndpoint}'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((e) => e.toString()).toList();
      } else {
        throw Exception('فشل جلب الفئات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ────────────────────────────────────────────
  // POST: إضافة منتج جديد
  // ────────────────────────────────────────────
  Future<Product> addProduct(Product product) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl${AppConstants.productsEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(product.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else {
        throw Exception('فشل إضافة المنتج: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ────────────────────────────────────────────
  // PUT: تحديث كامل لمنتج موجود
  // ────────────────────────────────────────────
  Future<Product> updateProduct(int id, Product product) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl${AppConstants.productsEndpoint}/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(product.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else {
        throw Exception('فشل تحديث المنتج: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ────────────────────────────────────────────
  // PATCH: تحديث جزئي لمنتج موجود
  // ────────────────────────────────────────────
  Future<Product> patchProduct(int id, Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl${AppConstants.productsEndpoint}/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else {
        throw Exception('فشل التعديل الجزئي: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ────────────────────────────────────────────
  // DELETE: حذف منتج
  // ────────────────────────────────────────────
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl${AppConstants.productsEndpoint}/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('فشل حذف المنتج: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}
