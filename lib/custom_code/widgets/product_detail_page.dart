import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'responsive_layout.dart';
import 'product_detail_page_mobile.dart';
import 'product_detail_page_desktop.dart';

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

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _buyNow() async {
    final product = widget.product;
    final total = product['price'] * quantity;

    final StringBuffer message = StringBuffer();
    message.writeln('*New Instant Order Request*');
    message.writeln('----------------');
    message.writeln('${product['name']} x $quantity: ₹$total');
    message.writeln('----------------');
    message.writeln('*Total: ₹$total*');

    final String whatsappUrl =
        'https://wa.me/919496905158?text=${Uri.encodeComponent(message.toString())}';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
