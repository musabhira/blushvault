import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductDetailPageDesktop extends StatefulWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Future<void> Function() onBuyNow;
  final Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const ProductDetailPageDesktop({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onBuyNow,
    required this.onAddToCart,
    required this.wishlist,
    required this.onToggleWishlist,
    required this.onShowCart,
  });

  @override
  State<ProductDetailPageDesktop> createState() =>
      _ProductDetailPageDesktopState();
}

class _ProductDetailPageDesktopState extends State<ProductDetailPageDesktop> {
  // Mock list of duplicate images for the gallery
  List<String> get _images {
    final List<String> allImages = [];
    final String mainImage = widget.product['image_url'] ?? '';

    if (mainImage.isNotEmpty) {
      allImages.add(mainImage);
    }

    if (widget.product['images'] != null && widget.product['images'] is List) {
      final List<dynamic> extraImages = widget.product['images'];
      for (var img in extraImages) {
        final imgUrl = img.toString();
        if (imgUrl.isNotEmpty && imgUrl != mainImage) {
          allImages.add(imgUrl);
        }
      }
    }
    return allImages;
  }

  final PageController _pageController = PageController();
  int _selectedImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 300,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.network(
              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.black),
                  onPressed: widget.onShowCart,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(100, 60, 100, 100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- LEFT: IMAGE GALLERY ---
              Expanded(
                flex: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnails Strip
                    SizedBox(
                      width: 80,
                      height: 600, // Constrained height for scrolling list
                      child: ListView.separated(
                        itemCount: _images.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedImageIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedImageIndex = index);
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(color: Colors.black, width: 1)
                                    : null,
                              ),
                              child: Image.network(
                                _images[index],
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Main Image (Sticky-ish behavior visual)
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 0.8,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _selectedImageIndex = index),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              _images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 80),

              // --- RIGHT: PRODUCT INFO (Sticky Column) ---
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product['name']?.toUpperCase() ?? '',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w400, // Light/Regular
                              letterSpacing: 1.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            widget.wishlist.any((item) =>
                                    item['id'] == widget.product['id'])
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.wishlist.any((item) =>
                                    item['id'] == widget.product['id'])
                                ? Colors.red
                                : Colors.black,
                          ),
                          onPressed: () =>
                              widget.onToggleWishlist(widget.product),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '₹${widget.product['price']}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (widget.product['original_price'] != null) ...[
                          const SizedBox(width: 16),
                          Text(
                            '₹${widget.product['original_price']}',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Free Shipping on orders above ₹999',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Quantity
                    Text(
                      'QUANTITY',
                      style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: widget.onDecrement,
                            icon: const Icon(Icons.remove, size: 16),
                          ),
                          Text('${widget.quantity}',
                              style: GoogleFonts.nunitoSans(
                                  fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: widget.onIncrement,
                            icon: const Icon(Icons.add, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => widget.onAddToCart(
                                  widget.product,
                                  quantity: widget.quantity),
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFF997C5B)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'ADD TO CART',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF997C5B),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: widget.onBuyNow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF997C5B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'BUY IT NOW',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Accordions
                    _buildAccordion(
                      'DESCRIPTION',
                      widget.product['description'] ??
                          'The Sacred Prism Necklace is a modern amulet, designed to reflect light and energy. \n\nHandcrafted in 18k gold plated brass. \nSet with custom cut crystals. \nNickel-free and hypoallergenic.',
                    ),
                    _buildAccordion(
                      'SHIPPING INFORMATION',
                      'We ship worldwide. \nFree standard shipping on international orders above \$200. \nDomestic orders are delivered within 3-5 business days.',
                    ),
                    _buildAccordion(
                      'WARRANTY',
                      'One year warranty on plating and manufacturing defects. Does not cover wear and tear.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordion(String title, String content) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.black,
          ),
        ),
        childrenPadding: const EdgeInsets.only(bottom: 24),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: const Color(0xFF555555),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
