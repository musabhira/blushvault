import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingDetailsForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic> data) onSubmit;

  const ShippingDetailsForm({
    super.key,
    this.initialData,
    required this.onSubmit,
  });

  @override
  State<ShippingDetailsForm> createState() => _ShippingDetailsFormState();
}

class _ShippingDetailsFormState extends State<ShippingDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _streetController;
  late TextEditingController _areaController;
  late TextEditingController _pincodeController;
  late TextEditingController _cityController;

  String _selectedState = 'Select state';
  String _selectedCountryCode = '+91';

  final List<String> _states = [
    'Select state',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

  final List<String> _countryCodes = [
    '+91',
    '+1',
    '+44',
    '+61',
    '+81',
    '+49',
    '+33'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadFromLocalStorage();
  }

  void _initializeControllers() {
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?['full_name'] ?? '');
    _emailController = TextEditingController(text: data?['email'] ?? '');
    _phoneController = TextEditingController(text: data?['phone_number'] ?? '');
    _addressController =
        TextEditingController(text: data?['address_line1'] ?? '');
    _streetController = TextEditingController(text: data?['street_name'] ?? '');
    _areaController = TextEditingController(text: data?['area_name'] ?? '');
    _pincodeController = TextEditingController(text: data?['pincode'] ?? '');
    _cityController = TextEditingController(text: data?['city_name'] ?? '');
    _selectedState = data?['state_name'] ?? 'Select state';
  }

  Future<void> _loadFromLocalStorage() async {
    if (widget.initialData != null) return; // Don't override if data is passed

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('ship_full_name') ?? '';
      _emailController.text = prefs.getString('ship_email') ?? '';
      _phoneController.text = prefs.getString('ship_phone') ?? '';
      _addressController.text = prefs.getString('ship_address') ?? '';
      _streetController.text = prefs.getString('ship_street') ?? '';
      _areaController.text = prefs.getString('ship_area') ?? '';
      _pincodeController.text = prefs.getString('ship_pincode') ?? '';
      _cityController.text = prefs.getString('ship_city') ?? '';
      _selectedState = prefs.getString('ship_state') ?? 'Select state';
      _selectedCountryCode = prefs.getString('ship_country_code') ?? '+91';
    });
  }

  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ship_full_name', _nameController.text.trim());
    await prefs.setString('ship_email', _emailController.text.trim());
    await prefs.setString('ship_phone', _phoneController.text.trim());
    await prefs.setString('ship_address', _addressController.text.trim());
    await prefs.setString('ship_street', _streetController.text.trim());
    await prefs.setString('ship_area', _areaController.text.trim());
    await prefs.setString('ship_pincode', _pincodeController.text.trim());
    await prefs.setString('ship_city', _cityController.text.trim());
    await prefs.setString('ship_state', _selectedState);
    await prefs.setString('ship_country_code', _selectedCountryCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.nunitoSans(color: Colors.black54, fontSize: 14),
      hintStyle: GoogleFonts.nunitoSans(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF997C5B)),
      ),
      errorStyle: GoogleFonts.nunitoSans(color: Colors.red[400], fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Add Address',
              style: GoogleFonts.nunitoSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Name'),
              style: const TextStyle(color: Colors.black),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration('Email'),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 16),

            // Phone Row with Country Code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: _countryCodes.contains(_selectedCountryCode)
                          ? _selectedCountryCode
                          : _countryCodes.first,
                      items: _countryCodes
                          .map((code) => DropdownMenuItem(
                                value: code,
                                child: Text(code,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black)),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCountryCode = val!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Phone'),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Phone number required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address Line 1
            TextFormField(
              controller: _addressController,
              decoration: _inputDecoration(
                  'Address ( House No/Name : 123, Rose Apartment )'),
              style: const TextStyle(color: Colors.black),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            // Street and Area Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _streetController,
                    decoration: _inputDecoration('Post / Street : MG Road'),
                    style: const TextStyle(color: Colors.black),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Street name is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _areaController,
                    decoration: _inputDecoration('Landmark / Area : Nearby...'),
                    style: const TextStyle(color: Colors.black),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Area is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // State Dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _states.contains(_selectedState)
                    ? _selectedState
                    : _states.first,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
                items: _states
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s,
                            style: GoogleFonts.nunitoSans(
                                fontSize: 14, color: Colors.black))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedState = v!),
                validator: (v) =>
                    v == 'Select state' ? 'State is required' : null,
              ),
            ),
            const SizedBox(height: 16),

            // PIN Code
            TextFormField(
              controller: _pincodeController,
              decoration: _inputDecoration('PIN Code'),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Pincode is required' : null,
            ),
            const SizedBox(height: 16),

            // City
            TextFormField(
              controller: _cityController,
              decoration: _inputDecoration('City/District',
                  hint: 'E.g. Kochi, Bangalore'),
              style: const TextStyle(color: Colors.black),
              validator: (v) =>
                  v == null || v.isEmpty ? 'City/District is required' : null,
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveToLocalStorage();
                    widget.onSubmit({
                      'full_name': _nameController.text.trim(),
                      'email': _emailController.text.trim(),
                      'phone_number':
                          "$_selectedCountryCode ${_phoneController.text.trim()}",
                      'address_line1': _addressController.text.trim(),
                      'street_name': _streetController.text.trim(),
                      'area_name': _areaController.text.trim(),
                      'state_name': _selectedState,
                      'pincode': _pincodeController.text.trim(),
                      'city_name': _cityController.text.trim(),
                      'updated_at': DateTime.now().toIso8601String(),
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF997C5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  'PROCEED TO PAYMENT',
                  style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
