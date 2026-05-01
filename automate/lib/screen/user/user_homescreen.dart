import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_dashboard.dart';
import 'user_activity.dart';
import '../../Logic/jobs/jobs_logic.dart';

class UserHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllActivity;
  const UserHomeScreen({
    super.key,
    this.onViewAllActivity,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _firstName = '';
  late final Stream<List<Map<String, dynamic>>> _activityStream;

  @override
  void initState() {
    super.initState();
    _activityStream = JobsLogic().getUserActivityJobs();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    // Try 'user' table (the table that actually exists)
    try {
      final res = await supabase
          .from('user')
          .select('first_name')
          .eq('uid', uid)
          .maybeSingle();
      if (res != null && mounted) {
        setState(() => _firstName = res['first_name'] ?? '');
        return;
      }
    } catch (_) {}

    // Fallback: mechanic table
    try {
      final res = await supabase
          .from('mechanic')
          .select('first_name')
          .eq('uid', uid)
          .maybeSingle();
      if (res != null && mounted) {
        setState(() => _firstName = res['first_name'] ?? '');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
            _buildHeader(),
            
            // Main Body Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _activityStream,
                builder: (context, snapshot) {
                  final jobs = snapshot.data ?? [];

                  // Sort by most recent
                  final sortedJobs = List<Map<String, dynamic>>.from(jobs)
                    ..sort((a, b) {
                      final aDate = DateTime.tryParse(a['created_at'] ?? '') ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final bDate = DateTime.tryParse(b['created_at'] ?? '') ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      return bDate.compareTo(aDate);
                    });

                  final recentJobs = sortedJobs.take(3).toList();
                  final totalRequests = jobs.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary Action Button
                      _buildAskForHelpButton(),
                      
                      const SizedBox(height: 32),

                      // Recent Activity Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 24, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(
                                'Recent Activity',
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.onViewAllActivity != null) {
                                widget.onViewAllActivity!();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UserActivityScreen()),
                                );
                              }
                            },
                            child: Text(
                              'View All',
                              style: GoogleFonts.inriaSans(
                                fontSize: 14,
                                color: const Color(0xFF2B5A82),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Recent Activity Cards
                      if (recentJobs.isEmpty &&
                          snapshot.connectionState == ConnectionState.waiting)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (recentJobs.isEmpty)
                        _buildEmptyActivityCard()
                      else
                        ...recentJobs.map((job) {
                          final rawStatus = job['status'] as String? ?? 'pending';
                          String displayStatus = 'Pending';
                          if (rawStatus == 'completed') displayStatus = 'Completed';
                          else if (rawStatus == 'canceled' || rawStatus == 'cancelled') displayStatus = 'Canceled';
                          else if (rawStatus == 'accepted') displayStatus = 'On Going';

                          // Time display
                          final dateStr = job['created_at'];
                          String timeDisplay = 'Recently';
                          if (dateStr != null) {
                            final date = DateTime.tryParse(dateStr)?.toLocal();
                            if (date != null) {
                              final diff = DateTime.now().difference(date);
                              if (diff.inHours < 1) {
                                timeDisplay = '${diff.inMinutes} min ago';
                              } else if (diff.inDays == 0) {
                                timeDisplay = '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
                              } else if (diff.inDays == 1) {
                                timeDisplay = 'Yesterday';
                              } else {
                                timeDisplay = '${diff.inDays} days ago';
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ActivityCard(
                              title: job['title'] ?? 'Service Request',
                              timeAgo: timeDisplay,
                              status: displayStatus,
                            ),
                          );
                        }),
                      
                      const SizedBox(height: 32),

                      // Your Stats Header
                      Text(
                        'Your Stats',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Total Requests Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Requests',
                                    style: GoogleFonts.inriaSans(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    snapshot.connectionState == ConnectionState.waiting &&
                                            snapshot.data == null
                                        ? '—'
                                        : '$totalRequests',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.assignment_outlined, size: 40, color: Colors.black38),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Active Job Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: StreamBuilder<Map<String, dynamic>?>(
              stream: JobsLogic().getUserActiveJob(),
              builder: (context, snapshot) {
                final job = snapshot.data;
                if (job == null) return const SizedBox.shrink();

                final mechanicName = job['mechanic_name'] ?? 'Mechanic';
                final title = job['title'] ?? 'Service Request';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserActivityScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF24A159),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.build_circle, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job in Progress',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$mechanicName is working on "$title"',
                                style: GoogleFonts.inriaSans(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'No recent activity yet.',
        style: GoogleFonts.inriaSans(
          fontSize: 15,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFBF00),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(55),
          bottomLeft: Radius.circular(55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 60.0, left: 24.0, right: 24.0, bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _firstName.isNotEmpty ? 'Welcome, $_firstName!' : 'Welcome!',
            style: GoogleFonts.inriaSans(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cebu Institute of\nTechnology University',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                'Request Help from Nearby Mechanics',
                style: GoogleFonts.inriaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAskForHelpButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFBF00),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserDashboardScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ask for Help',
                  style: GoogleFonts.inriaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.black, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// Reusable stateless widget for Recent Activity cards
class ActivityCard extends StatelessWidget {
  final String title;
  final String timeAgo;
  final String status;

  const ActivityCard({
    super.key,
    required this.title,
    required this.timeAgo,
    this.status = 'Completed',
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = const Color(0xFF24A159);
        break;
      case 'On Going':
        statusColor = Colors.deepOrange.shade700;
        break;
      case 'Canceled':
        statusColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.black54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inriaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: GoogleFonts.inriaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: GoogleFonts.inriaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
