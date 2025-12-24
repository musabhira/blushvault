import 'package:flutter/material.dart';
import 'package:blushvault/custom_code/widgets/cart_page_mobile.dart';
import 'package:blushvault/custom_code/widgets/cart_page_desktop.dart';
import 'package:blushvault/custom_code/widgets/responsive_layout.dart';

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final Function(int) onRemove;
  final Function(int, int) onUpdateQuantity;
  final Function(int) onMoveToWishlist;
  final List<Map<String, dynamic>> wishlist;
  final Function(Map<String, dynamic>) onToggleWishlist;
  final VoidCallback onShowCart;

  const CartPage({
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
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: CartPageMobile(
        cart: cart,
        onRemove: onRemove,
        onUpdateQuantity: onUpdateQuantity,
        onMoveToWishlist: onMoveToWishlist,
        wishlist: wishlist,
        onToggleWishlist: onToggleWishlist,
        onShowCart: onShowCart,
      ),
      desktopBody: CartPageDesktop(
        cart: cart,
        onRemove: onRemove,
        onUpdateQuantity: onUpdateQuantity,
        onMoveToWishlist: onMoveToWishlist,
        wishlist: wishlist,
        onToggleWishlist: onToggleWishlist,
        onShowCart: onShowCart,
      ),
    );
  }
}
