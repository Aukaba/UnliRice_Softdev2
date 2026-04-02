import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_mechanic_verification_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _AdminDashboardTab(onSwitchTab: _switchTab),
      AdminMechanicVerificationContent(onSwitchTab: _switchTab),
      const _PlaceholderTab(label: 'Drivers'),
      const _PlaceholderTab(label: 'Settings'),
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
                  icon: Icons.people,
                  label: 'Drivers',
                  isActive: _currentIndex == 2,
                  onTap: () => _switchTab(2),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
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
                color: isActive
                    ? const Color(0xFF19456B)
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

class _AdminDashboardTab extends StatefulWidget {
  final void Function(int) onSwitchTab;

  const _AdminDashboardTab({required this.onSwitchTab});

  @override
  State<_AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<_AdminDashboardTab> {
  static final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _adminName = 'Admin';

  // Counts loaded from Supabase — update table names to match yours
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

      // Load admin name
      if (uid != null) {
        final adminData = await _supabase
            .from('admin')
            .select('first_name')
            .eq('uid', uid)
            .single();
        _adminName = adminData['first_name'] ?? 'Admin';
      }

      // Load counts — update table/column names to match your Supabase
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
      // Silently fail — shows last known values or zeros
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
              left: -28,
              top: 87,
              child: Container(
                width: 258,
                height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x4C164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -18,
              top: 87,
              child: Container(
                width: 176,
                height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x7F164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -18,
              top: 87,
              child: Container(
                width: 103,
                height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0xFF164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _adminName,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Management System',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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

                const SizedBox(height: 16),

                // Stat cards
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF19456B),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(36, 0, 36, 24),
                          child: Column(
                            children: [
                              _StatCard(
                                title: 'Pending Mechanics:',
                                value: '$_pendingMechanics',
                                subtitle: 'Waiting for approval',
                                percentage: '',
                                isPositive: true,
                              ),
                              const SizedBox(height: 16),
                              _StatCard(
                                title: 'Active Requests:',
                                value: '$_activeRequests',
                                subtitle: 'drivers requesting help',
                                percentage: '',
                                isPositive: true,
                              ),
                              const SizedBox(height: 16),
                              _StatCard(
                                title: 'Registered Drivers:',
                                value: '$_registeredDrivers',
                                subtitle: 'users',
                                percentage: '',
                                isPositive: true,
                              ),
                              const SizedBox(height: 16),
                              _StatCard(
                                title: 'Verified Mechanics:',
                                value: '$_verifiedMechanics',
                                subtitle: 'mechanics active',
                                percentage: '',
                                isPositive: true,
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
  final String percentage;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.percentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
      child: Stack(
        children: [
          SizedBox(
            width: 260,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: Text(
              percentage,
              style: TextStyle(
                color: isPositive
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 78),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder tab ──────────────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final String label;

  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              '$label coming soon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This screen is under construction.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
