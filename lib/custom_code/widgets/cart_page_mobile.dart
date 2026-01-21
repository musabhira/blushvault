import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'razorpay_service.dart';

class CartPageMobile extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function(int) onRemove;
  final Function(int, int) onUpdateQuantity;
  final Function(int) onMoveToWishlist;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const CartPageMobile({
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
  State<CartPageMobile> createState() => _CartPageMobileState();
}

class _CartPageMobileState extends State<CartPageMobile> {
  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpayService = RazorpayService(
      context: context,
      cartItems: widget.cart,
      onSuccess: (paymentId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful! ID: $paymentId')),
        );
        // Here you would typically clear the cart and navigate to a success page
      },
      onFailure: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment Failed: $message'),
              backgroundColor: Colors.red),
        );
      },
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cart',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continue shopping',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.nunitoSans(
                        fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(item['image_url']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Quantity Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          _QuantityButton(
                                            icon: item['quantity'] == 1
                                                ? Icons.delete_outline
                                                : Icons.remove,
                                            onTap: () =>
                                                _decrementQuantity(index),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Text(
                                              '${item['quantity']}',
                                              style: GoogleFonts.nunitoSans(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          _QuantityButton(
                                            icon: Icons.add,
                                            onTap: () =>
                                                _incrementQuantity(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${item['price']}',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFB08D63),
                                          ),
                                        ),
                                        if (item['original_price'] != null)
                                          Text(
                                            '₹${item['original_price']}',
                                            style: GoogleFonts.nunitoSans(
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () => widget.onMoveToWishlist(index),
                                  child: Text(
                                    'Move to wishlist',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 12,
                                      color: const Color(0xFF997C5B),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Footer Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Rs. ${_subtotal.toStringAsFixed(2)}',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Discount Field
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Container(
                      //         height: 48,
                      //         padding:
                      //             const EdgeInsets.symmetric(horizontal: 16),
                      //         decoration: BoxDecoration(
                      //           border: Border.all(color: Colors.grey[300]!),
                      //           color: Colors.grey[100],
                      //         ),
                      //         alignment: Alignment.centerLeft,
                      //         child: Text(
                      //           'Discount Code',
                      //           style:
                      //               GoogleFonts.nunitoSans(color: Colors.grey),
                      //         ),
                      //       ),
                      //     ),
                      //     Container(
                      //       height: 48,
                      //       padding: const EdgeInsets.symmetric(horizontal: 32),
                      //       color: Colors.black,
                      //       alignment: Alignment.center,
                      //       child: Text(
                      //         'APPLY',
                      //         style: GoogleFonts.nunitoSans(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold,
                      //           letterSpacing: 1.5,
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
                      // const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () =>
                              _razorpayService.startCheckout(_subtotal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFF997C5B), // Purple color from reference
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'CHECK OUT',
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Shipping, taxes, and discount codes calculated at checkout.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          color: Colors.grey,
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }
}
