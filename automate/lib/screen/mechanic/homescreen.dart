import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Logic/jobs/jobs_logic.dart';
import 'homescreen_checkrequest.dart';
import 'jobs.dart';
import 'schedule.dart';
import '../messages/user_message_list.dart';
import 'profile.dart';
import 'active_job.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  StreamSubscription? _dispatchSub;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _listenForEmergencyDispatches();
    _checkActiveJob();
  }

  Future<void> _checkActiveJob() async {
    final activeJob = await JobsLogic().getMechanicActiveJob();
    if (activeJob != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MechanicActiveJobScreen(jobData: activeJob)),
      );
    }
  }

  void _listenForEmergencyDispatches() {
    _dispatchSub = JobsLogic().getMyEmergencyDispatch().listen((dispatches) {
      if (dispatches.isNotEmpty && !_isDialogShowing && mounted) {
        final dispatch = dispatches.first;
        _showEmergencyDialog(dispatch);
      }
    });
  }

  void _showEmergencyDialog(Map<String, dynamic> dispatch) {
    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EmergencyAlertDialog(dispatch: dispatch),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  @override
  void dispose() {
    _dispatchSub?.cancel();
    super.dispose();
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
                        const _ScheduleSection(),
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
  bool _isOnline = false;

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
            .select('first_name, last_name, available_for_emergency')
            .eq('uid', uid)
            .maybeSingle();
        if (res != null && mounted) {
          setState(() {
            _mechanicName = '${res['first_name']}';
            _isOnline = res['available_for_emergency'] ?? false;
          });
        } else if (mounted) {
          setState(() {
            _mechanicName = 'Mechanic';
            _isOnline = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _mechanicName = 'Mechanic';
          _isOnline = false;
        });
      }
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
                    Icon(Icons.circle, size: 10, color: _isOnline ? const Color(0xFF3FDF21) : const Color(0xFFD72B2B)),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? 'You\u2019re online' : 'You\u2019re offline',
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


class _IncomingRequestsSection extends StatefulWidget {
  const _IncomingRequestsSection();

  @override
  State<_IncomingRequestsSection> createState() =>
      _IncomingRequestsSectionState();
}

class _IncomingRequestsSectionState extends State<_IncomingRequestsSection> {
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = JobsLogic().getPendingJobs();
  }

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
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MechanicJobsScreen()),
                ),
                child: Text(
                  'View all',
                  style: GoogleFonts.inriaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF121212),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final jobs = snapshot.data ?? [];
              final top3 = jobs.take(3).toList();

              if (top3.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32, horizontal: 16),
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
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 40, color: Colors.black26),
                      const SizedBox(height: 12),
                      Text(
                        'No incoming requests',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < top3.length; i++) ...[
                    _RequestCard.fromJob(top3[i], context),
                    if (i < top3.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            },
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

  /// Build a card from a live pending-job map from the database.
  static Widget fromJob(Map<String, dynamic> job, BuildContext context) {
    final title = (job['title'] as String?)?.isNotEmpty == true
        ? job['title'] as String
        : (job['issue_description'] as String?)??
              'Service Request';
    final vehicle = job['vehicle'] as String? ?? 'Unknown vehicle';
    final location = job['pickup_location'] as String? ?? '';
    final subtitle = location.isNotEmpty ? '$vehicle • $location' : vehicle;
    final priority = job['priority'] as String? ?? 'Medium';
    final badge = priority == 'High' ? 'Urgent' : 'Normal';

    return _RequestCard(
      title: title,
      subtitle: subtitle,
      badge: badge,
      price: 'Pending ext.',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MechanicCheckRequestScreen(jobData: job, isAccepted: false),
        ),
      ),
    );
  }

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
                    color: badge == 'Urgent'
                        ? const Color(0xFFFFE5E5)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    badge == 'Urgent'
                        ? Icons.warning_amber_rounded
                        : Icons.build_circle_outlined,
                    color: badge == 'Urgent'
                        ? const Color(0xFFD72B2B)
                        : const Color(0xFF121212),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: GoogleFonts.inriaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection();

  String _mapStatus(String? rawStatus) {
    if (rawStatus == null || rawStatus.isEmpty) return 'Unknown';
    switch (rawStatus.toLowerCase()) {
      case 'accepted': return 'Incoming';
      case 'in-progress':
      case 'ongoing': return 'Ongoing';
      case 'completed':
      case 'done': return 'Done';
      default: return rawStatus[0].toUpperCase() + rawStatus.substring(1);
    }
  }

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
                'Schedule',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              InkWell(
                onTap: () {
                   Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MechanicScheduleScreen()));
                },
                child: Text(
                  'View all',
                  style: GoogleFonts.inriaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF121212),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: JobsLogic().getMechanicScheduledJobs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final jobs = snapshot.data ?? [];
              if (jobs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No upcoming schedule',
                      style: GoogleFonts.inriaSans(
                        fontSize: 14,
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }
              
              final topJobs = jobs.take(3).toList();
              
              return Column(
                children: topJobs.map((job) {
                  final title = job['title'] ?? 'Service Request';
                  final rawDate = job['scheduled_date'] ?? job['created_at'];
                  DateTime date = DateTime.now();
                  if (rawDate != null) {
                    date = DateTime.tryParse(rawDate) ?? DateTime.now();
                  }
                  
                  final hourStr = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
                  final timeString = '$hourStr:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
                  
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final jobDate = DateTime(date.year, date.month, date.day);
                  
                  String displayTime = timeString;
                  if (jobDate != today) {
                      displayTime = '${date.month}/${date.day} - $timeString';
                  }

                  final statusRaw = job['status'] as String?;
                  final statusMapped = _mapStatus(statusRaw);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ScheduleCard(
                      title: title,
                      time: displayTime,
                      status: statusMapped,
                      onTap: () {
                         Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MechanicScheduleScreen()));
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.title,
    required this.time,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;

    if (status == 'Ongoing') {
      statusColor = const Color(0xFF0052CC);
      statusBgColor = const Color(0xFFE5F0FF);
    } else if (status == 'Incoming') {
      statusColor = const Color(0xFFD72B2B);
      statusBgColor = const Color(0xFFFFE5E5);
    } else {
      statusColor = const Color(0xFF2F8A48);
      statusBgColor = const Color(0xFFE8F7EA);
    }

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
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.schedule, color: Color(0xFF121212)),
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
                  Text(time,
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
                color: statusBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(status,
                  style: GoogleFonts.inriaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyAlertDialog extends StatefulWidget {
  final Map<String, dynamic> dispatch;

  const _EmergencyAlertDialog({required this.dispatch});

  @override
  State<_EmergencyAlertDialog> createState() => _EmergencyAlertDialogState();
}

class _EmergencyAlertDialogState extends State<_EmergencyAlertDialog> {
  int _countdown = 10;
  Timer? _timer;
  bool _isResponding = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _handleDecline(); // Auto decline when timer runs out
      }
    });
  }

  Future<void> _handleAccept() async {
    if (_isResponding) return;
    setState(() => _isResponding = true);
    _timer?.cancel();

    try {
      final dispatchId = widget.dispatch['id'].toString();
      final job = widget.dispatch['jobs'] as Map<String, dynamic>?;
      final jobId = job?['id']?.toString();

      if (jobId != null) {
        await JobsLogic().respondToDispatch(dispatchId, jobId, true);
        if (mounted) {
          Navigator.pop(context); // Close dialog
          // Go to check request screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MechanicCheckRequestScreen(jobData: job, isAccepted: true),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error accepting dispatch: $e');
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _handleDecline() async {
    if (_isResponding) return;
    setState(() => _isResponding = true);
    _timer?.cancel();

    try {
      final dispatchId = widget.dispatch['id'].toString();
      final job = widget.dispatch['jobs'] as Map<String, dynamic>?;
      final jobId = job?['id']?.toString();

      if (jobId != null) {
        await JobsLogic().respondToDispatch(dispatchId, jobId, false);
      }
    } catch (e) {
      debugPrint('Error declining dispatch: $e');
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.dispatch['jobs'] as Map<String, dynamic>? ?? {};
    final title = job['title'] ?? job['issue_description'] ?? 'Emergency Service';
    final vehicle = job['vehicle'] ?? 'Unknown Vehicle';
    final distance = 'Distance unavailable';
    final userName = job['user_name'] ?? 'A Client';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Emergency Alert',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Auto Paired',
              style: GoogleFonts.inriaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3FDF21),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$userName needs your help immediately!',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inriaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car_outlined, size: 18, color: Colors.black87),
                const SizedBox(width: 4),
                Text(
                  vehicle,
                  style: GoogleFonts.inriaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: GoogleFonts.inriaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isResponding ? null : _handleAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: _isResponding
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Continue... ($_countdown)',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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