import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'product_detail_page.dart';
import 'home_widgets.dart';
import 'package:go_router/go_router.dart';
import 'cart_page.dart';

class ProductDetailsWrapper extends StatefulWidget {
  final String productId;

  const ProductDetailsWrapper({super.key, required this.productId});

  @override
  State<ProductDetailsWrapper> createState() => _ProductDetailsWrapperState();
}

class _ProductDetailsWrapperState extends State<ProductDetailsWrapper> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? product;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> wishlist = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      setState(() => isLoading = true);

      // Load Product
      final productData = await supabase
          .from('products')
          .select('*, category:categories!products_category_id_fkey(id, name)')
          .eq('id', widget.productId)
          .maybeSingle();

      if (productData == null) {
        setState(() {
          error = 'Product not found';
          isLoading = false;
        });
        return;
      }

      // Load Cart/Wishlist from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      final cartJson = prefs.getString('cart');
      if (cartJson != null) {
        cart = List<Map<String, dynamic>>.from(
            json.decode(cartJson).map((x) => Map<String, dynamic>.from(x)));
      }

      final wishlistJson = prefs.getString('wishlist');
      if (wishlistJson != null) {
        wishlist = List<Map<String, dynamic>>.from(
            json.decode(wishlistJson).map((x) => Map<String, dynamic>.from(x)));
      }

      setState(() {
        product = productData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading product: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(cart));
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist', json.encode(wishlist));
  }

  void _addToCart(Map<String, dynamic> product, {int quantity = 1}) {
    setState(() {
      final existingIndex =
          cart.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex != -1) {
        cart[existingIndex]['quantity'] += quantity;
      } else {
        cart.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'original_price': product['original_price'],
          'image_url': product['image_url'],
          'quantity': quantity,
        });
      }
      _saveCart();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${product['name']} added to cart'),
          backgroundColor: bgLight),
    );
  }

  void _toggleWishlist(Map<String, dynamic> product) {
    setState(() {
      final index = wishlist.indexWhere((item) => item['id'] == product['id']);
      if (index != -1) {
        wishlist.removeAt(index);
      } else {
        wishlist.add(product);
      }
      _saveWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFFB08D63))),
      );
    }

    if (error != null || product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.black),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(child: Text(error ?? 'Product not found')),
      );
    }

    return ProductDetailPage(
      product: product!,
      cart: cart,
      wishlist: wishlist,
      onAddToCart: _addToCart,
      onToggleWishlist: _toggleWishlist,
      onShowCart: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(
              cart: cart,
              onRemove: (index) {
                setState(() => cart.removeAt(index));
                _saveCart();
              },
              onUpdateQuantity: (index, qty) {
                setState(() => cart[index]['quantity'] = qty);
                _saveCart();
              },
              onMoveToWishlist: (index) {
                final item = cart[index];
                if (!wishlist.any((w) => w['id'] == item['id'])) {
                  wishlist.add(item); // Simple fallback
                }
                setState(() => cart.removeAt(index));
                _saveWishlist();
                _saveCart();
              },
              wishlist: wishlist,
              onToggleWishlist: _toggleWishlist,
              onShowCart: () {},
            ),
          ),
        );
      },
    );
  }
}
