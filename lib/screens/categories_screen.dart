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
            fontWeight: FontWeight.bold,
            color: AppConstants.textDark,
          ),
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
              Container(
                width: 100,
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final cat = categories[index];
                    final isSelected = _selectedCategory == cat;
                    final color =
                        AppConstants.categoryColors[cat] ??
                        AppConstants.primaryColor;
                    final icon =
                        AppConstants.categoryIcons[cat] ??
                        Icons.category_rounded;

                    return GestureDetector(
                      onTap: () => _selectCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: .15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: color.withValues(alpha: .4))
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              icon,
                              color: isSelected ? color : Colors.grey,
                              size: 26,
                            ),
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
        icon: Icons.inventory_2_rounded,
      );
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
