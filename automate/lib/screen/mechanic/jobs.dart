import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';
import 'schedule.dart';
import 'chat.dart';

class MechanicJobsScreen extends StatefulWidget {
  const MechanicJobsScreen({super.key});

  @override
  State<MechanicJobsScreen> createState() => _MechanicJobsScreenState();
}

class _MechanicJobsScreenState extends State<MechanicJobsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Urgent', 'Medium', 'Low'];

  final List<_JobData> _jobs = const [
    _JobData(
      title: 'Engine won\'t start',
      name: 'Rex Seadiño Jr.',
      vehicle: 'Toyota Vios',
      description:
          '"Car gonna but won\'t turn over. Battery seems fine, lights work. Helpdesk."',
      km: '0.47 km',
      minutesAgo: '2 min ago',
      price: '₱1,000 - ₱3,000',
      priority: 'High',
    ),
    _JobData(
      title: 'Engine won\'t start',
      name: 'Rex Seadiño Jr.',
      vehicle: 'Toyota Vios',
      description:
          '"Car gonna but won\'t turn over. Battery seems fine, lights work. Helpdesk."',
      km: '0.47 km',
      minutesAgo: '2 min ago',
      price: '₱1,000 - ₱3,000',
      priority: 'High',
    ),
    _JobData(
      title: 'Engine won\'t start',
      name: 'Rex Seadiño Jr.',
      vehicle: 'Toyota Vios',
      description:
          '"Car gonna but won\'t turn over. Battery seems fine, lights work. Helpdesk."',
      km: '0.47 km',
      minutesAgo: '2 min ago',
      price: '₱1,000 - ₱3,000',
      priority: 'High',
    ),
    _JobData(
      title: 'Engine won\'t start',
      name: 'Rex Seadiño Jr.',
      vehicle: 'Toyota Vios',
      description:
          '"Car gonna but won\'t turn over. Battery seems fine, lights work. Helpdesk."',
      km: '0.47 km',
      minutesAgo: '2 min ago',
      price: '₱1,000 - ₱3,000',
      priority: 'Medium',
    ),
  ];

  List<_JobData> get _filteredJobs {
    if (_selectedFilter == 'All') return _jobs;
    return _jobs.where((j) => j.priority == _selectedFilter).toList();
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
              left: -70,
              top: 160,
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
              right: -60,
              bottom: 200,
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
              left: -30,
              bottom: 60,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // ── Content ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB703),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.work_outline_rounded,
                            color: Color(0xFFFFB703), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job requests',
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '${_filteredJobs.length} pending requests',
                              style: GoogleFonts.inriaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.notifications_none,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Filter chips
                  Row(
                    children: _filters.map((f) {
                      final active = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.black
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              f,
                              style: GoogleFonts.inriaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? const Color(0xFFFFB703)
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Job cards list
            Expanded(
              child: _filteredJobs.isEmpty
                  ? Center(
                      child: Text(
                        'No $_selectedFilter requests',
                        style: GoogleFonts.inriaSans(
                          fontSize: 15,
                          color: Colors.black38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      itemCount: _filteredJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _JobCard(job: _filteredJobs[index]),
                    ),
            ),
          ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 1,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MechanicHomeScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MechanicScheduleScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MechanicChatScreen()),
            );
          }
        },
      ),
    );
  }
}

class _JobData {
  final String title;
  final String name;
  final String vehicle;
  final String description;
  final String km;
  final String minutesAgo;
  final String price;
  final String priority;

  const _JobData({
    required this.title,
    required this.name,
    required this.vehicle,
    required this.description,
    required this.km,
    required this.minutesAgo,
    required this.price,
    required this.priority,
  });
}

class _JobCard extends StatelessWidget {
  final _JobData job;
  const _JobCard({required this.job});

  Color get _badgeBg => job.priority == 'High'
      ? const Color(0xFFFFE5E5)
      : job.priority == 'Medium'
          ? const Color(0xFFFFF3CD)
          : const Color(0xFFE8F7EA);

  Color get _badgeText => job.priority == 'High'
      ? const Color(0xFFD72B2B)
      : job.priority == 'Medium'
          ? const Color(0xFFB07D00)
          : const Color(0xFF2F8A48);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.build_rounded,
                    color: Color(0xFF121212), size: 22),
              ),
              const SizedBox(width: 12),
              // Title + name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${job.name} • ${job.vehicle}',
                      style: GoogleFonts.inriaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Priority badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.priority,
                  style: GoogleFonts.inriaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inriaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          // Bottom row
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                job.km,
                style: GoogleFonts.inriaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                job.minutesAgo,
                style: GoogleFonts.inriaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              ),
              const Spacer(),
              Text(
                job.price,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF121212),
                ),
              ),
            ],
          ),
        ],
      ),
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