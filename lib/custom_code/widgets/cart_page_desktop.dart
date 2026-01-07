import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_widgets.dart';

class CartPageDesktop extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function(int) onRemove;
  final Function(int, int) onUpdateQuantity;
  final Function(int) onMoveToWishlist;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const CartPageDesktop({
    super.key,
    required this.cart,
    required this.onRemove,
    required this.onUpdateQuantity,
    required this.onMoveToWishlist,
    required this.wishlist,
    required this.onToggleWishlist,
    required this.onShowCart,
  });

  @override
  State<CartPageDesktop> createState() => _CartPageDesktopState();
}

class _CartPageDesktopState extends State<CartPageDesktop> {
  double get _subtotal {
    return widget.cart
        .fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void _incrementQuantity(int index) {
    setState(() {
      widget.onUpdateQuantity(index, widget.cart[index]['quantity'] + 1);
    });
  }

  void _decrementQuantity(int index) {
    if (widget.cart[index]['quantity'] > 1) {
      setState(() {
        widget.onUpdateQuantity(index, widget.cart[index]['quantity'] - 1);
      });
    } else {
      _removeItem(index);
    }
  }

  void _removeItem(int index) {
    setState(() {
      widget.onRemove(index);
    });
  }

  Future<void> _launchWhatsApp() async {
    final StringBuffer message = StringBuffer();
    message.writeln('New Order Request');
    message.writeln('----------------');
    for (final item in widget.cart) {
      final double totalItemPrice =
          (item['price'] ?? 0.0) * (item['quantity'] ?? 1);
      message.writeln(
          '${item['name']} x ${item['quantity']}: ₹${totalItemPrice.toStringAsFixed(0)}');
    }
    message.writeln('----------------');
    message.writeln('Total: ₹${_subtotal.toStringAsFixed(2)}');

    final String whatsappUrl =
        'https://wa.me/919496905158?text=${Uri.encodeComponent(message.toString())}';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        leadingWidth: 300,
        leading: Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Image.network(
                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'YOUR BAG',
          style: GoogleFonts.nunitoSans(
            fontSize: 24,
            color: Colors.black,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CONTINUE SHOPPING',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
      body: widget.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.nunitoSans(
                        fontSize: 24, color: Colors.black),
                  ),
                ],
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LEFT: CART ITEMS ---
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Headers
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Text('PRODUCT',
                                      style: GoogleFonts.nunitoSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 1))),
                              Expanded(
                                  flex: 2,
                                  child: Center(
                                      child: Text('QUANTITY',
                                          style: GoogleFonts.nunitoSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 1,
                                              color: Colors.black)))),
                              Expanded(
                                  flex: 2,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('TOTAL',
                                          style: GoogleFonts.nunitoSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 1,
                                              color: Colors.black)))),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, color: Colors.black12),
                        const SizedBox(height: 16),
                        // List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.cart.length,
                          separatorBuilder: (context, index) => const Divider(
                              height: 48, thickness: 1, color: Colors.black12),
                          itemBuilder: (context, index) {
                            final item = widget.cart[index];
                            return Row(
                              children: [
                                // Product Info
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(item['image_url']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Text(
                                                  '₹${item['price']}',
                                                  style: GoogleFonts.nunitoSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        const Color(0xFFB08D63),
                                                  ),
                                                ),
                                                if (item['original_price'] !=
                                                    null) ...[
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    '₹${item['original_price']}',
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                      fontSize: 14,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            InkWell(
                                              onTap: () => widget
                                                  .onMoveToWishlist(index),
                                              child: Text(
                                                'MOVE TO WISHLIST',
                                                style: GoogleFonts.nunitoSans(
                                                  fontSize: 12,
                                                  color:
                                                      const Color(0xFF997C5B),
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Container(
                                      width: 120,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                                item['quantity'] == 1
                                                    ? Icons.delete_outline
                                                    : Icons.remove,
                                                size: 18,
                                                color: Colors.black),
                                            onPressed: () =>
                                                _decrementQuantity(index),
                                          ),
                                          Text('${item['quantity']}',
                                              style: GoogleFonts.nunitoSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                size: 18, color: Colors.black),
                                            onPressed: () =>
                                                _incrementQuantity(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Total
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 80),

                  // --- RIGHT: ORDER SUMMARY ---
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER SUMMARY',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: GoogleFonts.nunitoSans(
                                    fontSize: 16, color: Colors.black),
                              ),
                              Text(
                                'Rs. ${_subtotal.toStringAsFixed(2)}',
                                style: GoogleFonts.nunitoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Shipping, taxes, and discount codes calculated at checkout.',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 32),
                          // Discount Field Desktop
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Container(
                          //         height: 48,
                          //         padding: const EdgeInsets.symmetric(
                          //             horizontal: 16),
                          //         decoration: BoxDecoration(
                          //           border:
                          //               Border.all(color: Colors.grey[300]!),
                          //           color: Colors.white,
                          //         ),
                          //         alignment: Alignment.centerLeft,
                          //         child: Text(
                          //           'Discount Code',
                          //           style: GoogleFonts.nunitoSans(
                          //               color: Colors.grey),
                          //         ),
                          //       ),
                          //     ),
                          //     Container(
                          //       height: 48,
                          //       padding:
                          //           const EdgeInsets.symmetric(horizontal: 24),
                          //       color: Colors.black,
                          //       alignment: Alignment.center,
                          //       child: Text(
                          //         'APPLY',
                          //         style: GoogleFonts.nunitoSans(
                          //           color: Colors.white,
                          //           fontWeight: FontWeight.bold,
                          //           letterSpacing: 1,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 16),
                          // // Coupons
                          // Row(
                          //   children: [
                          //     const Icon(Icons.local_offer_outlined,
                          //         size: 16, color: Colors.purple),
                          //     const SizedBox(width: 8),
                          //     Text(
                          //       'You have 4 coupons here',
                          //       style: GoogleFonts.nunitoSans(
                          //         color: Colors.purple,
                          //         fontSize: 13,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _launchWhatsApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF997C5B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'CHECKOUT',
                                style: GoogleFonts.nunitoSans(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );

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
}
