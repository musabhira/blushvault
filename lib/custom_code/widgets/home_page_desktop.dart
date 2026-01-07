import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';
import 'jewelry_layout_widget.dart';
import 'home_widgets.dart';
import 'wishlist_page.dart';
import 'category_products_page.dart';

class HomePageDesktop extends StatefulWidget {
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

  @override
  State<HomePageDesktop> createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _trendingKey = GlobalKey();
  final GlobalKey _collectionsKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final RenderAbstractViewport? viewport = RenderAbstractViewport.of(box);

      if (viewport != null) {
        final double targetOffset =
            viewport.getOffsetToReveal(box, 0.0).offset - 90;

        _scrollController.animateTo(
          targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsPage(
          categoryName: categoryName,
          allProducts: widget.products,
          categories: widget.categories,
          cart: widget.cart,
          wishlist: widget.wishlist,
          onAddToCart: widget.onAddToCart,
          onToggleWishlist: widget.onToggleWishlist,
          onShowCart: widget.onShowCart,
        ),
      ),
    );
  }

  List<dynamic> getFilteredProducts() {
    if (widget.selectedCategory == 'All') return widget.products;

    // Find the category ID for the selected category (case-insensitive search)
    dynamic selectedCat;
    for (final cat in widget.categories) {
      if (cat['name'].toString().toLowerCase() ==
          widget.selectedCategory.toLowerCase()) {
        selectedCat = cat;
        break;
      }
    }

    if (selectedCat == null) return widget.products;

    final String selectedId = selectedCat['id'].toString();

    return widget.products.where((p) {
      final String pCatId = (p['category_id'] ?? '').toString();
      final String pSubCatId = (p['sub_category_id'] ?? '').toString();

      return pCatId == selectedId || pSubCatId == selectedId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF0A1E40)));
    }

    Widget content = Scaffold(
      backgroundColor: bgLight,
      body: CustomScrollView(
        controller: _scrollController,
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
              padding: const EdgeInsets.only(left: 40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go('/'),
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
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _navLink('TRENDING NOW', () {
                  widget.onCategorySelected('All');
                  _scrollToSection(_trendingKey);
                }),
                const SizedBox(width: 40),
                _navLink('SHOP ALL', () => _navigateToCategory(context, 'All')),
                const SizedBox(width: 40),
                _navLink(
                    'COLLECTIONS', () => _scrollToSection(_collectionsKey)),
                const SizedBox(width: 40),
                _navLink('GALLERY', () => _scrollToSection(_galleryKey)),
                const SizedBox(width: 40),
                _navLink('OUR STORY', () => _scrollToSection(_footerKey)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Row(
                  children: [
                    _iconButton(Icons.search, () {
                      showSearch(
                        context: context,
                        delegate: ProductSearchDelegate(
                          products: widget.products,
                          onAddToCart: widget.onAddToCart,
                          cart: widget.cart,
                          wishlist: widget.wishlist,
                          onToggleWishlist: widget.onToggleWishlist,
                          onShowCart: widget.onShowCart,
                        ),
                      );
                    }),
                    const SizedBox(width: 24),
                    _iconButton(Icons.favorite_border, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WishlistPage(
                            onAddToCart: widget.onAddToCart,
                            cart: widget.cart,
                            wishlist: widget.wishlist,
                            onToggleWishlist: widget.onToggleWishlist,
                            onShowCart: widget.onShowCart,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 24),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _iconButton(
                            Icons.shopping_bag_outlined, widget.onShowCart),
                        if (widget.cart.isNotEmpty)
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
                                '${widget.cart.length}',
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

          SliverToBoxAdapter(
            child: SizedBox(
              height: 700,
              child: Stack(
                children: [
                  BannerCarousel(banners: widget.banners),
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
          SliverToBoxAdapter(
            child: Center(
              key: _trendingKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        'TRENDING NOW',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          color: const Color(0xFF0A1E40),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Wrap(
                          spacing: 24,
                          children: [
                            _filterTab('All', widget.selectedCategory == 'All'),
                            ...widget.categories.map((cat) => _filterTab(
                                cat['name'],
                                widget.selectedCategory == cat['name'])),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 50,
                        ),
                        itemCount: getFilteredProducts().length,
                        itemBuilder: (context, index) {
                          final filteredProducts = getFilteredProducts();
                          if (index >= filteredProducts.length) return null;
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
                              isFavorite: widget.wishlist
                                  .any((item) => item['id'] == product['id']),
                              onAddToCart: () => widget.onAddToCart(product),
                              onToggleWishlist: () =>
                                  widget.onToggleWishlist(product),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (50 * index).ms)
                              .moveY(begin: 30);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              key: _collectionsKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: JewelryLayoutWidget(),
                ),
              ),
            ),
          ),

          // 5. Editorial Masonry Gallery (Replacing Standard Carousel)
          SliverToBoxAdapter(
            child: Center(
              key: _galleryKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
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
                          if (widget.gallery.isNotEmpty)
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 2,
                              child: _galleryTile(widget.gallery[0]),
                            ),
                          if (widget.gallery.length > 1)
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: _galleryTile(widget.gallery[1]),
                            ),
                          if (widget.gallery.length > 2)
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 2,
                              child: _galleryTile(widget.gallery[2]),
                            ),
                          if (widget.gallery.length > 3)
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: _galleryTile(widget.gallery[3]),
                            ),
                          if (widget.gallery.length > 4)
                            StaggeredGridTile.count(
                              crossAxisCellCount: 2,
                              mainAxisCellCount: 1,
                              child: _galleryTile(widget.gallery[4]),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. Trending Products

          // 7. Footer
          SliverToBoxAdapter(
            child: Container(
              key: _footerKey,
              color: const Color(0xFF997C5B),
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
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
                            GestureDetector(
                              onTap: () => context.go('/'),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'BLUSHVAULT',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SOCIAL',
                              style: GoogleFonts.nunitoSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const FaIcon(
                                    FontAwesomeIcons.instagram,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  onPressed: () => launchUrl(Uri.parse(
                                      'https://www.instagram.com/blushvault_jewels/')),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.phone_outlined,
                                      color: Colors.white70, size: 20),
                                  onPressed: () =>
                                      launchUrl(Uri.parse('tel:+919496905158')),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.email_outlined,
                                      color: Colors.white70, size: 20),
                                  onPressed: () => launchUrl(Uri.parse(
                                      'mailto:blushvaultjewels@gmail.com')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 30),
                  Text(
                    '© 2026 Blushvault Jewelry. All Rights Reserved.',
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

    return content;
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

  Widget _navLink(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
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
      onTap: () => widget.onCategorySelected(label),
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
