import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_widgets.dart';
import 'product_detail_page.dart';

class CategoryProductsPage extends StatelessWidget {
  final String categoryName;
  final List<dynamic> allProducts;
  final List<dynamic> categories;
  final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>> wishlist;
  final void Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final void Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const CategoryProductsPage({
    super.key,
    required this.categoryName,
    required this.allProducts,
    required this.categories,
    required this.cart,
    required this.wishlist,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.onShowCart,
  });

  List<dynamic> getFilteredProducts() {
    if (categoryName == 'All') return allProducts;

    dynamic selectedCat;
    for (final cat in categories) {
      if (cat['name'] == categoryName) {
        selectedCat = cat;
        break;
      }
    }

    if (selectedCat == null) return [];

    final String selectedId = selectedCat['id'];

    return allProducts.where((p) {
      final bool matchesMain = p['category_id'] == selectedId;
      final bool matchesSub = p['sub_category_id'] == selectedId;
      return matchesMain || matchesSub;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = getFilteredProducts();
    final bool isDesktop = MediaQuery.of(context).size.width >= 1080;

    Widget content = Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName.toUpperCase(),
          style: GoogleFonts.nunitoSans(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: textPrimary),
            onPressed: onShowCart,
          ),
        ],
      ),
      body: filteredProducts.isEmpty
          ? Center(
              child: Text(
                'No products found in this category',
                style: GoogleFonts.nunitoSans(color: textSecondary),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          product: product,
                          onAddToCart: onAddToCart,
                          cart: cart,
                          wishlist: wishlist,
                          onToggleWishlist: onToggleWishlist,
                          onShowCart: onShowCart,
                        ),
                      ),
                    );
                  },
                  child: ProductCard(
                    product: product,
                    isFavorite:
                        wishlist.any((item) => item['id'] == product['id']),
                    onAddToCart: () => onAddToCart(product),
                    onToggleWishlist: () => onToggleWishlist(product),
                  ),
                );
              },
            ),
    );

    if (isDesktop) {
      return Container(
        color: bgLight,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
