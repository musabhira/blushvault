import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_widgets.dart';

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

  void _showShareOptions() {
    final String currentBaseUrl = Uri.base.origin;
    final String productUrl =
        '$currentBaseUrl/detailpage/${widget.product['id']}';
    final String productName = widget.product['name'] ?? 'Product';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share Product',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _shareOption(
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () async {
                        Navigator.pop(context);
                        final String message =
                            'Check out this beautiful item from BlushVault: $productName\n$productUrl';
                        final String whatsappUrl =
                            'https://wa.me/?text=${Uri.encodeComponent(message)}';
                        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                          await launchUrl(Uri.parse(whatsappUrl),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    _shareOption(
                      icon: Icons.link,
                      label: 'Copy Link',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Clipboard.setData(ClipboardData(text: productUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product link copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 300,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withOpacity(0.05), height: 1),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => context.go('/'),
              child: Image.network(
                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
                height: 35,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black),
                  onPressed: _showShareOptions,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.black),
                      onPressed: widget.onShowCart,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 60, 40, 100),
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
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
                                        ? Border.all(
                                            color: Colors.black, width: 1)
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
                              letterSpacing: 1,
                              color: Colors.black),
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
                                icon: const Icon(Icons.remove,
                                    color: Colors.black, size: 16),
                              ),
                              Text('${widget.quantity}',
                                  style: GoogleFonts.nunitoSans(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              IconButton(
                                onPressed: widget.onIncrement,
                                icon: const Icon(Icons.add,
                                    color: Colors.black, size: 16),
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
                                  onPressed:
                                      (widget.product['stock_quantity'] ?? 0) >
                                              0
                                          ? () => widget.onAddToCart(
                                              widget.product,
                                              quantity: widget.quantity)
                                          : null,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color:
                                            (widget.product['stock_quantity'] ??
                                                        0) >
                                                    0
                                                ? const Color(0xFF997C5B)
                                                : Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    (widget.product['stock_quantity'] ?? 0) > 0
                                        ? 'ADD TO CART'
                                        : 'OUT OF STOCK',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          (widget.product['stock_quantity'] ??
                                                      0) >
                                                  0
                                              ? const Color(0xFF997C5B)
                                              : Colors.grey,
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
                                  onPressed:
                                      (widget.product['stock_quantity'] ?? 0) >
                                              0
                                          ? widget.onBuyNow
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (widget.product['stock_quantity'] ??
                                                    0) >
                                                0
                                            ? const Color(0xFF997C5B)
                                            : Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    (widget.product['stock_quantity'] ?? 0) > 0
                                        ? 'BUY IT NOW'
                                        : 'OUT OF STOCK',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          (widget.product['stock_quantity'] ??
                                                      0) >
                                                  0
                                              ? Colors.white
                                              : Colors.grey[600],
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
