import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'home_widgets.dart';

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
      if (cat['name'].toString().toLowerCase() == categoryName.toLowerCase()) {
        selectedCat = cat;
        break;
      }
    }

    if (selectedCat == null) return [];

    final String selectedId = selectedCat['id'].toString();

    return allProducts.where((p) {
      final String pCatId = (p['category_id'] ?? '').toString();
      final String pSubCatId = (p['sub_category_id'] ?? '').toString();
      return pCatId == selectedId || pSubCatId == selectedId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = getFilteredProducts();
    final bool isDesktop = MediaQuery.of(context).size.width >= 1080;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        toolbarHeight: isDesktop ? 90 : kToolbarHeight,
        leadingWidth: isDesktop ? 300 : 56,
        leading: isDesktop
            ? Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Image.network(
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          categoryName.toUpperCase(),
          style: GoogleFonts.nunitoSans(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: isDesktop ? 20 : 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isDesktop ? 40 : 8),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: textPrimary),
              onPressed: onShowCart,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withOpacity(0.05), height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isDesktop ? 1440 : double.infinity),
          child: filteredProducts.isEmpty
              ? Center(
                  child: Text(
                    'No products found in this category',
                    style: GoogleFonts.nunitoSans(color: textSecondary),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 50,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          'ProductDetail',
                          pathParameters: {
                            'productId': product['id'].toString(),
                          },
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
        ),
      ),
    );
  }
}
