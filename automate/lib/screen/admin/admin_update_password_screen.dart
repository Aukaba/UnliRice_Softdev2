import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUpdatePasswordScreen extends StatefulWidget {
  const AdminUpdatePasswordScreen({super.key});

  @override
  State<AdminUpdatePasswordScreen> createState() =>
      _AdminUpdatePasswordScreenState();
}

class _AdminUpdatePasswordScreenState extends State<AdminUpdatePasswordScreen> {
  static final _supabase = Supabase.instance.client;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showReEnter = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _newPasswordController.text.trim();
    final reEnter = _reEnterPasswordController.text.trim();

    if (newPassword.isEmpty || reEnter.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (newPassword != reEnter) {
      _showError('New passwords do not match.');
      return;
    }

    if (newPassword.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to update password. Please try again.');
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

  void _showSuccessDialog() {
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
                'Reset Password Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),

              const SizedBox(height: 24),

              // Go Back button
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx); // close dialog
                  Navigator.pop(context); // go back to profile
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
            // Blue layered backgrounds rising from bottom — original Figma design
            Positioned(
              left: -1,
              top: size.height * 0.67,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.38,
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
              top: size.height * 0.76,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.30,
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
              top: size.height * 0.83,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.22,
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
                      // Back button
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
                        'Change Password',
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
                            'Forget Password',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Current Password
                        const Text(
                          'Current Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _PasswordField(
                          controller: _currentPasswordController,
                          show: _showCurrent,
                          onToggle: () =>
                              setState(() => _showCurrent = !_showCurrent),
                        ),

                        const SizedBox(height: 24),

                        // New Password
                        const Text(
                          'New Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _PasswordField(
                          controller: _newPasswordController,
                          show: _showNew,
                          onToggle: () => setState(() => _showNew = !_showNew),
                        ),

                        const SizedBox(height: 24),

                        // Re-Enter New Password
                        const Text(
                          'Re-Enter New Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _PasswordField(
                          controller: _reEnterPasswordController,
                          show: _showReEnter,
                          onToggle: () =>
                              setState(() => _showReEnter = !_showReEnter),
                        ),

                        const SizedBox(height: 40),

                        // Enter button
                        GestureDetector(
                          onTap: _isLoading ? null : _submit,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1D3557),
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
                                    'Enter',
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

// ── Password field ────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.show,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x3F26518E)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: !show,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF26518E).withOpacity(0.5),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
