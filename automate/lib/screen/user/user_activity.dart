import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../messages/user_chat_session.dart';
import '../../Logic/jobs/jobs_logic.dart';

class UserActivityScreen extends StatefulWidget {
  final VoidCallback? onMessageTap;
  const UserActivityScreen({super.key, this.onMessageTap});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  late final Stream<List<Map<String, dynamic>>> _activityStream;

  @override
  void initState() {
    super.initState();
    _activityStream = JobsLogic().getUserActivityJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient to match the yellow tone at the bottom
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    const Color(0xFFF9D976).withOpacity(0.4),
                    const Color(0xFFF9D976).withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_none, size: 30, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                        'Activity',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // List of Activities
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _activityStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final jobs = snapshot.data ?? [];
                      if (jobs.isEmpty) {
                        return Center(
                          child: Text(
                            'No past activities yet.',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      }
                      
                      // Sort jobs by most recent
                      jobs.sort((a, b) {
                        final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                        final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                        return bDate.compareTo(aDate);
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          
                          // Determine status logic
                          final rawStatus = job['status'] as String? ?? 'pending';
                          String displayStatus = 'Pending';
                          if (rawStatus == 'completed') displayStatus = 'Done';
                          else if (rawStatus == 'canceled') displayStatus = 'Canceled';
                          else if (rawStatus == 'accepted') {
                            final schedStr = job['scheduled_date'];
                            if (schedStr != null) {
                              final schedDate = DateTime.tryParse(schedStr);
                              if (schedDate != null) {
                                if (schedDate.isAfter(DateTime.now())) {
                                  displayStatus = 'Assigned';
                                } else {
                                  displayStatus = 'On Going';
                                }
                              } else {
                                displayStatus = 'On Going';
                              }
                            } else {
                              displayStatus = 'On Going';
                            }
                          }

                          // Determine time logic
                          final dateStr = job['created_at'];
                          String timeDisplay = 'Recently';
                          if (dateStr != null) {
                            final date = DateTime.tryParse(dateStr);
                            if (date != null) {
                              final diff = DateTime.now().difference(date);
                              if (diff.inDays == 0) {
                                timeDisplay = 'Today, ${date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour)}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
                              } else if (diff.inDays == 1) {
                                timeDisplay = 'Yesterday, ${date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour)}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
                              } else {
                                timeDisplay = '${diff.inDays} days ago';
                              }
                            }
                          }

                          return _buildActivityCard(
                            context: context,
                            name: job['mechanic_name'] ?? (job['mechanic_id'] != null ? 'Mechanic Assigned' : 'Waiting for Mechanic'),
                            partnerId: job['mechanic_id'],
                            service: job['title'] ?? 'Service',
                            status: displayStatus,
                            time: timeDisplay,
                            price: 'Pending', // Would fetch real price if available
                            rating: '-', // Ratings logic not implemented yet
                            avatarColor: const Color(0xFF6A8FB0),
                            onMessageTap: widget.onMessageTap,
                          );
                        },
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required String name,
    required String service,
    required String status,
    required String time,
    required String price,
    required String rating,
    required Color avatarColor,
    String? partnerId,
    VoidCallback? onMessageTap,
  }) {
    bool isCompleted = status == 'Done' || status == 'Completed';
    bool isOngoingOrAssigned = status == 'Assigned' || status == 'On Going';
    bool isPending = status == 'Pending';

    Color statusBgColor = isCompleted
        ? const Color(0xFFA5D6A7).withOpacity(0.8)
        : isOngoingOrAssigned
            ? const Color(0xFFFFCC80).withOpacity(0.8) // assigned/ongoing -> orange
            : isPending
                ? Colors.grey.shade300
                : const Color(0xFFEF9A9A).withOpacity(0.8); // canceled -> red

    Color statusTextColor = isCompleted
        ? Colors.green.shade800
        : isOngoingOrAssigned
            ? Colors.deepOrange.shade800
            : isPending
                ? Colors.black54
                : Colors.red.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar, Name, Service, and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: avatarColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Timestamp
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 8),
            // Price, Rating, Message Button
            Row(
              children: [
                Text(
                  price,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 18, color: Colors.amber.shade500),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (partnerId != null && partnerId.isNotEmpty)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      if (onMessageTap != null) {
                        onMessageTap();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserChatSessionScreen(
                              mechanicName: name,
                              partnerId: partnerId,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 16, color: const Color(0xFF6A8FB0)),
                          const SizedBox(width: 6),
                          Text(
                            'Message',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6A8FB0),
                            ),
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
