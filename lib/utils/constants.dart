// lib/utils/constants.dart
// ثوابت التطبيق: الألوان، الروابط، والقيم الثابتة

import 'package:flutter/material.dart';

class AppConstants {
  // ── REST API ──────────────────────────────────────────────
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';
  static const String productsByCategoryEndpoint = '/products/category';

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'Flutter Shop';
  static const String appVersion = '1.0.0';

  // ── Colors ────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFFFF6584);
  static const Color accentColor = Color(0xFF43E97B);
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);

  // ── Category Icons Map ────────────────────────────────────
  static const Map<String, IconData> categoryIcons = {
    "electronics": Icons.devices_rounded,
    "jewelery": Icons.diamond_rounded,
    "men's clothing": Icons.man_rounded,
    "women's clothing": Icons.woman_rounded,
    "books": Icons.menu_book_rounded,
  };

  // ── Category Colors Map ───────────────────────────────────
  static const Map<String, Color> categoryColors = {
    "electronics": Color(0xFF6C63FF),
    "jewelery": Color(0xFFFFD700),
    "men's clothing": Color(0xFF4FC3F7),
    "women's clothing": Color(0xFFFF80AB),
    "books": Color(0xFF81C784),
  };
}
