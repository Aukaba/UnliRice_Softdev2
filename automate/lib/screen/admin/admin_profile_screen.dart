import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_update_password_screen.dart';
import '../authentication/login_screen.dart';

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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _goToUpdatePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AdminUpdatePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF164D83),
              Color(0xFF1A6BAF),
              Colors.white,
            ],
            stops: [0.0, 0.35, 0.85],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/AutoMate_logo.png',
                      width: 44,
                      height: 44,
                      errorBuilder: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings,
                            color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Admin Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFE5E5E5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {},
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
                                    child: const Icon(Icons.person,
                                        size: 48, color: Color(0xFF1A1A1A)),
                                  ),
                                  Positioned(
                                    bottom: -4,
                                    right: -8,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFBF00),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.edit,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isLoading)
                              const CircularProgressIndicator(
                                  color: Color(0xFF164D83))
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

                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Update Password',
                        onTap: _goToUpdatePassword,
                      ),
                      
                      const SizedBox(height: 20),

                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _ToggleTile(
                        icon: Icons.verified_outlined,
                        label: 'Verification Alerts',
                        value: _verificationAlerts,
                        onChanged: (val) =>
                            setState(() => _verificationAlerts = val),
                      ),
                      const SizedBox(height: 10),
                      _ToggleTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'Transaction Updates',
                        value: _transactionUpdates,
                        onChanged: (val) =>
                            setState(() => _transactionUpdates = val),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _signOut,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0xFFE5E5E5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.logout_rounded,
                                  color: Color(0xFFDB2020), size: 26),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          child: Text(label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              )),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon, required this.label, required this.onTap});

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
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFB703), size: 26),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                )),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFAAAAAA), size: 22),
          ],
        ),
      ),
    );
  }
}

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
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFB703), size: 26),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              )),
          const Spacer(),
          // ENHANCED ACCESSIBILITY TOGGLE
          Semantics(
            container: true,
            toggled: true,
            checked: value,
            label: label,
            onTap: () => onChanged(!value),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(!value),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 48.0,
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 28,
                    decoration: BoxDecoration(
                      color: value
                          ? const Color(0xFF164D83)
                          : const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: value
                            ? const Color(0xFF164D83)
                            : const Color(0xFFAAAAAA),
                        width: 1.5,
                      ),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment:
                          value ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}