import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../authentication/reset_password_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  static final _supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscurePassword = true;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      final data = await _supabase
          .from('mechanic')
          .select('first_name, last_name, email, phone, address, bio')
          .eq('uid', uid)
          .single();

      _firstNameController.text = data['first_name'] ?? '';
      _lastNameController.text = data['last_name'] ?? '';
      _emailController.text = data['email'] ?? _supabase.auth.currentUser?.email ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _bioController.text = data['bio'] ?? '';
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      // Update mechanic table
      await _supabase.from('mechanic').update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'bio': _bioController.text.trim(),
      }).eq('uid', uid);

      // Update email in auth if changed
      final currentEmail = _supabase.auth.currentUser?.email ?? '';
      if (_emailController.text.trim() != currentEmail) {
        await _supabase.auth.updateUser(
          UserAttributes(email: _emailController.text.trim()),
        );
      }

      if (mounted) {
        _showSnack('Profile updated successfully!');
        Navigator.pop(context, true); // return true so profile reloads
      }
    } catch (e) {
      debugPrint('Failed to save profile: $e');
      if (mounted) _showSnack('Failed to save changes.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.inriaSans(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor:
            isError ? const Color(0xFFD72B2B) : const Color(0xFF2F8A48),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Decorative amber blobs ──
            Positioned(
              right: -70,
              top: 100,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: 160,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Color(0x1FFFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -40,
              bottom: 60,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB703),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFFFFB703), size: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Settings',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Edit your profile & details',
                              style: GoogleFonts.inriaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ──
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFFB703)))
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(16, 20, 16, 100),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                // ── Personal Info ──
                                _SectionLabel(label: 'PERSONAL INFO'),
                                const SizedBox(height: 12),
                                _Card(
                                  child: Column(
                                    children: [
                                      _FieldRow(
                                        label: 'First Name',
                                        icon: Icons.person_outline_rounded,
                                        controller: _firstNameController,
                                        hint: 'Juan',
                                        isFirst: true,
                                        validator: (v) => v == null || v.trim().isEmpty
                                            ? 'Required'
                                            : null,
                                      ),
                                      _CardDivider(),
                                      _FieldRow(
                                        label: 'Last Name',
                                        icon: Icons.person_outline_rounded,
                                        controller: _lastNameController,
                                        hint: 'dela Cruz',
                                        isLast: true,
                                        validator: (v) => v == null || v.trim().isEmpty
                                            ? 'Required'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ── Contact ──
                                _SectionLabel(label: 'CONTACT'),
                                const SizedBox(height: 12),
                                _Card(
                                  child: Column(
                                    children: [
                                      _FieldRow(
                                        label: 'Email',
                                        icon: Icons.email_outlined,
                                        controller: _emailController,
                                        hint: 'juan@email.com',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        isFirst: true,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Required';
                                          }
                                          if (!v.contains('@')) {
                                            return 'Enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      _CardDivider(),
                                      _FieldRow(
                                        label: 'Phone',
                                        icon: Icons.phone_outlined,
                                        controller: _phoneController,
                                        hint: '09xxxxxxxxx',
                                        keyboardType: TextInputType.phone,
                                        isLast: true,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ── Location ──
                                _SectionLabel(label: 'LOCATION'),
                                const SizedBox(height: 12),
                                _Card(
                                  child: _FieldRow(
                                    label: 'Address',
                                    icon: Icons.location_on_outlined,
                                    controller: _addressController,
                                    hint: 'Tisa, Cebu City',
                                    isFirst: true,
                                    isLast: true,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ── Bio ──
                                _SectionLabel(label: 'BIO'),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 14,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 14, 16, 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Short Bio',
                                          style: GoogleFonts.inriaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black38,
                                            letterSpacing: 0.5,
                                          )),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _bioController,
                                        maxLines: 3,
                                        maxLength: 150,
                                        style: GoogleFonts.inriaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Tell clients a little about yourself...',
                                          hintStyle: GoogleFonts.inriaSans(
                                            fontSize: 13,
                                            color: Colors.black26,
                                          ),
                                          border: InputBorder.none,
                                          counterStyle: GoogleFonts.inriaSans(
                                            fontSize: 11,
                                            color: Colors.black26,
                                          ),
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ── Change Password ──
                                _SectionLabel(label: 'CHANGE PASSWORD'),
                                const SizedBox(height: 12),
                                _Card(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F7FA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.black54),
                                    ),
                                    title: Text('Reset Password',
                                        style: GoogleFonts.inriaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        )),
                                    subtitle: Text('Change your account password',
                                        style: GoogleFonts.inriaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black38,
                                        )),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black38),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // ── Save button pinned at bottom ──
            if (!_isLoading)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _isSaving ? null : _saveChanges,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isSaving
                          ? const Color(0xFFFFD55E)
                          : const Color(0xFFFFB703),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFFFB703).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded,
                                    size: 18, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'Save Changes',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.inriaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: const Color(0xFFF0F0F0),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool isFirst;
  final bool isLast;
  final String? Function(String?)? validator;

  const _FieldRow({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.isFirst = false,
    this.isLast = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inriaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black38,
                      letterSpacing: 0.3,
                    )),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: GoogleFonts.inriaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.inriaSans(
                      fontSize: 14,
                      color: Colors.black26,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    errorStyle: GoogleFonts.inriaSans(
                      fontSize: 11,
                      color: Color(0xFFD72B2B),
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

class _PasswordFieldRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final bool isFirst;
  final bool isLast;

  const _PasswordFieldRow({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inriaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black38,
                      letterSpacing: 0.3,
                    )),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  style: GoogleFonts.inriaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.inriaSans(
                      fontSize: 14,
                      color: Colors.black26,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: Colors.black38,
                      ),
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