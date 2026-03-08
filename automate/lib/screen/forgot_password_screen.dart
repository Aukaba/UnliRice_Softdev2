import 'package:flutter/material.dart';
import '../Logic/auth_logic.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSendingOtp = false;
  bool _isVerifying = false;
  bool _otpSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email.');
      return;
    }
    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });
    try {
      await AuthLogic.forgotPassword(email: _emailController.text.trim());
      setState(() => _otpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter the OTP.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    try {
      await AuthLogic.verifyOtp(
        email: _emailController.text.trim(),
        token: _otpController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFC107);
    const darkBlue = Color(0xFF1A2B4A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Logo Header ──
          Stack(
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      left: -40,
                      child: _circle(140, amber),
                    ),
                    Positioned(
                      top: 40,
                      right: -40,
                      child: _circle(140, amber),
                    ),
                    Positioned(
                      bottom: -30,
                      left: 60,
                      child: _circle(100, amber),
                    ),
                  ],
                ),
              ),
              // Back button
              Positioned(
                top: 48,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: darkBlue),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Logo
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    _logo(),
                  ],
                ),
              ),
            ],
          ),

          // ── Form ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Forget Password',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email + Send
                  const Text('Enter Email',
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSendingOtp ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isSendingOtp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Send',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // OTP
                  const Text('Enter OTP',
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                    ),

                  // Enter button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isVerifying || !_otpSent) ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Enter',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _logo() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.build, color: Color(0xFF1A2B4A), size: 36),
            Icon(Icons.location_on, color: Color(0xFF1A2B4A), size: 40),
            Icon(Icons.build, color: Color(0xFF1A2B4A), size: 36),
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Auto',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4A)),
              ),
              TextSpan(
                text: 'Mate',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
