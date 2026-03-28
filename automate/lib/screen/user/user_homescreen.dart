import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_dashboard.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0; // Default active index is Map

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          _buildHeader(),
          
          // Main Body Scrollable Section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
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
                        Text(
                          'View All',
                          style: GoogleFonts.inriaSans(
                            fontSize: 14,
                            color: const Color(0xFF2B5A82),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recent Activity Cards
                    const ActivityCard(
                      title: 'Engine Check',
                      timeAgo: 'Completed 2 hours ago',
                    ),
                    const SizedBox(height: 12),
                    const ActivityCard(
                      title: 'Tire Replacement',
                      timeAgo: 'Completed yesterday',
                    ),
                    const SizedBox(height: 12),
                    const ActivityCard(
                      title: 'Oil Change',
                      timeAgo: 'Completed 3 days ago',
                    ),
                    
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

                    // Stats Card Placeholder
                    Container(
                      width: double.infinity,
                      height: 100, // Matching the proportion shown in design
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Total Requests',
                        style: GoogleFonts.inriaSans(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFBF00),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(55), // Explicitly large bottom-right curve
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
            'Welcome, Angelic!',
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: const Color(0xFF2B5A82), // Deep Blue specified
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: GoogleFonts.inriaSans(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inriaSans(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.location_on),
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.notifications_none),
            ),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.chat_bubble_outline),
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.person_outline),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Reusable stateless widget for Recent Activity cards
class ActivityCard extends StatelessWidget {
  final String title;
  final String timeAgo;

  const ActivityCard({
    super.key,
    required this.title,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inriaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
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
          Text(
            'Completed',
            style: GoogleFonts.inriaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF24A159), // Proper Green status color
            ),
          ),
        ],
      ),
    );
  }
}
