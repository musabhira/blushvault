import 'package:blushvault/custom_code/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailPageMobile extends StatefulWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Future<void> Function() onBuyNow;
  final Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const ProductDetailPageMobile({
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
  State<ProductDetailPageMobile> createState() =>
      _ProductDetailPageMobileState();
}

class _ProductDetailPageMobileState extends State<ProductDetailPageMobile> {
  final PageController _pageController = PageController();

  // Mock list of images (using the same one for demonstration)
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Image.network(
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
          height: 24,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: widget.onShowCart,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Full Width Image Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 500, // Large editorial images
                  child: PageView.builder(
                    controller: _pageController,
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
                Positioned(
                  bottom: 20,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _images.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      activeDotColor: Colors.black,
                      dotColor: Colors.grey,
                      expansionFactor: 3,
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => widget.onToggleWishlist(widget.product),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.wishlist.any(
                                (item) => item['id'] == widget.product['id'])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.wishlist.any(
                                (item) => item['id'] == widget.product['id'])
                            ? Colors.red
                            : Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Product Information
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center aligned
                children: [
                  Text(
                    widget.product['name']?.toUpperCase() ?? '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w400, // Lighter, editorial weight
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${widget.product['price']}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (widget.product['original_price'] != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '₹${widget.product['original_price']}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Quantity Selector
                  Container(
                    width: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(0), // Sharp edges
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: widget.onDecrement,
                          icon: const Icon(Icons.remove,
                              size: 16, color: Colors.black),
                          constraints: const BoxConstraints(minWidth: 40),
                        ),
                        Text(
                          '${widget.quantity}',
                          style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        IconButton(
                          onPressed: widget.onIncrement,
                          icon: const Icon(Icons.add,
                              size: 16, color: Colors.black),
                          constraints: const BoxConstraints(minWidth: 40),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => widget.onAddToCart(widget.product,
                          quantity: widget.quantity),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF997C5B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // Pill shape
                        ),
                      ),
                      child: Text(
                        'ADD TO CART',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF997C5B),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onBuyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF997C5B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // Pill shape
                        ),
                      ),
                      child: Text(
                        'BUY IT NOW',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Accordions (Product Details)
                  _buildAccordion(
                    'DESCRIPTION',
                    widget.product['description'] ??
                        'Handcrafted in 18k gold plated brass. \n\nHeight: 28 mm\nWidth: 15 mm\nWeight: 8g',
                  ),
                  _buildAccordion(
                    'SHIPPING & DELIVERY',
                    'Free express shipping on all orders. \nEstimated delivery: 3-5 business days.',
                  ),
                  _buildAccordion(
                    'CARE INSTRUCTIONS',
                    'Keep away from water/perfume. Store in provided pouch.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordion(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Text(
                content,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
