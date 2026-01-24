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
      openRazorpayWeb(options, _handleWebSuccess, _handleWebFailure);
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

  void _handleWebSuccess(String paymentId) {
    _handlePaymentSuccess(PaymentSuccessResponse(paymentId, null, null, null));
  }

  void _handleWebFailure(String message) {
    onFailure(message);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Navigate to Success Page
    // Using context.goNamed requires the route to be registered.
    // We added 'PaymentSuccess' route in nav.dart

    try {
      context.pushNamed('PaymentSuccess', pathParameters: {
        'paymentId': response.paymentId ?? ''
      } // Using pathParameters if defined as /:id or queryParams if not
          );
      // Note: In nav.dart I defined path as /payment_success
      // And retrieved param via params.getParam.
      // Usually GoRouter uses query params for extra data if not in path.
      // Let's use context.pushNamed with queryParameters if getParam handles it.
      // Actually Nav.dart uses params.getParam which usually looks at all params.
      // I will use extra object or query params.

      // Let's use pushNamed (which pushes a new page on stack)
      context.pushNamed('PaymentSuccess',
          queryParameters: {'paymentId': response.paymentId ?? ''});
    } catch (e) {
      print("Navigation Error: $e");
    }

    onSuccess(response.paymentId ?? '');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure(response.message ?? 'Payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onFailure('External wallet selected: ${response.walletName}');
  }
}
