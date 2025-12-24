import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'home_page.dart';
import 'product_detail_page.dart';
import 'jewelry_layout_widget.dart';
import 'home_widgets.dart';
import 'wishlist_page.dart';

class HomePageDesktop extends StatelessWidget {
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

  const HomePageDesktop({
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
    return products
        .where((p) =>
            p['categories'] != null &&
            p['categories']['name'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF0A1E40)));
    }

    return Scaffold(
      backgroundColor: bgLight,
      body: CustomScrollView(
        slivers: [
          // 1. Navbar
          SliverAppBar(
            pinned: true,
            backgroundColor: bgLight,
            elevation: 0,
            toolbarHeight: 90,
            leadingWidth: 300,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child:
                  Container(color: Colors.black.withOpacity(0.05), height: 1),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.network(
                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _navLink('NEW ARRIVALS'),
                const SizedBox(width: 40),
                _navLink('SHOP ALL'),
                const SizedBox(width: 40),
                _navLink('COLLECTIONS'),
                const SizedBox(width: 40),
                _navLink('OUR STORY'),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 60),
                child: Row(
                  children: [
                    _iconButton(Icons.search, () {
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
                    }),
                    const SizedBox(width: 24),
                    _iconButton(Icons.favorite_border, () {
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
                    }),
                    const SizedBox(width: 24),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _iconButton(Icons.shopping_bag_outlined, onShowCart),
                        if (cart.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFB08D63),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cart.length}',
                                style: GoogleFonts.nunitoSans(
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
                  ],
                ),
              ),
            ],
          ),

          // 2. Hero Section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 700,
              child: Stack(
                children: [
                  BannerCarousel(banners: banners),
                  Positioned(
                    bottom: 120,
                    left: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: JewelryLayoutWidget(),
            ),
          ),

          // 5. Editorial Masonry Gallery (Replacing Standard Carousel)
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 60),
              child: Column(
                children: [
                  Text(
                    'AS SEEN ON YOU',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      color: const Color(0xFF0A1E40),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tag @blushvault_jewels to be featured',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 48),
                  StaggeredGrid.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      // Manually composing a nice masonry layout with gallery items
                      if (gallery.isNotEmpty)
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 2,
                          child: _galleryTile(gallery[0]),
                        ),
                      if (gallery.length > 1)
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: _galleryTile(gallery[1]),
                        ),
                      if (gallery.length > 2)
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 2,
                          child: _galleryTile(gallery[2]),
                        ),
                      if (gallery.length > 3)
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: _galleryTile(gallery[3]),
                        ),
                      if (gallery.length > 4)
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1,
                          child: _galleryTile(gallery[4]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 6. Trending Products
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'TRENDING NOW',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    color: const Color(0xFF0A1E40),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Wrap(
                  spacing: 24,
                  children: [
                    _filterTab('All', selectedCategory == 'All'),
                    ...categories.map((cat) => _filterTab(
                        cat['name'], selectedCategory == cat['name'])),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(100, 0, 100, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.75,
                crossAxisSpacing: 30,
                mainAxisSpacing: 50,
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
                      isFavorite:
                          wishlist.any((item) => item['id'] == product['id']),
                      onAddToCart: () => onAddToCart(product),
                      onToggleWishlist: () => onToggleWishlist(product),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).moveY(begin: 30);
                },
                childCount: getFilteredProducts().length,
              ),
            ),
          ),

          // 7. Footer
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF997C5B),
              padding:
                  const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BLUSHVAULT',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Handcrafted jewelry inspired by the beauty of nature and the strength of the modern woman.',
                              style: GoogleFonts.nunitoSans(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 60),
                      _footerColumn('SHOP', [
                        'New Arrivals',
                        'Best Sellers',
                        'Rings',
                        'Necklaces'
                      ]),
                      _footerColumn('HELP', [
                        'Shipping Information',
                        'Returns & Exchanges',
                        'Care Guide'
                      ]),
                      _footerColumn(
                          'SOCIAL', ['Instagram', 'Pinterest', 'Facebook']),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 30),
                  Text(
                    '© 2024 Blushvault Jewelry. All Rights Reserved.',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _trustItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0A1E40)),
        const SizedBox(width: 12),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: const Color(0xFF0A1E40),
          ),
        ),
      ],
    );
  }

  Widget _galleryTile(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0), // Sharp editorial edges
        image: DecorationImage(
          image: NetworkImage(item['image_url']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        child: const Icon(FontAwesomeIcons.instagram,
            color: Colors.white, size: 20),
      ),
    ).animate().fadeIn();
  }

  Widget _navLink(String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0A1E40),
        textStyle: GoogleFonts.nunitoSans(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      child: Text(text),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF0A1E40), size: 22),
      onPressed: onTap,
    );
  }

  Widget _filterTab(String label, bool isSelected) {
    return InkWell(
      onTap: () => onCategorySelected(label),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(color: Color(0xFF0A1E40), width: 2))
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.nunitoSans(
            color: isSelected ? const Color(0xFF0A1E40) : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _footerColumn(String title, List<String> links) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ...links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  link,
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
