import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'responsive_layout.dart';
import 'home_page_mobile.dart';
import 'home_page_desktop.dart';
import 'cart_page.dart';

// Export widgets used by mobile and desktop pages
import 'home_widgets.dart';
export 'home_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<dynamic> banners = [];
  List<dynamic> products = [];
  List<dynamic> categories = [];
  List<dynamic> gallery = [];
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> wishlist = [];
  bool isLoading = true;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    loadData();
    loadCart();
    loadWishlist();
  }

  Future<void> loadData() async {
    try {
      setState(() => isLoading = true);

      final bannersData = await supabase
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('order_position');

      // Cautious select for categories to handle potential schema updates
      dynamic categoriesData;
      try {
        categoriesData = await supabase
            .from('categories')
            .select('*, parent:categories!categories_parent_id_fkey(name)')
            .eq('is_active', true)
            .order('name');
      } catch (e) {
        print('Nested categories select failed, falling back: $e');
        categoriesData = await supabase
            .from('categories')
            .select()
            .eq('is_active', true)
            .order('name');
      }

      // Cautious select for products
      dynamic productsData;
      try {
        productsData = await supabase
            .from('products')
            .select(
                '*, category:categories!products_category_id_fkey(id, name), sub_category:categories!products_sub_category_id_fkey(name)')
            .eq('is_active', true)
            .order('created_at', ascending: false);
      } catch (e) {
        print('Nested products select failed, falling back to basic join: $e');
        try {
          // If the products_sub_category_id_fkey doesn't exist yet, try just the main category with explicit fkey
          productsData = await supabase
              .from('products')
              .select(
                  '*, category:categories!products_category_id_fkey(id, name)')
              .eq('is_active', true)
              .order('created_at', ascending: false);
        } catch (e2) {
          print('Explicit join fallback failed, trying legacy join: $e2');
          // Last resort: standard join (might fail if multiple fkeys exist)
          productsData = await supabase
              .from('products')
              .select('*, categories(name)')
              .eq('is_active', true)
              .order('created_at', ascending: false);
        }
      }

      final galleryData = await supabase
          .from('gallery')
          .select()
          .eq('is_active', true)
          .order('order_position');

      setState(() {
        banners = bannersData;
        products = productsData;
        categories = categoriesData;
        gallery = galleryData;
        isLoading = false;
      });
    } catch (e) {
      print('CRITICAL: Error loading data: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');
      if (cartJson != null) {
        setState(() {
          cart = List<Map<String, dynamic>>.from(
              json.decode(cartJson).map((x) => Map<String, dynamic>.from(x)));
        });
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(cart));
  }

  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist');
      if (wishlistJson != null) {
        setState(() {
          wishlist = List<Map<String, dynamic>>.from(json
              .decode(wishlistJson)
              .map((x) => Map<String, dynamic>.from(x)));
        });
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  Future<void> saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist', json.encode(wishlist));
  }

  void toggleWishlist(Map<String, dynamic> product) {
    setState(() {
      final index = wishlist.indexWhere((item) => item['id'] == product['id']);
      if (index != -1) {
        wishlist.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            duration: Duration(seconds: 1),
            backgroundColor: bgLight,
            elevation: 0,
          ),
        );
      } else {
        wishlist.add(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to wishlist'),
            duration: Duration(seconds: 1),
            backgroundColor: bgLight,
            elevation: 0,
          ),
        );
      }
      saveWishlist();
    });
  }

  void addToCart(Map<String, dynamic> product, {int quantity = 1}) {
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
      saveCart();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
        duration: const Duration(seconds: 2),
        backgroundColor: bgLight,
      ),
    );
  }

  void removeFromCart(int index) {
    setState(() {
      cart.removeAt(index);
      saveCart();
    });
  }

  void moveToWishlist(int index) {
    final item = cart[index];
    // Convert cart item back to product format if needed
    // Assuming product data is already in the item or can be found
    final product = products.firstWhere((p) => p['id'] == item['id'],
        orElse: () => {
              'id': item['id'],
              'name': item['name'],
              'price': item['price'],
              'image_url': item['image_url'],
              // original_price might be missing, try to find it
            });

    setState(() {
      // Toggle wishlist (add if not there)
      if (!wishlist.any((w) => w['id'] == product['id'])) {
        wishlist.add(product);
      }
      // Remove from cart
      cart.removeAt(index);
      saveWishlist();
      saveCart();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Moved to wishlist'),
        duration: Duration(seconds: 1),
        backgroundColor: bgLight,
        elevation: 0,
      ),
    );
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(index);
    } else {
      setState(() {
        cart[index]['quantity'] = newQuantity;
        saveCart();
      });
    }
  }

  void showCartDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cart: cart,
          onRemove: removeFromCart,
          onUpdateQuantity: updateQuantity,
          onMoveToWishlist: moveToWishlist,
          wishlist: wishlist,
          onToggleWishlist: toggleWishlist,
          onShowCart: showCartDialog,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: ResponsiveLayout(
        mobileBody: HomePageMobile(
          banners: banners,
          products: products,
          categories: categories,
          gallery: gallery,
          cart: cart,
          wishlist: wishlist,
          selectedCategory: selectedCategory,
          isLoading: isLoading,
          onCategorySelected: (cat) => setState(() => selectedCategory = cat),
          onAddToCart: addToCart,
          onToggleWishlist: toggleWishlist,
          onShowCart: showCartDialog,
          onMoveToWishlist: moveToWishlist,
        ),
        desktopBody: HomePageDesktop(
          banners: banners,
          products: products,
          categories: categories,
          gallery: gallery,
          cart: cart,
          wishlist: wishlist,
          selectedCategory: selectedCategory,
          isLoading: isLoading,
          onCategorySelected: (cat) => setState(() => selectedCategory = cat),
          onAddToCart: addToCart,
          onToggleWishlist: toggleWishlist,
          onShowCart: showCartDialog,
          onMoveToWishlist: moveToWishlist,
        ),
      ),
    );
  }
}
