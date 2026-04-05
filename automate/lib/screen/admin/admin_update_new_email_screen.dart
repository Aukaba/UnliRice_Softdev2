import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUpdateNewEmailScreen extends StatefulWidget {
  final String verifiedEmail;
  const AdminUpdateNewEmailScreen({super.key, required this.verifiedEmail});

  @override
  State<AdminUpdateNewEmailScreen> createState() =>
      _AdminUpdateNewEmailScreenState();
}

class _AdminUpdateNewEmailScreenState extends State<AdminUpdateNewEmailScreen> {
  static final _supabase = Supabase.instance.client;

  final _newEmailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final newEmail = _newEmailController.text.trim();

    if (newEmail.isEmpty) {
      _showError('Please enter your new email.');
      return;
    }

    if (!newEmail.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));
      if (!mounted) return;
      _showEmailUpdatedDialog();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to update email. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEmailUpdatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 379,
          padding: const EdgeInsets.all(30),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFF164D83)),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF29A017).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF29A017),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Email Updated!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 24),

              // Go Back button
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx); // close dialog
                  // Pop back to profile (2 screens back — new email + otp screen)
                  Navigator.popUntil(
                    context,
                    (route) =>
                        route.settings.name == '/admin-profile' ||
                        route.isFirst,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF203C63),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFF164D83),
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Go Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Blue layered backgrounds — original Figma design
            Positioned(
              left: -1,
              top: size.height * 0.21,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.85,
                decoration: ShapeDecoration(
                  color: const Color(0x38164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -1,
              top: size.height * 0.39,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.67,
                decoration: ShapeDecoration(
                  color: const Color(0x7F164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -1,
              top: size.height * 0.60,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.46,
                decoration: ShapeDecoration(
                  color: const Color(0xAA164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF19456B),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: ShapeDecoration(
                          image: const DecorationImage(
                            image: NetworkImage("https://placehold.co/98x98"),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Change Email',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF19456B),
                        size: 28,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Center(
                          child: Text(
                            'New Email',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // New Email field
                        const Text(
                          'New Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: 58,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0x3F26518E),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: TextField(
                            controller: _newEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Continue button
                        GestureDetector(
                          onTap: _isLoading ? null : _continue,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1D3557),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF2D5A85),
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 19,
                                  offset: Offset(0, 4),
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Continue',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
