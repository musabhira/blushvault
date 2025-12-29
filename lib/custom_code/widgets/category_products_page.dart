import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryProductsPage extends StatelessWidget {
  final String categoryName;
  final List<dynamic> allProducts;
  final List<dynamic> categories;
  final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>> wishlist;
  final void Function(Map<String, dynamic>, {int quantity}) onAddToCart;
  final void Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const CategoryProductsPage({
    super.key,
    required this.categoryName,
    required this.allProducts,
    required this.categories,
    required this.cart,
    required this.wishlist,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.onShowCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Center(child: Text('Products for $categoryName')),
    );
  }
}
