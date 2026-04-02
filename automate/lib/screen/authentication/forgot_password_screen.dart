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

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage = 'Please enter your email.');
      }
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
        setState(
          () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (email.isEmpty || otp.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage = 'Please enter email and OTP.');
      }
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
        setState(
          () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Gold circle — top left (large, partially off-screen) ──────────
          Positioned(
            top: -size.height * 0.10,
            left: -size.width * 0.25,
            child: Container(
              width: size.width * 0.90,
              height: size.width * 0.90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFC107),
              ),
            ),
          ),

          // ── Gold circle — mid right (medium, partially off-screen) ────────
          Positioned(
            top: size.height * 0.38,
            right: -size.width * 0.28,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFC107),
              ),
            ),
          ),

          // ── Gold circle — bottom left (small, partially off-screen) ───────
          Positioned(
            bottom: -size.width * 0.18,
            left: -size.width * 0.15,
            child: Container(
              width: size.width * 0.48,
              height: size.width * 0.48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFC107),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back arrow
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, top: 4.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 26,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo ─────────────────────────────────────────
                        const SizedBox(height: 8),
                        Center(
                          child: Image.asset(
                            'assets/images/AutoMate_logo.png',
                            width: size.width * 0.75,
                            height: size.width * 0.75,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // ── Title ─────────────────────────────────────────
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

                        // ── Error message ─────────────────────────────────
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
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                    ),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // ── Email field + Send button ─────────────────────
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD0D0D0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Text input
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.inriaSans(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 0,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),

                              // Send button — anchored to right inside the field
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: SizedBox(
                                  height: 38,
                                  child: ElevatedButton(
                                    onPressed: _isSending ? null : _sendOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5584AC),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                    ),
                                    child: _isSending
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Send',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Enter OTP label ───────────────────────────────
                        const SizedBox(height: 22),
                        Text(
                          'Enter OTP',
                          style: GoogleFonts.inriaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // ── OTP field ─────────────────────────────────────
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD0D0D0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inriaSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 0,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),

                        // ── Enter button ──────────────────────────────────
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9E9E9E),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(
                                0xFF9E9E9E,
                              ).withOpacity(0.6),
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
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Enter',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
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
}
