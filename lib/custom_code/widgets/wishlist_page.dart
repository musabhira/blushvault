import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'product_detail_page.dart';

class WishlistPage extends StatefulWidget {
  final Map<String, dynamic>?
      productToAdd; // Optional: Pass a product to add immediately
  final Function(Map<String, dynamic>)? onAddToCart;
  final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>>? wishlist;
  final Function(Map<String, dynamic>)? onToggleWishlist;
  final VoidCallback onShowCart;

  const WishlistPage({
    super.key,
    this.productToAdd,
    this.onAddToCart,
    required this.cart,
    this.wishlist,
    this.onToggleWishlist,
    required this.onShowCart,
  });

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> _wishlist = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    if (widget.wishlist != null) {
      setState(() {
        _wishlist = List<Map<String, dynamic>>.from(widget.wishlist!);
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      final String? wishlistJson = prefs.getString('wishlist');
      if (wishlistJson != null) {
        setState(() {
          _wishlist = List<Map<String, dynamic>>.from(json
              .decode(wishlistJson)
              .map((x) => Map<String, dynamic>.from(x)));
        });
      }
    }

    if (widget.productToAdd != null) {
      _addToWishlist(widget.productToAdd!);
    }
  }

  Future<void> _addToWishlist(Map<String, dynamic> product) async {
    // Check if already exists
    if (_wishlist.any((item) => item['id'] == product['id'])) return;

    setState(() {
      _wishlist.add(product);
    });
    _saveWishlist();
  }

  Future<void> _removeFromWishlist(String id) async {
    setState(() {
      _wishlist.removeWhere((item) => item['id'] == id);
    });
    _saveWishlist();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('wishlist', json.encode(_wishlist));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1080;

    Widget content = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'WISHLIST',
          style: GoogleFonts.nunitoSans(
            color: Colors.black,
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.black, size: 24),
                onPressed: widget.onShowCart,
              ),
              if (widget.cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB08D63),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${widget.cart.length}',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _wishlist.length,
              itemBuilder: (context, index) {
                final product = _wishlist[index];
                return Stack(
                  children: [
                    // We can reuse ProductCard if accessible, or build a simple card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              product: product,
                              onAddToCart: (product, {int? quantity}) {
                                widget.onAddToCart?.call(product);
                              },
                              cart: widget.cart,
                              wishlist: widget.wishlist ?? _wishlist,
                              onToggleWishlist: (p) {
                                if (widget.onToggleWishlist != null) {
                                  widget.onToggleWishlist!(p);
                                } else {
                                  _removeFromWishlist(p['id']);
                                }
                              },
                              onShowCart: widget.onShowCart,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                child: Image.network(
                                  product['image_url'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunitoSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${product['price']}',
                                          style: GoogleFonts.nunitoSans(
                                            color: const Color(0xFFB08D63),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (product['original_price'] !=
                                            null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '₹${product['original_price']}',
                                            style: GoogleFonts.nunitoSans(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const Spacer(),
                                    if (widget.onAddToCart != null)
                                      SizedBox(
                                        width: double.infinity,
                                        child: GestureDetector(
                                          onTap: () {},
                                          behavior: HitTestBehavior.opaque,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                widget.onAddToCart!(product);
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              side: const BorderSide(
                                                  color: Colors.black),
                                            ),
                                            child: Text('ADD TO BAG',
                                                style: GoogleFonts.nunitoSans(
                                                    fontSize: 10,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _removeFromWishlist(product['id']),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );

    if (isDesktop) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: content,
          ),
        ),
      );
    }
    return content;
  }
}
