import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_update_password_screen.dart';
import 'admin_update_email_screen.dart';
import '../authentication/login_screen.dart'; // <-- added import

class AdminProfileContent extends StatefulWidget {
  const AdminProfileContent({super.key});

  @override
  State<AdminProfileContent> createState() => _AdminProfileContentState();
}

class _AdminProfileContentState extends State<AdminProfileContent> {
  static final _supabase = Supabase.instance.client;

  bool _verificationAlerts = false;
  bool _transactionUpdates = false;
  bool _isLoading = true;

  String _adminName = '';
  String _adminEmail = '';
  String _adminRole = '';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      final data = await _supabase
          .from('admin')
          .select('first_name, position')
          .eq('uid', uid)
          .single();

      setState(() {
        _adminName = data['first_name'] ?? '';
        _adminRole = data['position'] ?? 'System Administrator';
        _adminEmail = _supabase.auth.currentUser?.email ?? '';
      });
    } catch (_) {
      // Silently fail
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    // Updated to match first version: push LoginScreen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _goToUpdatePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminUpdatePasswordScreen(),
      ),
    );
  }

  void _goToUpdateEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminUpdateEmailScreen()),
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
              top: size.height * 0.15,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.90,
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
                height: size.height * 0.66,
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
              top: size.height * 0.67,
              child: Container(
                width: size.width + 2,
                height: size.height * 0.38,
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
                      Container(
                        width: 70,
                        height: 70,
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
                        'Admin Profile',
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

                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFE5E5E5),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar with edit button
                              GestureDetector(
                                onTap: () {
                                  // Pick profile picture — coming soon
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 75,
                                      height: 75,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF1A1A1A),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 48,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -4,
                                      right: -8,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFBF00),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (_isLoading)
                                const CircularProgressIndicator(
                                  color: Color(0xFF19456B),
                                )
                              else ...[
                                _InfoRow(
                                  label: 'Admin:',
                                  value: _adminName.isNotEmpty
                                      ? _adminName
                                      : 'Angelic Alerta',
                                ),
                                const SizedBox(height: 6),
                                _InfoRow(
                                  label: 'Email:',
                                  value: _adminEmail.isNotEmpty
                                      ? _adminEmail
                                      : 'AdminAlerta@gmail.com',
                                ),
                                const SizedBox(height: 6),
                                _InfoRow(
                                  label: 'Role:',
                                  value: _adminRole.isNotEmpty
                                      ? _adminRole
                                      : 'System Administrator',
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Update Password — navigates to AdminUpdatePasswordScreen
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Update Password',
                          onTap: _goToUpdatePassword,
                        ),
                        const SizedBox(height: 10),

                        // Update Email — navigates to AdminUpdateEmailScreen
                        _SettingsTile(
                          icon: Icons.email_outlined,
                          label: 'Update Email',
                          onTap: _goToUpdateEmail,
                        ),

                        const SizedBox(height: 20),

                        // Notifications heading
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Verification Alerts toggle
                        _ToggleTile(
                          icon: Icons.verified_outlined,
                          label: 'Verification Alerts',
                          value: _verificationAlerts,
                          onChanged: (val) =>
                              setState(() => _verificationAlerts = val),
                        ),
                        const SizedBox(height: 10),

                        // Transaction Updates toggle
                        _ToggleTile(
                          icon: Icons.receipt_long_outlined,
                          label: 'Transaction Updates',
                          value: _transactionUpdates,
                          onChanged: (val) =>
                              setState(() => _transactionUpdates = val),
                        ),

                        const SizedBox(height: 20),

                        // Log out
                        Container(
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            color: const Color(0xAA164D83),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: _signOut,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFE5E5E5),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Color(0xFFDB2020),
                                    size: 26,
                                  ),
                                  SizedBox(width: 14),
                                  Text(
                                    'Log out',
                                    style: TextStyle(
                                      color: Color(0xFFDB2020),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFB703), size: 26),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFAAAAAA),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle tile ────────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFB703), size: 26),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF164D83),
            activeTrackColor: const Color(0xFF164D83).withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
