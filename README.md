#  Flutter Shop — متجر إلكتروني متكامل

##  معلومات الطالب
اسم الطالب/ حمدي نجيب حسن عبدالقادر
 القسم/ هندسة البرمجيات — مستوى ثالث 
 project Name/Flutter Shop — Used by Flutter + Provider + REST API 




##  هيكل المشروع

```
flutter_shop/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── models/product.dart
    ├── services/api_service.dart
    ├── providers/
    │   ├── products_provider.dart
    │   ├── cart_provider.dart
    │   └── favorites_provider.dart
    ├── screens/
    │   ├── home_screen.dart
    │   ├── categories_screen.dart
    │   ├── product_details_screen.dart
    │   ├── edit_product_screen.dart
    │   ├── cart_screen.dart
    │   ├── favorites_screen.dart
    │   └── add_product_screen.dart
    ├── widgets/
    │   ├── product_card.dart
    │   ├── cart_item_widget.dart
    │   └── loading_widget.dart
    └── utils/constants.dart
```

---

## 1️⃣ شاشة الفئات — الحالة الأولى (ملابس نسائية محددة)

![Categories Screen - Women's Clothing](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-01.jpg)

> **الوصف:** شاشة الفئات عند اختيار فئة "ملابس نسائية"، تظهر قائمة الفئات على اليسار وشبكة المنتجات على اليمين. المنتجات التي تحمل علامة ✓ خضراء تعني أنها مضافة للسلة.

### 📄 `lib/screens/categories_screen.dart`

```dart

// lib/screens/categories_screen.dart
// شاشة الفئات: تعرض جميع الفئات مع فلترة المنتجات

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_widget.dart';
import 'product_details_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _selectedCategory;
  List<Product> _filteredProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchCategories();
    });
  }

  Future<void> _selectCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoadingProducts = true;
    });

    final products = await context
        .read<ProductsProvider>()
        .fetchProductsByCategory(category);

    if (mounted) {
      setState(() {
        _filteredProducts = products;
        _isLoadingProducts = false;
      });
    }
  }

  String _translateCategory(String cat) {
    switch (cat) {
      case "electronics":
        return "إلكترونيات";
      case "jewelery":
        return "مجوهرات";
      case "men's clothing":
        return "ملابس رجالية";
      case "women's clothing":
        return "ملابس نسائية";
      default:
        return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'الفئات',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppConstants.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.textDark),
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, _) {
          final categories = productsProvider.categories;

          if (categories.isEmpty) {
            return const LoadingWidget(message: 'جاري تحميل الفئات...');
          }

          return Row(
            children: [
              // قائمة الفئات (جانبية) 
              Container(
                width: 100,
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final cat = categories[index];
                    final isSelected = _selectedCategory == cat;
                    final color = AppConstants.categoryColors[cat] ??
                        AppConstants.primaryColor;
                    final icon =
                        AppConstants.categoryIcons[cat] ??
                            Icons.category_rounded;

                    return GestureDetector(
                      onTap: () => _selectCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: color.withOpacity(0.4))
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(icon,
                                color: isSelected ? color : Colors.grey,
                                size: 26),
                            const SizedBox(height: 6),
                            Text(
                              _translateCategory(cat),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? color
                                    : AppConstants.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              //  عرض منتجات الفئة المختارة 
              Expanded(
                child: _selectedCategory == null
                    ? _buildSelectPrompt()
                    : _isLoadingProducts
                        ? const LoadingWidget(message: 'جاري التحميل...')
                        : _buildProductsGrid(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'اختر فئة\nلعرض المنتجات',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppConstants.textLight,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) {
      return const EmptyWidget(
          message: 'لا توجد منتجات في هذه الفئة',
          icon: Icons.inventory_2_rounded);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          ),
        );
      },
    );
  }
}
```

---

## 2️⃣ شاشة الفئات — الحالة الثانية (إلكترونيات محددة)

![Categories Screen - Electronics](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-02.jpg)

> **الوصف:** نفس شاشة الفئات بعد اختيار "إلكترونيات"، يتغير تمييز الفئة ويُعرض شبكة منتجات الإلكترونيات المحملة من API.

### 📄 الكود — نفس ملف `categories_screen.dart` أعلاه
### 📄 `lib/services/api_service.dart` — دالة GET بالفئة

```dart
// lib/services/api_service.dart
// GET: جلب منتجات حسب الفئة

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
```

---

## 3️⃣ شاشة الفئات — الحالة الأولية (لم يُختر فئة بعد)

![Categories Screen - Initial State](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-03.jpg)

> **الوصف:** الحالة الابتدائية لشاشة الفئات قبل اختيار أي فئة، تظهر الفئات الأربع في الشريط الجانبي، وتظهر رسالة "اختر فئة لعرض المنتجات" على اليمين.

### 📄 Widget الحالة الابتدائية — داخل `categories_screen.dart`

```dart
Widget _buildSelectPrompt() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app_rounded, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text(
          'اختر فئة\nلعرض المنتجات',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppConstants.textLight,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
```

---

## 4️⃣ الشاشة الرئيسية — قسم الملابس النسائية

![Home Screen - Women's Clothing](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-04.jpg)

> **الوصف:** الشاشة الرئيسية تعرض المنتجات مجمّعة حسب الفئة. يظهر قسم "ملابس نسائية" مع أيقونة القسم ولون مميز. AppBar يحتوي على أيقونة الفئات والمفضلة والسلة مع عداد المنتجات.

### 📄 `lib/screens/home_screen.dart`

```dart
// lib/screens/home_screen.dart
// الشاشة الرئيسية: تعرض المنتجات مجمّعة حسب الفئات

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_widget.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'add_product_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
      context.read<ProductsProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, _) {
          if (productsProvider.isLoading) {
            return const LoadingWidget(message: 'جاري تحميل المنتجات...');
          }
          if (productsProvider.loadingState == LoadingState.error) {
            return ErrorWidget2(
              message: productsProvider.errorMessage,
              onRetry: () => productsProvider.fetchProducts(),
            );
          }
          return _buildBody(context, productsProvider.products);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'منتج جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //  AppBar 
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.primaryColor, Color(0xFF8B85FF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'Flutter Shop',
            style: TextStyle(
              color: AppConstants.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        // زر الفئات
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoriesScreen()),
          ),
          icon: const Icon(Icons.category_rounded,
              color: AppConstants.textDark),
        ),
        // زر المفضلة
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          ),
          icon: const Icon(Icons.favorite_rounded,
              color: AppConstants.secondaryColor),
        ),
        // زر السلة مع العداد
        Consumer<CartProvider>(
          builder: (_, cartProvider, _) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                icon: const Icon(Icons.shopping_cart_rounded,
                    color: AppConstants.primaryColor),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppConstants.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  //  Body 
  Widget _buildBody(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const EmptyWidget(
          message: 'لا توجد منتجات', icon: Icons.inventory_2_rounded);
    }

    // تجميع المنتجات حسب الفئة
    final Map<String, List<Product>> grouped = {};
    for (var p in products) {
      grouped.putIfAbsent(p.category, () => []).add(p);
    }

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => context.read<ProductsProvider>().fetchProducts(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildBanner(),
          const SizedBox(height: 16),
          ...grouped.entries.map(
            (entry) =>
                _buildCategorySection(context, entry.key, entry.value),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  //  بانر ترحيبي 
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, Color(0xFF8B85FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مرحباً بك! 👋',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                const Text(
                  'اكتشف أفضل\nالمنتجات لديك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<ProductsProvider>(
                  builder: (_, p, __) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${p.products.length} منتج متاح',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.shopping_bag_rounded,
              size: 80, color: Colors.white24),
        ],
      ),
    );
  }

  //  قسم فئة المنتجات 
  Widget _buildCategorySection(
      BuildContext context, String category, List<Product> products) {
    final color = AppConstants.categoryColors[category] ??
        AppConstants.primaryColor;
    final icon =
        AppConstants.categoryIcons[category] ?? Icons.category_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatCategory(category),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                  ),
                ),
              ),
              Text(
                '${products.length} منتج',
                style: const TextStyle(
                    color: AppConstants.textLight, fontSize: 12),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _formatCategory(String category) {
    switch (category) {
      case "electronics": return "إلكترونيات";
      case "jewelery":    return "مجوهرات";
      case "men's clothing":   return "ملابس رجالية";
      case "women's clothing": return "ملابس نسائية";
      default: return category;
    }
  }
}
```

---

## 5️⃣ الشاشة الرئيسية — قسم الإلكترونيات

![Home Screen - Electronics](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-05.jpg)

> **الوصف:** نفس الشاشة الرئيسية بعد التمرير لأسفل، يظهر قسم "إلكترونيات" مع لون البنفسجي المميز وأيقونة الحاسب.

### 📄 Widget بطاقة المنتج — `lib/widgets/product_card.dart`

```dart
// lib/widgets/product_card.dart
// بطاقة عرض المنتج داخل الصفحة الرئيسية والفئات

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_rounded,
                          size: 48, color: Colors.grey,
                        ),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ),
                    ),
                  ),
                  // زر المفضلة
                  Positioned(
                    top: 8, right: 8,
                    child: _FavoriteButton(product: product),
                  ),
                ],
              ),
            ),
            //  معلومات المنتج
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      _AddToCartButton(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  زر المفضلة 
class _FavoriteButton extends StatelessWidget {
  final Product product;
  const _FavoriteButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (_, favProvider, __) {
        final isFav = favProvider.isFavorite(product.id);
        return GestureDetector(
          onTap: () => favProvider.toggleFavorite(product),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1), blurRadius: 4)
              ],
            ),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 16,
              color: isFav ? AppConstants.secondaryColor : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}

//  زر إضافة للسلة 
class _AddToCartButton extends StatelessWidget {
  final Product product;
  const _AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cartProvider, __) {
        final inCart = cartProvider.isInCart(product.id);
        return GestureDetector(
          onTap: () {
            cartProvider.addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تمت الإضافة للسلة ✓'),
                duration: const Duration(seconds: 1),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: inCart
                  ? AppConstants.successColor
                  : AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              inCart
                  ? Icons.check_rounded
                  : Icons.add_shopping_cart_rounded,
              size: 16, color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
```

---

## 6️⃣ الشاشة الرئيسية — قسم المجوهرات

![Home Screen - Jewelery](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-06.jpg)

> **الوصف:** قسم "مجوهرات" في الشاشة الرئيسية، يظهر المنتج الأول في المفضلة (قلب أحمر) والثاني مضاف للسلة (علامة ✓ خضراء).

### 📄 `lib/providers/favorites_provider.dart`

```dart
// lib/providers/favorites_provider.dart
// مزود المفضلة: يدير قائمة المنتجات المفضلة

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final Map<int, Product> _favorites = {};

  Map<int, Product> get favorites => Map.unmodifiable(_favorites);
  List<Product> get favoritesList => _favorites.values.toList();
  int get count => _favorites.length;

  // إضافة/إزالة من المفضلة (toggle)
  void toggleFavorite(Product product) {
    if (_favorites.containsKey(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites[product.id] = product;
    }
    notifyListeners();
  }

  void removeFromFavorites(int productId) {
    _favorites.remove(productId);
    notifyListeners();
  }

  bool isFavorite(int productId) => _favorites.containsKey(productId);

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}
```

### 📄 `lib/providers/cart_provider.dart`

```dart
// lib/providers/cart_provider.dart
// مزود السلة: يدير إضافة وحذف وتحديث المنتجات في السلة

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => Map.unmodifiable(_items);

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get uniqueItemCount => _items.length;

  double get totalAmount {
    return _items.values
        .fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
  }

  // إضافة منتج للسلة
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(int productId) => _items.containsKey(productId);

  int getQuantity(int productId) => _items[productId]?.quantity ?? 0;
}
```

---

## 7️⃣ شاشة تفاصيل المنتج

![Product Details Screen](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-07.jpg)

> **الوصف:** شاشة تفاصيل المنتج تعرض صورة كبيرة، الفئة، الاسم، السعر، التقييم، الوصف، وزري "تعديل المنتج" و"حذف المنتج". في الأسفل شريط "أضف للسلة" مع مؤشر الكمية الحالية.

### 📄 `lib/screens/product_details_screen.dart`

```dart
// lib/screens/product_details_screen.dart
// شاشة تفاصيل المنتج: تعرض كل المعلومات مع أزرار الإجراءات

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/products_provider.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';
import 'edit_product_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1), blurRadius: 8)
            ],
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: AppConstants.textDark),
        ),
      ),
      actions: [
        Consumer<FavoritesProvider>(
          builder: (_, favProvider, __) {
            final isFav = favProvider.isFavorite(product.id);
            return GestureDetector(
              onTap: () {
                favProvider.toggleFavorite(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isFav
                        ? 'تم الإزالة من المفضلة'
                        : 'تمت الإضافة للمفضلة ❤️'),
                    backgroundColor: isFav
                        ? Colors.grey
                        : AppConstants.secondaryColor,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 8)
                  ],
                ),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav
                      ? AppConstants.secondaryColor
                      : AppConstants.textDark,
                  size: 20,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(40),
          child: Image.network(
            product.image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_rounded,
              size: 80, color: Colors.grey,
            ),
            loadingBuilder: (_, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const LoadingWidget();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الفئة
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (AppConstants.categoryColors[product.category] ??
                      AppConstants.primaryColor)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.category.toUpperCase(),
              style: TextStyle(
                color: AppConstants.categoryColors[product.category] ??
                    AppConstants.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // الاسم
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: AppConstants.textDark, height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // السعر والتقييم
          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const Spacer(),
              if (product.rating != null) ...[
                const Icon(Icons.star_rounded,
                    color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${product.rating!.rate}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(' (${product.rating!.count})',
                    style: const TextStyle(
                        color: AppConstants.textLight, fontSize: 13)),
              ],
            ],
          ),
          const SizedBox(height: 20),
          // الوصف
          const Text('الوصف',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold,
                  color: AppConstants.textDark)),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14, color: AppConstants.textLight, height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // أزرار التعديل والحذف
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'تعديل المنتج',
                  color: const Color(0xFF2196F3),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditProductScreen(product: product)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_rounded,
                  label: 'حذف المنتج',
                  color: AppConstants.errorColor,
                  onTap: () => _confirmDelete(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cartProvider, __) {
        final inCart = cartProvider.isInCart(product.id);
        final quantity = cartProvider.getQuantity(product.id);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20, offset: const Offset(0, -4))
            ],
          ),
          child: Row(
            children: [
              if (inCart)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'في السلة ($quantity)',
                    style: const TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (inCart) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    cartProvider.addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تمت الإضافة للسلة ✓'),
                        backgroundColor: AppConstants.successColor,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded,
                      color: Colors.white),
                  label: const Text(
                    'أضف للسلة',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${product.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('حذف',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context
          .read<ProductsProvider>()
          .deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'تم حذف المنتج بنجاح ✓' : 'فشل حذف المنتج'),
            backgroundColor: success
                ? AppConstants.successColor
                : AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (success) Navigator.pop(context);
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
```

---

## 8️⃣ شاشة السلة

![Cart Screen](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-08.jpg)

> **الوصف:** شاشة السلة تعرض المنتجات المضافة مع الصورة والاسم والسعر وأدوات التحكم بالكمية (+/-) وزر الحذف. في الأسفل ملخص الفاتورة مع الإجمالي وزر "إتمام الطلب".

### 📄 `lib/screens/cart_screen.dart`

```dart
// lib/screens/cart_screen.dart
// شاشة السلة: تعرض المنتجات المضافة مع الكمية والإجمالي

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/loading_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'سلة التسوق',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppConstants.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.textDark),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cartProvider, __) {
              if (cartProvider.items.isEmpty) return const SizedBox();
              return TextButton.icon(
                onPressed: () => _confirmClearCart(context, cartProvider),
                icon: const Icon(Icons.delete_sweep_rounded,
                    color: AppConstants.errorColor, size: 18),
                label: const Text('مسح الكل',
                    style: TextStyle(
                        color: AppConstants.errorColor, fontSize: 13)),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.items.isEmpty) {
            return const EmptyWidget(
              message: 'السلة فارغة\nأضف منتجات للبدء!',
              icon: Icons.shopping_cart_outlined,
            );
          }

          final items = cartProvider.items.values.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: items.length,
                  itemBuilder: (_, index) =>
                      CartItemWidget(cartItem: items[index]),
                ),
              ),
              _buildTotalBar(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, -4),
          )
        ],
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('عدد المنتجات',
                  style: TextStyle(color: AppConstants.textLight)),
              Text(
                '${cartProvider.uniqueItemCount} منتج (${cartProvider.itemCount} قطعة)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppConstants.textDark),
              ),
              Text(
                '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _showCheckoutDialog(context, cartProvider),
              icon: const Icon(Icons.payment_rounded, color: Colors.white),
              label: const Text(
                'إتمام الطلب',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(
      BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppConstants.successColor),
            SizedBox(width: 8),
            Text('تأكيد الطلب'),
          ],
        ),
        content: Text(
          'سيتم تأكيد طلبك بإجمالي \$${cartProvider.totalAmount.toStringAsFixed(2)}\nهل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم تأكيد طلبك بنجاح! 🎉'),
                  backgroundColor: AppConstants.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('تأكيد',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(
      BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('مسح السلة'),
        content:
            const Text('هل تريد إزالة جميع المنتجات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('مسح',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
```

### 📄 `lib/widgets/cart_item_widget.dart`

```dart
// lib/widgets/cart_item_widget.dart
// عنصر السلة: يعرض تفاصيل المنتج في شاشة السلة

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70, height: 70,
              color: Colors.grey[50],
              padding: const EdgeInsets.all(6),
              child: Image.network(
                cartItem.product.image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.image_not_supported_rounded),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // معلومات المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppConstants.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${cartItem.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      onTap: () => cartProvider
                          .decreaseQuantity(cartItem.product.id),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      onTap: () =>
                          cartProvider.addItem(cartItem.product),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          cartProvider.removeItem(cartItem.product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              AppConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppConstants.errorColor, size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppConstants.primaryColor),
      ),
    );
  }
}
```

---

## 9️⃣ شاشة إضافة منتج جديد

![Add Product Screen](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-09.jpg)

> **الوصف:** شاشة إضافة منتج جديد تحتوي على Form كامل بحقول: اسم المنتج، السعر، الوصف، رابط الصورة، والفئة (Dropdown). عند الضغط على الزر يُنفَّذ POST Request للـ API.

### 📄 `lib/screens/add_product_screen.dart`

```dart
// lib/screens/add_product_screen.dart
// شاشة إضافة منتج جديد: تنفّذ POST Request

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../utils/constants.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController(
      text:
          'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_FMwebp_QL65_.jpg');
  String _selectedCategory = 'electronics';
  bool _isLoading = false;

  final List<String> _categories = [
    "electronics", "jewelery", "men's clothing", "women's clothing",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newProduct = Product(
      id: 0,
      title: _titleController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      image: _imageController.text.trim(),
    );

    final success =
        await context.read<ProductsProvider>().addProduct(newProduct);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'تمت إضافة المنتج بنجاح! ✓'
              : 'فشلت إضافة المنتج'),
          backgroundColor: success
              ? AppConstants.successColor
              : AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'إضافة منتج جديد',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppConstants.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هيدر القسم
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConstants.primaryColor, Color(0xFF8B85FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_box_rounded,
                        color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('منتج جديد',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('سيتم إرسال POST Request للـ API',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _titleController,
                label: 'اسم المنتج *', hint: 'مثال: iPhone 15 Pro',
                icon: Icons.title_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'اسم المنتج مطلوب' : null,
              ),
              _buildField(
                controller: _priceController,
                label: 'السعر (\$) *', hint: 'مثال: 99.99',
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'السعر مطلوب';
                  if (double.tryParse(v) == null) return 'أدخل رقماً صحيحاً';
                  if (double.parse(v) <= 0) return 'يجب أن يكون أكبر من 0';
                  return null;
                },
              ),
              _buildField(
                controller: _descriptionController,
                label: 'الوصف *', hint: 'وصف تفصيلي للمنتج...',
                icon: Icons.description_rounded, maxLines: 4,
                validator: (v) => v == null || v.length < 10
                    ? 'الوصف يجب أن يكون 10 أحرف على الأقل'
                    : null,
              ),
              _buildField(
                controller: _imageController,
                label: 'رابط الصورة *', hint: 'https://...',
                icon: Icons.image_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'رابط الصورة مطلوب' : null,
              ),
              // الفئة
              const Text('الفئة *',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textDark, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6)
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppConstants.primaryColor),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(
                                    AppConstants.categoryIcons[cat] ??
                                        Icons.category_rounded,
                                    size: 18,
                                    color:
                                        AppConstants.categoryColors[cat] ??
                                            AppConstants.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(cat),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    _isLoading ? 'جاري الإرسال...' : 'إضافة المنتج (POST)',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label, required String hint, required IconData icon,
    TextInputType? keyboardType, int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textDark, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppConstants.primaryColor),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppConstants.primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppConstants.errorColor),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔟 الشاشة الرئيسية — قسم الملابس الرجالية

![Home Screen - Men's Clothing](https://raw.githubusercontent.com/H_amdi/flutter_shop/main/screenshots/page-10.jpg)

> **الوصف:** قسم "ملابس رجالية" في الشاشة الرئيسية مع لون أزرق مميز وأيقونة رجل. المنتج الأول مضاف للسلة (عداد = 1 في AppBar).

### 📄 الملفات الداعمة — Model & API Service

#### `lib/models/product.dart`

```dart
// lib/models/product.dart
// نموذج بيانات المنتج مع دعم JSON Parsing

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating? rating;

  Product({
    required this.id, required this.title, required this.price,
    required this.description, required this.category,
    required this.image, this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      rating: json['rating'] != null
          ? Rating.fromJson(json['rating'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'price': price,
    'description': description, 'category': category, 'image': image,
  };

  Product copyWith({
    int? id, String? title, double? price, String? description,
    String? category, String? image, Rating? rating,
  }) {
    return Product(
      id: id ?? this.id, title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image, rating: rating ?? this.rating,
    );
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    rate: (json['rate'] ?? 0).toDouble(),
    count: json['count'] ?? 0,
  );
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}
```

#### `lib/services/api_service.dart` — جميع العمليات

```dart
// lib/services/api_service.dart
// طبقة الخدمات: GET / POST / PUT / PATCH / DELETE

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;

  //  GET: جلب جميع المنتجات 
  Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Product.fromJson(j)).toList();
    }
    throw Exception('فشل جلب المنتجات: ${response.statusCode}');
  }

  // GET: جلب منتجات حسب الفئة 
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final encoded = Uri.encodeComponent(category);
    final response = await http
        .get(Uri.parse('$_baseUrl/products/category/$encoded'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => Product.fromJson(j)).toList();
    }
    throw Exception('فشل جلب منتجات الفئة: ${response.statusCode}');
  }

  //  GET: جلب الفئات 
  Future<List<String>> fetchCategories() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products/categories'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(response.body);
      return list.map((e) => e.toString()).toList();
    }
    throw Exception('فشل جلب الفئات');
  }

  // ── POST: إضافة منتج جديد 
  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('فشل إضافة المنتج');
  }

  //  PUT: تحديث كامل 
  Future<Product> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('فشل تحديث المنتج');
  }

  //  PATCH: تحديث جزئي 
  Future<Product> patchProduct(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('فشل التعديل الجزئي');
  }

  //  DELETE: حذف منتج 
  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) return true;
    throw Exception('فشل حذف المنتج');
  }
}
```

---

## ⚙️ الملفات الأساسية

### 📄 `lib/main.dart` — نقطة دخول التطبيق

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() => runApp(const FlutterShopApp());

class FlutterShopApp extends StatelessWidget {
  const FlutterShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.primaryColor),
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
```

### 📄 `pubspec.yaml`

```yaml
name: flutter_shop
description: A complete Flutter e-commerce app with REST API and Provider.
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  http: ^1.2.1
  cached_network_image: ^3.3.1
  flutter_spinkit: ^5.2.1
  fluttertoast: ^8.2.4
  google_fonts: ^6.2.1
  badges: ^3.1.2
  cupertino_icons: ^1.0.6

flutter:
  uses-material-design: true
