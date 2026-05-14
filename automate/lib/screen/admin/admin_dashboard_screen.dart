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
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: _currentIndex == 0,
                  onTap: () => _switchTab(0),
                ),
                _NavItem(
                  icon: Icons.build,
                  label: 'Verification',
                  isActive: _currentIndex == 1,
                  onTap: () => _switchTab(1),
                ),
                _NavItem(
                  icon: Icons.bar_chart,
                  label: 'Analytics',
                  isActive: _currentIndex == 2,
                  onTap: () => _switchTab(2),
                ),
                _NavItem(
                  icon: Icons.person,
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
              ? const Color(0xFF19456B).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF19456B) : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF19456B) : Colors.grey.shade400,
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
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _adminName = 'Admin';
  int _pendingMechanics = 0;
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

      // Get admin name
      if (uid != null) {
        try {
          final adminData = await _supabase
              .from('admin')
              .select('first_name')
              .eq('uid', uid)
              .maybeSingle();
          if (adminData != null) {
            _adminName = adminData['first_name'] ?? 'Admin';
          }
        } catch (e) {
          debugPrint("Error fetching admin: $e");
        }
      }

      // Get pending verifications
      try {
        final pending = await _supabase
            .from('mechanic_verification')
            .select('id')
            .eq('status', 'pending');
        _pendingMechanics = (pending as List).length;
      } catch (e) {
        debugPrint("Error fetching pending: $e");
      }

      // Get registered users/drivers
      try {
        final drivers = await _supabase
            .from('user')
            .select('uid');
        _registeredDrivers = (drivers as List).length;
      } catch (e) {
        debugPrint("Error fetching drivers: $e");
      }

      // Get verified mechanics
      try {
        final verified = await _supabase
            .from('mechanic')
            .select('uid')
            .eq('verified', true);
        _verifiedMechanics = (verified as List).length;
      } catch (e) {
        debugPrint("Error fetching verified mechanics: $e");
      }

    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Sidebar layers
            Positioned(
              left: -28, top: 87,
              child: Container(
                width: 258, height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x4C164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),
            Positioned(
              left: -18, top: 87,
              child: Container(
                width: 176, height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x7F164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),
            Positioned(
              left: -18, top: 87,
              child: Container(
                width: 103, height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0xFF164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
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
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF164D83),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, $_adminName',
                            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
                          const Text('Management System',
                            style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF19456B), size: 28),
                        onPressed: _loadData,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stat cards
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF19456B)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(36, 0, 36, 24),
                          child: Column(
                            children: [
                              _StatCard(
                                title: 'Pending Mechanics',
                                value: '$_pendingMechanics',
                                subtitle: 'Waiting for approval',
                                icon: Icons.pending_actions,
                                color: const Color(0xFFFFB703),
                                onTap: () => widget.onSwitchTab(1),
                              ),
                              const SizedBox(height: 16),
                              _StatCard(
                                title: 'Registered Drivers',
                                value: '$_registeredDrivers',
                                subtitle: 'Total users',
                                icon: Icons.people,
                                color: const Color(0xFF009227),
                                onTap: null,
                              ),
                              const SizedBox(height: 16),
                              _StatCard(
                                title: 'Verified Mechanics',
                                value: '$_verifiedMechanics',
                                subtitle: 'Mechanics active',
                                icon: Icons.verified,
                                color: const Color(0xFF0052CC),
                                onTap: () => widget.onSwitchTab(1),
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

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: const TextStyle(color: Color(0xFF666666), fontSize: 13, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value,
                    style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 32, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: const TextStyle(color: Color(0xFF999999), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}