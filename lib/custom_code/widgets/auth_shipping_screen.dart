import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'shipping_details_form.dart';

class AuthShippingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AuthShippingScreen({super.key, required this.onComplete});

  @override
  State<AuthShippingScreen> createState() => _AuthShippingScreenState();
}

class _AuthShippingScreenState extends State<AuthShippingScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _showShipping = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // If already logged in, skip to shipping
    if (SupaFlow.client.auth.currentUser != null) {
      _showShipping = true;
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await SupaFlow.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await SupaFlow.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Account created! Please verify your email if required.')),
        );
      }

      // Check if shipping data exists
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        final existingData = await SupaFlow.client
            .from('user_shipping_details')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (existingData != null) {
          // Already have data, complete now
          widget.onComplete();
        } else {
          // Move to shipping step
          setState(() => _showShipping = true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF8), // Soft cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _showShipping ? _buildShippingStep() : _buildAuthStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthStep() {
    return Column(
      key: const ValueKey('auth_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Logo
        Image.network(
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/blushvault-jw8pdn/assets/gpx3poi3nbc1/Asset_25.png',
          height: 40,
        ),
        const SizedBox(height: 40),
        Text(
          _isLogin ? 'Welcome Back' : 'Create Account',
          style: GoogleFonts.nunitoSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Login to proceed with your order.'
              : 'Join BlushVault for a better shopping experience.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                validator: (v) => v == null || v.length < 6
                    ? 'Password must be 6+ characters'
                    : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF997C5B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isLogin ? 'LOG IN' : 'SIGN UP',
                          style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin
                      ? "Don't have an account? "
                      : "Already have an account? "),
                  GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? "Sign Up" : "Log In",
                      style: const TextStyle(
                        color: Color(0xFF997C5B),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingStep() {
    return Column(
      key: const ValueKey('shipping_step'),
      children: [
        // Progress indicator
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('Account Verified',
                style: GoogleFonts.nunitoSans(
                    color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
        ShippingDetailsForm(
          onSubmit: (phone, address) async {
            setState(() => _isLoading = true);
            try {
              final user = SupaFlow.client.auth.currentUser;
              await SupaFlow.client.from('user_shipping_details').upsert({
                'user_id': user!.id,
                'phone_number': phone,
                'address': address,
                'updated_at': DateTime.now().toIso8601String(),
              });
              widget.onComplete();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error saving details: $e'),
                    backgroundColor: Colors.red),
              );
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
        ),
      ],
    );
  }
}
