import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_widget.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'المفضلة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppConstants.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.textDark),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (_, favProvider, _) {
              if (favProvider.count == 0) return const SizedBox();
              return TextButton(
                onPressed: () => favProvider.clearFavorites(),
                child: const Text(
                  'مسح الكل',
                  style: TextStyle(color: AppConstants.errorColor),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favProvider, _) {
          if (favProvider.count == 0) {
            return const EmptyWidget(
              message: 'لا توجد منتجات في المفضلة\nأضف منتجات لتراها هنا!',
              icon: Icons.favorite_border_rounded,
            );
          }

          final favorites = favProvider.favoritesList;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: AppConstants.secondaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${favProvider.count} منتج في المفضلة',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final product = favorites[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: product),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
