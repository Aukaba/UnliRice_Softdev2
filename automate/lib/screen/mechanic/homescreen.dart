import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homescreen_checkrequest.dart';
import 'jobs.dart';
import 'schedule.dart';
import '../messages/user_message_list.dart';
import 'profile.dart';

class MechanicHomeScreen extends StatelessWidget {
  const MechanicHomeScreen({super.key});

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
              top: 120,
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
            // ── Scrollable content ──
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const _HeaderSection(),
                        const SizedBox(height: 16),
                        const _StatsSection(),
                        const SizedBox(height: 24),
                        const _IncomingRequestsSection(),
                        const SizedBox(height: 24),
                        const _PerformanceSection(),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 0,
        onItemTapped: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MechanicJobsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MechanicScheduleScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserMessageListScreen()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MechanicProfileScreen()),
            );
          }
        },
      ),
    );
  }
}

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  String _mechanicName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchName();
  }

  Future<void> _fetchName() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        final res = await Supabase.instance.client
            .from('mechanic')
            .select('first_name, last_name')
            .eq('uid', uid)
            .maybeSingle();
        if (res != null && mounted) {
          setState(() {
            _mechanicName = '${res['first_name']}';
          });
        } else if (mounted) {
          setState(() {
            _mechanicName = 'Mechanic';
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _mechanicName = 'Mechanic');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB703),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning,',
                    style: GoogleFonts.inriaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _mechanicName,
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
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
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Color(0xFF3FDF21)),
                    const SizedBox(width: 8),
                    Text(
                      'You\u2019re online',
                      style: GoogleFonts.inriaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_pin, size: 16, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(
                      'Tisa, Cebu City',
                      style: GoogleFonts.inriaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _StatCard(value: '₱4,500', label: 'TODAY', highlighted: true)),
          SizedBox(width: 12),
          Expanded(child: _StatCard(value: '₱23.8K', label: 'THIS WEEK')),
          SizedBox(width: 12),
          Expanded(child: _StatCard(value: '342', label: 'TOTAL JOBS')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool highlighted;

  const _StatCard({required this.value, required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inriaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingRequestsSection extends StatelessWidget {
  const _IncomingRequestsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incoming Requests',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                'View all',
                style: GoogleFonts.inriaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF121212),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RequestCard(
            title: 'Engine won\u2019t start',
            subtitle: 'Ron Seldizo \u2022 Toyota Vios',
            badge: 'Urgent',
            price: '₱1,500 - ₱2,000',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MechanicCheckRequestScreen())),
          ),
          const SizedBox(height: 12),
          _RequestCard(
            title: 'Flat tire on CBL',
            subtitle: 'Aaron Barnaija \u2022 Yamaha N-115',
            badge: 'Normal',
            price: '₱1,000 - ₱1,300',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MechanicCheckRequestScreen())),
          ),
          const SizedBox(height: 12),
          _RequestCard(
            title: 'AC not cooling',
            subtitle: 'Mambaling motorcab \u2022 Toyota Vios',
            badge: 'Normal',
            price: '₱1,500 - ₱2,000',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MechanicCheckRequestScreen())),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final String price;
  final VoidCallback onTap;

  const _RequestCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.build_circle_outlined, color: Color(0xFF121212)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: GoogleFonts.inriaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badge == 'Urgent'
                        ? const Color(0xFFFFE5E5)
                        : const Color(0xFFE8F7EA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(badge,
                      style: GoogleFonts.inriaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badge == 'Urgent'
                              ? const Color(0xFFD72B2B)
                              : const Color(0xFF2F8A48))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF121212))),
                Text('View details',
                    style: GoogleFonts.inriaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF121212))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your Performance',
                style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PerformanceMetric(label: 'Rating', value: '4.9'),
                _PerformanceMetric(label: 'Accuracy', value: '94%'),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PerformanceMetric(label: 'Avg. Response', value: '2.5 MIN'),
                _PerformanceMetric(label: 'Completion', value: '98%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  final String label;
  final String value;

  const _PerformanceMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.montserrat(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.inriaSans(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }
}

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
          Text(label,
              style: GoogleFonts.inriaSans(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}