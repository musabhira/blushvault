import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'product_detail_page_mobile.dart';
import 'product_detail_page_desktop.dart';
import 'razorpay_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.cart,
    required this.wishlist,
    required this.onToggleWishlist,
    required this.onShowCart,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  late final RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      context: context,
      cartItems: _getCurrentItems(),
      onSuccess: (paymentId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Successful! Payment ID: $paymentId'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onFailure: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Failed: $message'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getCurrentItems() {
    return [
      {
        'id': widget.product['id'],
        'name': widget.product['name'],
        'price': widget.product['price'],
        'image_url': widget.product['image_url'],
        'quantity': quantity,
      }
    ];
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
      _razorpayService.cartItems = _getCurrentItems();
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        _razorpayService.cartItems = _getCurrentItems();
      });
    }
  }

  Future<void> _buyNow() async {
    final double total = (widget.product['price'] as num).toDouble() * quantity;
    await _razorpayService.startCheckout(total);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: ProductDetailPageMobile(
        product: widget.product,
        quantity: quantity,
        onIncrement: _incrementQuantity,
        onDecrement: _decrementQuantity,
        onBuyNow: _buyNow,
        onAddToCart: widget.onAddToCart,
        wishlist: widget.wishlist,
        onToggleWishlist: widget.onToggleWishlist,
        onShowCart: widget.onShowCart,
      ),
      desktopBody: ProductDetailPageDesktop(
        product: widget.product,
        quantity: quantity,
        onIncrement: _incrementQuantity,
        onDecrement: _decrementQuantity,
        onBuyNow: _buyNow,
        onAddToCart: widget.onAddToCart,
        wishlist: widget.wishlist,
        onToggleWishlist: widget.onToggleWishlist,
        onShowCart: widget.onShowCart,
      ),
    );
  }
}
