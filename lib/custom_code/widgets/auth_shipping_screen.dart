import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'shipping_details_form.dart';

class AuthShippingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AuthShippingScreen({super.key, required this.onComplete});

  @override
  State<AuthShippingScreen> createState() => _AuthShippingScreenState();
}

class _AuthShippingScreenState extends State<AuthShippingScreen> {
  bool _isLoading = true;
  bool _showForm = true;
  Map<String, dynamic> _shippingData = {};
  String? _guestUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Get or Create Guest ID
    String? userId = prefs.getString('guest_user_id');
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('guest_user_id', userId);
    }
    _guestUserId = userId;

    // Load Shipping Info
    final name = prefs.getString('ship_full_name');
    final phone = prefs.getString('ship_phone');

    // If we have basic info, assume we have data
    if (name != null && name.isNotEmpty && phone != null && phone.isNotEmpty) {
      setState(() {
        _shippingData = {
          'full_name': name,
          'email': prefs.getString('ship_email') ?? '',
          'phone_number': phone,
          'address_line1': prefs.getString('ship_address') ?? '',
          'street_name': prefs.getString('ship_street') ?? '',
          'area_name': prefs.getString('ship_area') ?? '',
          'state_name': prefs.getString('ship_state') ?? '',
          'pincode': prefs.getString('ship_pincode') ?? '',
          'city_name': prefs.getString('ship_city') ?? '',
          'country_code': prefs.getString('ship_country_code') ?? '+91',
        };
        _showForm = false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _showForm = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToTable(Map<String, dynamic> data) async {
    // Only save to Supabase table if user is authenticated
    final user = SupaFlow.client.auth.currentUser;
    if (user == null) {
      // Guest user: Data is already saved to LocalStorage in ShippingDetailsForm
      // We do NOT save to 'user_shipping_details' because it requires a valid auth.users FK.
      return;
    }

    try {
      await SupaFlow.client.from('user_shipping_details').upsert({
        'user_id': user.id,
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Supabase Save Error (Auth Flow): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF997C5B)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.nunitoSans(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _showForm
                  ? ShippingDetailsForm(
                      initialData:
                          _shippingData.isNotEmpty ? _shippingData : null,
                      onSubmit: (data) async {
                        setState(() => _isLoading = true);

                        // Update local state
                        _shippingData = data;

                        // Save to Table (Try/Catch)
                        await _saveToTable(data);

                        setState(() {
                          _isLoading = false;
                          _showForm = false;
                        });
                      },
                    )
                  : _buildSummaryStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStep() {
    return Column(
      key: const ValueKey('summary_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping To',
                style: GoogleFonts.nunitoSans(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: Color(0xFF997C5B)),
              label: Text('EDIT',
                  style: GoogleFonts.nunitoSans(
                      color: const Color(0xFF997C5B),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow(
                  Icons.person_outline, _shippingData['full_name'] ?? ''),
              const SizedBox(height: 12),
              _summaryRow(
                  Icons.phone_outlined, _shippingData['phone_number'] ?? ''),
              const SizedBox(height: 12),
              _summaryRow(Icons.email_outlined, _shippingData['email'] ?? ''),
              const Divider(height: 32),
              _summaryRow(Icons.location_on_outlined,
                  "${_shippingData['address_line1']}, ${_shippingData['street_name']}\n${_shippingData['area_name']}, ${_shippingData['city_name']}\n${_shippingData['state_name']} - ${_shippingData['pincode']}"),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: widget.onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF997C5B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('CONTINUE TO PAYMENT',
                style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: GoogleFonts.nunitoSans(
                  fontSize: 15, color: Colors.black87, height: 1.4)),
        ),
      ],
    );
  }
}
