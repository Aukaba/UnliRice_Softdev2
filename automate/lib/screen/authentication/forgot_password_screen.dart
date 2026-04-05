import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Logic/authentication/reset_password.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSending = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  static const _amber = Color(0xFFFFC107);
  static const _blue = Color(0xFF5584AC);
  static const _grey = Color(0xFF9E9E9E);
  static const _borderColor = Color(0xFFD0D0D0);

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email.');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSending = true;
    });
    try {
      await ResetPasswordLogic.forgotPassword(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (email.isEmpty || otp.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and OTP.');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      await ResetPasswordLogic.verifyOtp(email: email, token: otp);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Shared input decoration — no floating label, clean border
  InputDecoration _inputDecoration({Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      // Disable the floating label entirely
      floatingLabelBehavior: FloatingLabelBehavior.never,
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── TOP-LEFT large gold circle ──────────────────────────────────
          Positioned(
            top: -size.height * 0.08,
            left: -size.width * 0.22,
            child: _circle(size.width * 0.88, _amber),
          ),

          // ── MID-RIGHT medium gold circle ────────────────────────────────
          Positioned(
            top: size.height * 0.40,
            right: -size.width * 0.30,
            child: _circle(size.width * 0.62, _amber),
          ),

          // ── BOTTOM-LEFT small gold circle ───────────────────────────────
          Positioned(
            bottom: -size.width * 0.16,
            left: -size.width * 0.14,
            child: _circle(size.width * 0.45, _amber),
          ),

          // ── MAIN CONTENT ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back arrow
                IconButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.black87, size: 26),
                  onPressed: () => Navigator.pop(context),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        const SizedBox(height: 8),
                        Center(
                          child: Image.asset(
                            'assets/images/AutoMate_logo.png',
                            width: size.width * 0.75,
                            height: size.width * 0.75,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Title
                        const SizedBox(height: 36),
                        Center(
                          child: Text(
                            'Forget Password',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Error banner
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade700, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ── Enter Email label ─────────────────────────────
                        const SizedBox(height: 28),
                        Text(
                          'Enter Email',
                          style: GoogleFonts.inriaSans(
                              fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),

                        // ── Email row: field + Send button ────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.inriaSans(
                                    fontSize: 14, color: Colors.black87),
                                decoration: _inputDecoration(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSending ? null : _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                ),
                                child: _isSending
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : Text(
                                        'Send',
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13),
                                      ),
                              ),
                            ),
                          ],
                        ),

                        // ── Enter OTP label ───────────────────────────────
                        const SizedBox(height: 20),
                        Text(
                          'Enter OTP',
                          style: GoogleFonts.inriaSans(
                              fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),

                        // ── OTP field ─────────────────────────────────────
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inriaSans(
                              fontSize: 14, color: Colors.black87),
                          decoration: _inputDecoration(),
                        ),

                        // ── Enter button ──────────────────────────────────
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.white),
                                  )
                                : Text(
                                    'Enter',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
