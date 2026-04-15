import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_mechanic_verification_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _DashboardTab(onSwitchTab: _switchTab),
      AdminMechanicVerificationContent(onSwitchTab: _switchTab),
      const AdminAnalyticsContent(),
      const AdminProfileContent(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: _currentIndex == 0,
                  onTap: () => _switchTab(0),
                ),
                _NavItem(
                  icon: Icons.verified_user_outlined,
                  label: 'Verification',
                  isActive: _currentIndex == 1,
                  onTap: () => _switchTab(1),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  isActive: _currentIndex == 2,
                  onTap: () => _switchTab(2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isActive: _currentIndex == 3,
                  onTap: () => _switchTab(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom nav item ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF164D83).withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF164D83) : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF164D83)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const _DashboardTab({required this.onSwitchTab});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  static final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _adminName = 'Admin';
  int _pendingMechanics = 0;
  int _activeRequests = 0;
  int _registeredDrivers = 0;
  int _verifiedMechanics = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid != null) {
        final adminData = await _supabase
            .from('admin')
            .select('first_name')
            .eq('uid', uid)
            .single();
        _adminName = adminData['first_name'] ?? 'Admin';
      }
      final pending = await _supabase
          .from('mechanics')
          .select('id')
          .eq('status', 'pending');
      final active = await _supabase
          .from('requests')
          .select('id')
          .eq('status', 'active');
      final drivers = await _supabase.from('users').select('id');
      final verified = await _supabase
          .from('mechanics')
          .select('id')
          .eq('status', 'approved');

      if (mounted) {
        setState(() {
          _pendingMechanics = (pending as List).length;
          _activeRequests = (active as List).length;
          _registeredDrivers = (drivers as List).length;
          _verifiedMechanics = (verified as List).length;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background — deep navy left fading to light right
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
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      // Profile image / logo
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _adminName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Management System',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Notification button
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

                // ── Stat cards ────────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: Column(
                            children: [
                              _StatCard(
                                title: 'Pending Mechanics',
                                value: '$_pendingMechanics',
                                subtitle: 'Waiting for approval',
                              ),
                              const SizedBox(height: 14),
                              _StatCard(
                                title: 'Active Requests',
                                value: '$_activeRequests',
                                subtitle: 'Drivers requesting help',
                              ),
                              const SizedBox(height: 14),
                              _StatCard(
                                title: 'Registered Drivers',
                                value: '$_registeredDrivers',
                                subtitle: 'users',
                              ),
                              const SizedBox(height: 14),
                              _StatCard(
                                title: 'Verified Mechanics',
                                value: '$_verifiedMechanics',
                                subtitle: 'mechanics active',
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

// ── Stat card — clean white card matching image ───────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF164D83),
              fontSize: 36,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
