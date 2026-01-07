import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// --- CONSTANTS ---
const primaryDarkBlue = Color(0xFF0A1E40); // Dark Blue for Announcement/Buttons
const primaryGold = Color(0xFFB08D63);
const textPrimary = Color(0xFF333333);
const textSecondary = Color(0xFF666666);
const discountTeal = Color(0xFF008080);
const bgLight = Color(0xFFF6F1EB);
const secondaryGold = Color(0xFF997C5B);

// --- ANNOUNCEMENT BAR ---
class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({super.key});

  @override
  State<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<AnnouncementBar> {
  final List<String> _messages = [
    'GET A FREEBIE ON PREPAID ORDERS | WORLDWIDE SHIPPING',
    'FREE SHIPPING ON ALL ORDERS ABOVE ₹2999',
    'SIGN UP & GET 10% OFF ON YOUR FIRST ORDER',
  ];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFF997C5B),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isEntering = child.key == ValueKey<int>(_index);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: isEntering ? const Offset(0, 1) : const Offset(0, -1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _messages[_index],
            key: ValueKey<int>(_index),
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// --- CIRCULAR CATEGORY ITEM ---
class CircularCategoryItem extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;

  const CircularCategoryItem({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class BannerCarouselMobile extends StatefulWidget {
  final List<dynamic> banners;

  const BannerCarouselMobile({super.key, required this.banners});

  @override
  State<BannerCarouselMobile> createState() => _BannerCarouselMobileState();
}

class _BannerCarouselMobileState extends State<BannerCarouselMobile> {
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    if (widget.banners.isNotEmpty) {
      Future.delayed(const Duration(seconds: 4), autoScroll);
    }
  }

  void autoScroll() {
    if (mounted && widget.banners.isNotEmpty) {
      final nextIndex = (currentIndex + 1) % widget.banners.length;
      pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      Future.delayed(const Duration(seconds: 4), autoScroll);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const Center(child: Text('No banners available'));
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: (index) => setState(() => currentIndex = index),
          itemCount: widget.banners.length,
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner['image_url'] ?? '',
                  fit: BoxFit.cover,
                ),
                // Gradient for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                // Text Overlay
              ],
            );
          },
        ),
        // Indicators
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

// --- BANNER CAROUSEL ---
class BannerCarousel extends StatefulWidget {
  final List<dynamic> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    if (widget.banners.isNotEmpty) {
      Future.delayed(const Duration(seconds: 4), autoScroll);
    }
  }

  void autoScroll() {
    if (mounted && widget.banners.isNotEmpty) {
      final nextIndex = (currentIndex + 1) % widget.banners.length;
      pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      Future.delayed(const Duration(seconds: 4), autoScroll);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const Center(child: Text('No banners available'));
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: (index) => setState(() => currentIndex = index),
          itemCount: widget.banners.length,
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner['image_url_desktop'] ?? '',
                  fit: BoxFit.cover,
                ),
                // Gradient for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                // Text Overlay
              ],
            );
          },
        ),
        // Indicators
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

// --- CATEGORY CHIP (Legacy Support for Desktop) ---
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryDarkBlue : Colors.white,
            border: Border.all(
              color: isSelected ? primaryDarkBlue : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.nunitoSans(
              color: isSelected ? Colors.white : textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// --- UPDATED PRODUCT CARD (PALMONAS STYLE) ---
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;

  const ProductCard({
    super.key,
    required this.product,
    this.isFavorite = false,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    product['image_url'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Wishlist Icon (Bottom Left)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onToggleWishlist,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(10), // Increased hit area
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20, // Slightly larger
                        color: isFavorite ? Colors.red : textPrimary,
                      ),
                    ),
                  ),
                ),
                // Badge (if featured or sale)
                if (product['is_featured'] == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF997C5B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'BESTSELLER',
                        style: GoogleFonts.nunitoSans(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  product['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${product['price']}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (product['original_price'] != null)
                      Text(
                        '₹${product['original_price']}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: textSecondary,
                        ),
                      ),
                  ],
                ),
                if (product['discount'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${product['discount']}% OFF',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: discountTeal,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: GestureDetector(
                    onTap: () {}, // Prevent outer detector from firing
                    behavior: HitTestBehavior.opaque,
                    child: OutlinedButton(
                      onPressed: onAddToCart,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryDarkBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'ADD TO BAG',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryDarkBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const GalleryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item['image_url'],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final List<dynamic> products;
  final Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.black, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.nunitoSans(color: Colors.grey, fontSize: 16),
        border: InputBorder.none,
      ),
    );
  }

  ProductSearchDelegate({
    required this.products,
    required this.onAddToCart,
    required this.cart,
    required this.wishlist,
    required this.onToggleWishlist,
    required this.onShowCart,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.black),
        onPressed: () {
          query = '';
          Navigator.pop(context);
        },
      ),
      StatefulBuilder(builder: (context, setIconState) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon:
                  const Icon(Icons.shopping_bag_outlined, color: Colors.black),
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
        );
      }),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults(context);
  }

  Widget _buildResults(BuildContext context) {
    final queryLower = query.toLowerCase();
    final results = products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final desc = (p['description'] ?? '').toString().toLowerCase();
      return name.contains(queryLower) || desc.contains(queryLower);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No products found.',
          style: GoogleFonts.nunitoSans(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Determine responsiveness
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return StatefulBuilder(
      builder: (context, setDelegateState) {
        return Container(
          color: bgLight,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? width * 0.2 : 16,
              vertical: 20,
            ),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = results[index];
              final isFavorite =
                  wishlist.any((item) => item['id'] == product['id']);

              return SearchProductTile(
                product: product,
                isFavorite: isFavorite,
                onAddToCart: () {
                  onAddToCart(product);
                  setDelegateState(() {});
                },
                onToggleWishlist: () {
                  onToggleWishlist(product);
                  setDelegateState(() {});
                },
                onTap: () {
                  close(context, null);
                  context.pushNamed(
                    'ProductDetail',
                    pathParameters: {
                      'productId': product['id'].toString(),
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class SearchProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;
  final VoidCallback onTap;

  const SearchProductTile({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                product['image_url'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹${product['price']}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: primaryGold,
                          ),
                        ),
                        if (product['original_price'] != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '₹${product['original_price']}',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (product['discount'] != null)
                      Text(
                        '${product['discount']}% OFF',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: discountTeal,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : textPrimary,
                      size: 22,
                    ),
                    onPressed: onToggleWishlist,
                  ),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: onAddToCart,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryDarkBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        'ADD CART',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryDarkBlue,
                        ),
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

// --- SHIMMER WIDGETS ---
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1200.ms,
          color: Colors.white.withOpacity(0.6),
        );
  }
}

class ProductDetailShimmerMobile extends StatelessWidget {
  const ProductDetailShimmerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        centerTitle: true,
        title: const ShimmerBox(width: 100, height: 20),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ShimmerBox(
                width: double.infinity, height: 500, borderRadius: 0),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const ShimmerBox(width: 200, height: 28),
                  const SizedBox(height: 12),
                  const ShimmerBox(width: 100, height: 24),
                  const SizedBox(height: 32),
                  const ShimmerBox(width: 140, height: 40),
                  const SizedBox(height: 32),
                  const ShimmerBox(
                      width: double.infinity, height: 50, borderRadius: 25),
                  const SizedBox(height: 16),
                  const ShimmerBox(
                      width: double.infinity, height: 50, borderRadius: 25),
                  const SizedBox(height: 48),
                  ...List.generate(
                      3,
                      (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ShimmerBox(width: 120, height: 16),
                                const SizedBox(height: 8),
                                const ShimmerBox(
                                    width: double.infinity, height: 14),
                                const SizedBox(height: 4),
                                const ShimmerBox(width: 200, height: 14),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailShimmerDesktop extends StatelessWidget {
  const ProductDetailShimmerDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          // Mock Navbar Shimmer
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              children: [
                const ShimmerBox(width: 150, height: 40),
                const Spacer(),
                Row(
                  children: List.generate(
                    4,
                    (index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ShimmerBox(width: 80, height: 16),
                    ),
                  ),
                ),
                const Spacer(),
                const ShimmerBox(width: 100, height: 30),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Shimmer
                  const Expanded(
                    flex: 1,
                    child: ShimmerBox(width: double.infinity, height: 700),
                  ),
                  const SizedBox(width: 60),
                  // Details Shimmer
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerBox(width: 300, height: 36),
                        const SizedBox(height: 20),
                        const ShimmerBox(width: 150, height: 28),
                        const SizedBox(height: 40),
                        const ShimmerBox(width: 140, height: 45),
                        const SizedBox(height: 40),
                        const ShimmerBox(
                            width: double.infinity,
                            height: 50,
                            borderRadius: 25),
                        const SizedBox(height: 16),
                        const ShimmerBox(
                            width: double.infinity,
                            height: 50,
                            borderRadius: 25),
                        const SizedBox(height: 40),
                        ...List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                ShimmerBox(width: 150, height: 18),
                                SizedBox(height: 12),
                                ShimmerBox(width: double.infinity, height: 14),
                                SizedBox(height: 6),
                                ShimmerBox(width: 300, height: 14),
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
          ),
        ],
      ),
    );
  }
}
