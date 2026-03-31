import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static final _supabase = Supabase.instance.client;

  String _firstName = '';
  String _position = '';
  bool _isLoading = true;

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
        _firstName = data['first_name'] ?? '';
        _position = data['position'] ?? '';
      });
    } catch (_) {
      // Silently fail — dashboard still loads
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFBF00),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: GoogleFonts.montserrat(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF121212),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF121212),
                                ),
                              )
                            : Text(
                                _firstName.isNotEmpty
                                    ? 'Welcome, $_firstName · $_position'
                                    : 'Welcome, Admin',
                                style: GoogleFonts.inriaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF121212),
                                ),
                              ),
                      ],
                    ),
                  ),
                  // Sign-out button
                  IconButton(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    color: const Color(0xFF121212),
                    tooltip: 'Sign out',
                  ),
                ],
              ),
            ),

            // ── Body (white card) ────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Section title ──────────────────────────
                        Text(
                          'Dashboard',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF121212),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your platform from here.',
                          style: GoogleFonts.inriaSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Placeholder stat cards ─────────────────
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.people_alt_rounded,
                              label: 'Users',
                              value: '—',
                              color: const Color(0xFF16477A),
                            ),
                            const SizedBox(width: 14),
                            _StatCard(
                              icon: Icons.build_rounded,
                              label: 'Mechanics',
                              value: '—',
                              color: const Color(0xFFFFBF00),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.directions_car_rounded,
                              label: 'Jobs',
                              value: '—',
                              color: const Color(0xFF16477A),
                            ),
                            const SizedBox(width: 14),
                            _StatCard(
                              icon: Icons.admin_panel_settings_rounded,
                              label: 'Admins',
                              value: '—',
                              color: const Color(0xFFFFBF00),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ── Empty state ────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.construction_rounded,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'More features coming soon',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'This dashboard is under construction.',
                                style: GoogleFonts.inriaSans(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
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

// ── Reusable stat card widget ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF121212),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inriaSans(
                    fontSize: 13,
                    color: Colors.grey.shade600,
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
