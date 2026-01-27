import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '/backend/supabase/supabase.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String paymentId;

  const PaymentSuccessPage({super.key, required this.paymentId});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderData;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final data = await SupaFlow.client
          .from('orders')
          .select()
          .eq('payment_id', widget.paymentId)
          .maybeSingle(); // Get the single order matching payment ID

      if (mounted) {
        setState(() {
          _orderData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching order for success page: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchWhatsApp() async {
    if (_orderData == null) return;

    final id = _orderData!['id'].toString().substring(0, 8);
    final shipping = _orderData!['shipping_details'] ?? {};
    final fullName = shipping['full_name'] ?? 'Guest';
    final itemsList = _orderData!['order_items'] as List<dynamic>? ?? [];

    // Construct items string
    String itemsStr =
        itemsList.map((i) => "${i['name']} (Qty: ${i['quantity']})").join(', ');

    // Construct pre-filled message
    String message = "Hi BlushVault Support,\n\n"
        "I just placed an order with ID: #$id\n"
        "Payment ID: ${widget.paymentId}\n"
        "Customer: $fullName\n"
        "Items: $itemsStr\n\n"
        "Can you enable update me on the delivery status?";

    final url = Uri.parse(
        "https://wa.me/919496905158?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 80, color: Colors.green),
              ),
              const SizedBox(height: 32),
              Text(
                'Payment Successful!',
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for your order.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              if (widget.paymentId.isNotEmpty)
                Text(
                  'Transaction ID: ${widget.paymentId}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),

              const SizedBox(height: 48),

              // WhatsApp Support Button
              if (!_isLoading && _orderData != null)
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _launchWhatsApp,
                    icon: const FaIcon(FontAwesomeIcons.whatsapp,
                        color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    label: Text(
                      'Get Updates on WhatsApp',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFF25D366)),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: 200,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF997C5B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'CONTINUE SHOPPING',
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: const Color(0xFF997C5B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
