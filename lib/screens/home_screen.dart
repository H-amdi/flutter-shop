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
    // جلب البيانات عند فتح الشاشة
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

  // ── AppBar ──────────────────────────────────
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
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 20,
            ),
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
          icon: const Icon(
            Icons.category_rounded,
            color: AppConstants.textDark,
          ),
          tooltip: 'الفئات',
        ),
        // زر المفضلة
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          ),
          icon: const Icon(
            Icons.favorite_rounded,
            color: AppConstants.secondaryColor,
          ),
          tooltip: 'المفضلة',
        ),

        Consumer<CartProvider>(
          builder: (_, cartProvider, _) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: AppConstants.primaryColor,
                ),
                tooltip: 'السلة',
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
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
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

  Widget _buildBody(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const EmptyWidget(
        message: 'لا توجد منتجات',
        icon: Icons.inventory_2_rounded,
      );
    }

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
            (entry) => _buildCategorySection(context, entry.key, entry.value),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

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
                const Text(
                  'مرحباً بك! 👋',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
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
                  builder: (_, p, _) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${p.products.length} منتج متاح',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.shopping_bag_rounded,
            size: 80,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<Product> products,
  ) {
    final color =
        AppConstants.categoryColors[category] ?? AppConstants.primaryColor;
    final icon = AppConstants.categoryIcons[category] ?? Icons.category_rounded;

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
                  color: color.withValues(alpha: .15),
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
                  color: AppConstants.textLight,
                  fontSize: 12,
                ),
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
      case "electronics":
        return "إلكترونيات";
      case "jewelery":
        return "مجوهرات";
      case "men's clothing":
        return "ملابس رجالية";
      case "women's clothing":
        return "ملابس نسائية";
      default:
        return category;
    }
  }
}
