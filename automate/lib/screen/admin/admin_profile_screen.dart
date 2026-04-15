import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_update_password_screen.dart';

class AdminProfileContent extends StatefulWidget {
  const AdminProfileContent({super.key});

  @override
  State<AdminProfileContent> createState() => _AdminProfileContentState();
}

class _AdminProfileContentState extends State<AdminProfileContent> {
  static final _supabase = Supabase.instance.client;

  bool _verificationAlerts = true;
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
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goToUpdatePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminUpdatePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF164D83),
                    Color(0xFF1A5A96),
                    Color(0xFFD6E4F0),
                    Color(0xFFF0F5FA),
                  ],
                  stops: [0.0, 0.25, 0.65, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Admin Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        // Profile card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar with edit button
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 56,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF164D83),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (_isLoading)
                                const CircularProgressIndicator(
                                  color: Color(0xFF164D83),
                                )
                              else ...[
                                Text(
                                  _adminName.isNotEmpty
                                      ? _adminName
                                      : 'Angelic Alerta',
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _adminRole.isNotEmpty
                                      ? _adminRole
                                      : 'System Administrator',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Profile edit button
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF164D83),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Profile edit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Update Password card
                        GestureDetector(
                          onTap: _goToUpdatePassword,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF164D83,
                                    ).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF164D83),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Update Password',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 15,
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
                        ),

                        const SizedBox(height: 16),

                        // Notifications card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Verification Alerts
                              Row(
                                children: [
                                  const Icon(
                                    Icons.notifications_rounded,
                                    color: Color(0xFF164D83),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Notifications',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  _CustomSwitch(
                                    value: _verificationAlerts,
                                    onChanged: (val) => setState(
                                      () => _verificationAlerts = val,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Transaction Updates
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF164D83),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Notifications',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  _CustomSwitch(
                                    value: _transactionUpdates,
                                    onChanged: (val) => setState(
                                      () => _transactionUpdates = val,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Log out button
                        GestureDetector(
                          onTap: _signOut,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Log out',
                              style: TextStyle(
                                color: Color(0xFFDB2020),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}

// ── Custom switch with clear off state ───────────────────────────────────────

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF164D83) : const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? 24 : 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
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
          ],
        ),
      ),
    );
  }
}
