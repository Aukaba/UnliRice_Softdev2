import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserActivityScreen extends StatelessWidget {
  const UserActivityScreen({super.key});

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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: [
                      _buildActivityCard(
                        name: 'Romel Escape',
                        service: 'Engine Diagnostics',
                        status: 'Completed',
                        time: 'Today, 2:30 PM',
                        price: '₱5,000',
                        rating: '4.8',
                        avatarColor: const Color(0xFF6A8FB0),
                      ),
                      _buildActivityCard(
                        name: 'Sarah Johnson',
                        service: 'Tire Replacement',
                        status: 'Completed',
                        time: 'Yesterday, 4:15 PM',
                        price: '₱3,067',
                        rating: '5.0',
                        avatarColor: const Color(0xFF6A8FB0),
                      ),
                      _buildActivityCard(
                        name: 'Regin Mercado',
                        service: 'Oil Change',
                        status: 'Completed',
                        time: '3 days ago, 10:00 AM',
                        price: '₱3,067',
                        rating: '4.5',
                        avatarColor: const Color(0xFF6A8FB0),
                      ),
                      _buildActivityCard(
                        name: 'Mike Wilson',
                        service: 'Battery Check',
                        status: 'Canceled',
                        time: '1 week ago, 6:45 PM',
                        price: '₱3,067',
                        rating: '4.5',
                        avatarColor: const Color(0xFF6A8FB0),
                      ),
                    ],
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
    required String name,
    required String service,
    required String status,
    required String time,
    required String price,
    required String rating,
    required Color avatarColor,
  }) {
    bool isCompleted = status == 'Completed';
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
                    color: isCompleted ? const Color(0xFFA5D6A7).withOpacity(0.8) : const Color(0xFFEF9A9A).withOpacity(0.8), // subtle green / red background
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.green.shade800 : Colors.red.shade800,
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
                InkWell(
                  onTap: () {
                    // Navigate to message or handle click
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
