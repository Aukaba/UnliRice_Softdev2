import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Basic placeholder for the Next Screen as requested
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: const Center(child: Text('Reset Password Screen coming soon')),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP command executed!')),
    );
  }

  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gold Circles mimicking the custom overlapping graphics
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFBF00),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFBF00),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFBF00),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Back Arrow
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // AutoMate Logo Mockup / Loading from assets if exists
                        SizedBox(
                          height: 120,
                          child: Image.asset(
                            'assets/logo.png',
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback layout representing the logo in case asset is not placed yet
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()..rotateZ(-0.5),
                                        child: const Icon(Icons.build, color: Color(0xFF16477A), size: 40),
                                      ),
                                      const Icon(Icons.location_on, color: Color(0xFF5584AC), size: 60),
                                      Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()..rotateY(math.pi)..rotateZ(-0.5),
                                        child: const Icon(Icons.build, color: Color(0xFF16477A), size: 40),
                                      ),
                                    ],
                                  ),
                                  RichText(
                                    text: const TextSpan(
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Montserrat'),
                                      children: [
                                        TextSpan(text: 'Auto', style: TextStyle(color: Color(0xFF16477A))),
                                        TextSpan(text: 'Mate', style: TextStyle(color: Color(0xFFFFBF00))),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 48),

                        Text(
                          'Forget Password',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        
                        const SizedBox(height: 48),

                        // Enter Email Field mapped correctly
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter Email',
                            style: GoogleFonts.inriaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                  child: ElevatedButton(
                                    onPressed: _sendOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5584AC), // Exact requested Blue
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                    ),
                                    child: Text(
                                      'Send',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Enter OTP
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter OTP',
                            style: GoogleFonts.inriaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              isDense: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Enter Bottom Button (Gray)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9F9F9F), // Exact requested deep grey
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Enter',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 64),
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
