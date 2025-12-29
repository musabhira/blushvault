import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart';
import 'product_detail_page.dart';
import 'wishlist_page.dart';
import 'home_widgets.dart'; // Ensure this is imported for the new widgets
import 'jewelry_layout_widget.dart'; // Keep this if user wants to keep the "JewelryLayout" section
import 'category_products_page.dart';

class HomePageMobile extends StatelessWidget {
  final List<dynamic> banners;
  final List<dynamic> products;
  final List<dynamic> categories;
  final List<dynamic> gallery;
  final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>> wishlist;
  final String selectedCategory;
  final bool isLoading;
  final Function(String) onCategorySelected;
  final Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final Function() onShowCart;
  final Function(int) onMoveToWishlist;

  const HomePageMobile({
    super.key,
    required this.banners,
    required this.products,
    required this.categories,
    required this.gallery,
    required this.cart,
    required this.wishlist,
    required this.selectedCategory,
    required this.isLoading,
    required this.onCategorySelected,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.onShowCart,
    required this.onMoveToWishlist,
  });

  List<dynamic> getFilteredProducts() {
    if (selectedCategory == 'All') return products;

    // Find the category ID for the selected category
    final selectedCat = categories.firstWhere(
      (c) => c['name'] == selectedCategory,
      orElse: () => null,
    );

    if (selectedCat == null) return products;

    final String selectedId = selectedCat['id'];

    return products.where((p) {
      final bool matchesMain = p['category_id'] == selectedId;
      final bool matchesSub = p['sub_category_id'] == selectedId;

      // Also check if the product's main category has this as a parent
      // (This handles showing all sub-cat items when main cat is selected)
      // Note: We need parent_id in category data linked to product
      // For now, simple ID check covers most cases.
      return matchesMain || matchesSub;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFB08D63)));
    }

    return Scaffold(
      backgroundColor: bgLight,
      drawer: CommonDrawer(
        onAddToCart: onAddToCart,
        cart: cart,
        wishlist: wishlist,
        onToggleWishlist: onToggleWishlist,
        onShowCart: onShowCart,
        categories: categories,
        products: products,
        onCategorySelected: onCategorySelected,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Fixed Announcement Bar
            const AnnouncementBar(),

            // 2. Main Scrollable Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: bgLight,
                    elevation: 0,
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF333333)),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    centerTitle: true,
                    title: Image.network(
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search,
                            color: Color(0xFF333333), size: 24),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: ProductSearchDelegate(
                              products: products,
                              onAddToCart: onAddToCart,
                              cart: cart,
                              wishlist: wishlist,
                              onToggleWishlist: onToggleWishlist,
                              onShowCart: onShowCart,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Color(0xFF333333), size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WishlistPage(
                                onAddToCart: onAddToCart,
                                cart: cart,
                                wishlist: wishlist,
                                onToggleWishlist: onToggleWishlist,
                                onShowCart: onShowCart,
                              ),
                            ),
                          );
                        },
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined,
                                color: Color(0xFF333333), size: 24),
                            onPressed: onShowCart,
                          ),
                          if (cart.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB08D63),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  '${cart.length}',
                                  style: GoogleFonts.nunitoSans(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                        color: Colors.grey[200],
                        height: 1,
                      ),
                    ),
                  ),

                  // Hero Banners
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 500,
                      child: BannerCarousel(banners: banners),
                    ).animate().fadeIn(duration: 600.ms),
                  ),

                  // "Shop By Category" Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 32, bottom: 24, left: 16),
                      child: Text(
                        'SHOP BY CATEGORY',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),

                  // Circular Categories Grid
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          if (categories.isEmpty) return null;
                          final cat = categories[index % categories.length];
                          final imageUrl = cat['image_url'] ??
                              'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400';

                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: CircularCategoryItem(
                              imageUrl: imageUrl,
                              label: cat['name'],
                              onTap: () => onCategorySelected(cat['name']),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 48, bottom: 16, left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NEW ARRIVALS',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          TextButton(
                            onPressed: () => onCategorySelected('All'),
                            child: Text(
                              'VIEW ALL',
                              style: GoogleFonts.nunitoSans(
                                color: const Color(0xFFB08D63),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final filteredProducts = getFilteredProducts();
                          if (index >= filteredProducts.length) return null;
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
                              isFavorite: wishlist
                                  .any((item) => item['id'] == product['id']),
                              onAddToCart: () => onAddToCart(product),
                              onToggleWishlist: () => onToggleWishlist(product),
                            ),
                          ).animate().fadeIn(delay: (50 * index).ms);
                        },
                        childCount:
                            getFilteredProducts().length, // Use filtered count
                      ),
                    ),
                  ),

                  // "View All" Button under features (Use filtered count to decide if we show more)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: OutlinedButton(
                          onPressed: () => onCategorySelected('All'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 16),
                            side: const BorderSide(color: Colors.black),
                          ),
                          child: Text(
                            'VIEW ALL PRODUCTS',
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Custom Jewelry Collection Section
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: JewelryLayoutWidget(),
                    ),
                  ),

                  // Instagram / Gallery Section
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 30),
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      color: const Color(0xFFFAFAFA),
                      child: Column(
                        children: [
                          Text(
                            '@BLUSHVAULT_JEWELS',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Follow us on Instagram',
                            style: GoogleFonts.nunitoSans(
                              color: const Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Horizontal Scrolling Gallery
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: gallery.length,
                              itemBuilder: (context, index) {
                                final item = gallery[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: AspectRatio(
                                    aspectRatio: 0.8,
                                    child: GalleryCard(item: item),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 48, horizontal: 24),
                      // color: const Color(0xFF0A1E40),
                      color: const Color(0xFF997C5B),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'BLUSHVAULT',
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const FaIcon(
                                  FontAwesomeIcons.instagram,
                                  color: Colors.white70,
                                ),
                                onPressed: () => launchUrl(Uri.parse(
                                    'https://www.instagram.com/blushvault_jewels/')),
                              ),
                              const SizedBox(width: 24),
                              IconButton(
                                icon: const Icon(Icons.phone_outlined,
                                    color: Colors.white70),
                                onPressed: () =>
                                    launchUrl(Uri.parse('tel:+919496905158')),
                              ),
                              const SizedBox(width: 24),
                              IconButton(
                                icon: const Icon(Icons.email_outlined,
                                    color: Colors.white70),
                                onPressed: () => launchUrl(Uri.parse(
                                    'mailto:blushvaultjewels@gmail.com')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            '© 2024 Blushvault. All Rights Reserved.',
                            style: GoogleFonts.nunitoSans(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
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

class CommonDrawer extends StatelessWidget {
  final Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;
  final List<dynamic> categories;
  final List<dynamic> products;
  final Function(String) onCategorySelected;

  const CommonDrawer({
    super.key,
    required this.onAddToCart,
    required this.cart,
    required this.wishlist,
    required this.onToggleWishlist,
    required this.onShowCart,
    required this.categories,
    required this.products,
    required this.onCategorySelected,
  });

  void _navigateToCategory(BuildContext context, String categoryName) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsPage(
          categoryName: categoryName,
          allProducts: products,
          categories: categories,
          cart: cart,
          wishlist: wishlist,
          onAddToCart: onAddToCart,
          onToggleWishlist: onToggleWishlist,
          onShowCart: onShowCart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: bgLight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: bgLight,
            ),
            child: Center(
              child: Image.network(
                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: textPrimary),
            title: Text('HOME',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                )),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border, color: textPrimary),
            title: Text('WISHLIST',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                )),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistPage(
                    onAddToCart: onAddToCart,
                    cart: cart,
                    wishlist: wishlist,
                    onToggleWishlist: onToggleWishlist,
                    onShowCart: onShowCart,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.shopping_bag_outlined, color: textPrimary),
            title: Text('MY BAG',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                )),
            onTap: () {
              Navigator.pop(context);
              onShowCart();
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'SHOP BY CATEGORY',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...categories.where((c) => c['parent_id'] == null).map((mainCat) {
            final subs = categories
                .where((c) => c['parent_id'] == mainCat['id'])
                .toList();

            if (subs.isEmpty) {
              return ListTile(
                title: Text(mainCat['name'].toUpperCase(),
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                onTap: () => _navigateToCategory(context, mainCat['name']),
              );
            }

            return ExpansionTile(
              title: Text(mainCat['name'].toUpperCase(),
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
              childrenPadding: const EdgeInsets.only(left: 16),
              children: [
                ListTile(
                  title: Text('ALL ${mainCat['name'].toUpperCase()}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: textSecondary,
                      )),
                  onTap: () => _navigateToCategory(context, mainCat['name']),
                ),
                ...subs.map((sub) => ListTile(
                      title: Text(sub['name'].toUpperCase(),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            color: textSecondary,
                          )),
                      onTap: () => _navigateToCategory(context, sub['name']),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}
