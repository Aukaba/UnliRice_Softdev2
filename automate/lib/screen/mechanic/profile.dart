import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';
import 'jobs.dart';
import 'schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../messages/user_message_list.dart';
import '../authentication/login_screen.dart'; // Just in case for logout

class MechanicProfileScreen extends StatefulWidget {
  const MechanicProfileScreen({super.key});

  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  static final _supabase = Supabase.instance.client;
  bool _availableForEmergency = true;
  bool _isLoading = true;
  String _mechanicName = '';

  @override
  void initState() {
    super.initState();
    _loadMechanicInfo();
  }

  Future<void> _loadMechanicInfo() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      final data = await _supabase
          .from('mechanic')
          .select('first_name, last_name')
          .eq('uid', uid)
          .single();

      setState(() {
        final firstName = data['first_name'] ?? '';
        final lastName = data['last_name'] ?? '';
        _mechanicName = '$firstName $lastName'.trim();
      });
    } catch (e, stackTrace) {
      debugPrint('Failed to load mechanic info: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Signout warning: $e');
    } finally {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
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
              right: -60,
              top: 180,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: 300,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  color: Color(0x1FFFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 100,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ── Main content ──
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header — scrolls with content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB703),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person_outline_rounded,
                              color: Color(0xFFFFB703), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Profile',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.notifications_none, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Profile card ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar + name
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFFE0D6C8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color(0xFF8B7355),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _isLoading ? 'Loading...' : (_mechanicName.isEmpty ? 'Mechanic Profile' : _mechanicName),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded,
                                          size: 18, color: Color(0xFF1DA1F2)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mekaniko ng NewJeans bai',
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
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ProfileStat(
                              value: '4.9',
                              label: 'REVIEWS',
                              sub: '128',
                              isRating: true,
                            ),
                            Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                            _ProfileStat(value: '342', label: 'JOBS DONE'),
                            Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                            _ProfileStat(value: 'Since', label: '2022', isSince: true),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Available for Emergency toggle ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _availableForEmergency
                                ? const Color(0xFF3FDF21)
                                : Colors.black26,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Available for Emergency',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Switch(
                          value: _availableForEmergency,
                          onChanged: (v) =>
                              setState(() => _availableForEmergency = v),
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF3FDF21),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.black12,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Specializations ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                size: 20, color: Colors.black87),
                            const SizedBox(width: 8),
                            Text(
                              'Specializations',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Toyota', 'Honda', 'Mitsubibi', 'Engine', 'Transmission']
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F7FA),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFE8E8E8)),
                                    ),
                                    child: Text(
                                      s,
                                      style: GoogleFonts.inriaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Business section ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Text(
                      'BUSINESS',
                      style: GoogleFonts.inriaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.black38,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _MenuRow(
                          icon: Icons.credit_card_outlined,
                          title: 'Earnings & Payouts',
                          subtitle: 'View payment history',
                          isFirst: true,
                        ),
                        const _Divider(),
                        _MenuRow(
                          icon: Icons.description_outlined,
                          title: 'Job History',
                          subtitle: 'Past completed jobs',
                        ),
                        const _Divider(),
                        _MenuRow(
                          icon: Icons.schedule_outlined,
                          title: 'Working Hours',
                          subtitle: 'Set your weekly schedule',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Settings section ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Text(
                      'SETTINGS',
                      style: GoogleFonts.inriaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.black38,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _MenuRow(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage alerts & sounds',
                          isFirst: true,
                        ),
                        const _Divider(),
                        _MenuRow(
                          icon: Icons.location_on_outlined,
                          title: 'Service Area',
                          subtitle: 'Set your coverage radius',
                        ),
                        const _Divider(),
                        _MenuRow(
                          icon: Icons.settings_outlined,
                          title: 'Account Settings',
                          subtitle: 'Edit profile & details',
                        ),
                        const _Divider(),
                        _MenuRow(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'FAQs and contact',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Log Out ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _signOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded,
                                size: 20, color: Color(0xFFD72B2B)),
                            const SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD72B2B),
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
          ],
        ),
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 4,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicHomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicJobsScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicScheduleScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const UserMessageListScreen()));
          }
        },
      ),
    );
  }
}

// ─── Profile stat widget ──────────────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final String? sub;
  final bool isRating;
  final bool isSince;

  const _ProfileStat({
    required this.value,
    required this.label,
    this.sub,
    this.isRating = false,
    this.isSince = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isSince) ...[
          Text(
            value,
            style: GoogleFonts.inriaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ] else if (isRating) ...[
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFB703)),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${sub ?? ''} $label',
            style: GoogleFonts.inriaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black38,
            ),
          ),
        ] else ...[
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inriaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black38,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Menu row ────────────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(28) : Radius.zero,
            bottom: isLast ? const Radius.circular(28) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: Colors.black87),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inriaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 72),
      height: 1,
      color: const Color(0xFFF0F0F0),
    );
  }
}

// ─── Bottom nav ──────────────────────────────────────────────────────────────

class _MechanicBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const _MechanicBottomNavigationBar(
      {required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined, label: 'Home', active: currentIndex == 0, onTap: () => onItemTapped(0)),
            _NavItem(icon: Icons.inventory_2_outlined, label: 'Jobs', active: currentIndex == 1, onTap: () => onItemTapped(1)),
            _NavItem(icon: Icons.calendar_month_outlined, label: 'Schedule', active: currentIndex == 2, onTap: () => onItemTapped(2)),
            _NavItem(icon: Icons.chat_bubble_outline, label: 'Chat', active: currentIndex == 3, onTap: () => onItemTapped(3)),
            _NavItem(icon: Icons.person_outline, label: 'Profile', active: currentIndex == 4, onTap: () => onItemTapped(4)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon, required this.label, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFFFB703) : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? const Color(0x33FFB703) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inriaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}