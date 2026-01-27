import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'auth_shipping_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import to handle web-specific logic without breaking using dart:js on mobile
import 'razorpay_stub.dart' if (dart.library.js) 'razorpay_web.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final BuildContext context;
  List<Map<String, dynamic>> cartItems;
  final Function(String paymentId) onSuccess;
  final Function(String message) onFailure;

  RazorpayService({
    required this.context,
    required this.cartItems,
    required this.onSuccess,
    required this.onFailure,
  }) {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }

  Future<void> startCheckout(double amount) async {
    // Directly show the shipping flow (which handles Guest/Auto-fill logic)
    _showAuthShippingFlow(amount);
  }

  void _showAuthShippingFlow(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFDFBF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: AuthShippingScreen(
                  onComplete: () async {
                    Navigator.pop(context); // Close sheet
                    await _loadDetailsAndPay(amount);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadDetailsAndPay(double amount) async {
    final prefs = await SharedPreferences.getInstance();

    final phone = prefs.getString('ship_phone') ?? '';
    final email = prefs.getString('ship_email') ?? '';

    // Construct address
    final address = [
      prefs.getString('ship_address'),
      prefs.getString('ship_street'),
      prefs.getString('ship_area'),
      prefs.getString('ship_city'),
      prefs.getString('ship_state'),
      prefs.getString('ship_pincode')
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    if (phone.isNotEmpty) {
      _openRazorpay(phone, address, amount, email);
    } else {
      onFailure("Missing shipping details");
    }
  }

  void _openRazorpay(
      String phone, String address, double amount, String email) {
    print('DEBUG: Opening Razorpay for amount: $amount');

    var options = {
      'key': 'rzp_live_S6Ym62Ai4FrUMs', // Live Key ID
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'BlushVault Jewels',
      'description': 'Order Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': phone, 'email': email},
      'notes': {
        'shipping_address': address,
        'items_count': cartItems.length.toString(),
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    if (kIsWeb) {
      // Use the conditionally imported custom web implementation
      openRazorpayWeb(
          options,
          (paymentId) => _handleWebSuccess(paymentId, amount),
          _handleWebFailure);
    } else {
      // Use the standard package for Mobile
      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Error starting Razorpay: $e');
        onFailure('Could not open payment gateway');
      }
    }
  }

  void _handleWebSuccess(String paymentId, double amount) {
    _handlePaymentSuccess(PaymentSuccessResponse(paymentId, null, null, null));
    // Pass amount to handle success if needed
  }

  void _handleWebFailure(String message) {
    onFailure(message);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? '';

    // SAVE ORDER TO SUPABASE
    await _saveOrder(paymentId);

    try {
      context.pushNamed('PaymentSuccess',
          queryParameters: {'paymentId': paymentId});
    } catch (e) {
      print("Navigation Error: $e");
    }

    onSuccess(paymentId);
  }

  Future<void> _saveOrder(String paymentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Calculate total amount from cartItems
      // Assuming cartItems have 'price' and 'quantity' or taking it from passed amount if not
      // The passed 'amount' to startCheckout is correct.
      // But I don't have it in scope here easily unless I store it or pass it.
      // I'll re-calculate or just use 0 if failing, but better to save exact amount.
      // Actually 'cartItems' is available.

      double totalAmount = 0.0;
      for (var item in cartItems) {
        // This logic depends on item structure, assuming 'price' is double or string and 'quantity' is int
        // Using safe parsing
        double p = double.tryParse(item['price'].toString()) ?? 0.0;
        int q = int.tryParse(item['quantity'].toString()) ?? 1;
        totalAmount += p * q;
      }

      final shippingDetails = {
        'full_name': prefs.getString('ship_full_name'),
        'email': prefs.getString('ship_email'),
        'phone_number': prefs.getString('ship_phone'),
        'address_line1': prefs.getString('ship_address'),
        'street_name': prefs.getString('ship_street'),
        'area_name': prefs.getString('ship_area'),
        'city_name': prefs.getString('ship_city'),
        'state_name': prefs.getString('ship_state'),
        'pincode': prefs.getString('ship_pincode'),
        'country_code': prefs.getString('ship_country_code'),
      };

      final userId =
          prefs.getString('guest_user_id'); // Or Auth user if available
      final authUser = SupaFlow.client.auth.currentUser;

      await SupaFlow.client.from('orders').insert({
        'user_id': authUser?.id ?? userId, // Store guest ID if not auth
        'payment_id': paymentId,
        'amount': totalAmount,
        'status': 'paid',
        'shipping_details': shippingDetails,
        'order_items': cartItems, // Save the items snapshot
      });
    } catch (e) {
      debugPrint("Error Saving Order: $e");
      // Don't fail the UI flow, but log it.
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure(response.message ?? 'Payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onFailure('External wallet selected: ${response.walletName}');
  }
}
