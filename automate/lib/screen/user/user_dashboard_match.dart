import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_successful_booking.dart';

class UserDashboardMatchScreen extends StatefulWidget {
  const UserDashboardMatchScreen({super.key});

  @override
  State<UserDashboardMatchScreen> createState() => _UserDashboardMatchScreenState();
}

class _UserDashboardMatchScreenState extends State<UserDashboardMatchScreen> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Map Background Placeholder
          // (In a real app, this would be a GoogleMap widget, here we simulate the UI)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              color: const Color(0xFFE4F0F5), // Light gray-blue simulating map tone
              child: Stack(
                children: [
                  // Dummy map lines and details mimicking the reference image
                  Positioned(
                    top: 100,
                    left: 20,
                    right: -100,
                    child: Container(
                      height: 12,
                      color: Colors.white.withOpacity(0.8),
                      transform: Matrix4.rotationZ(-0.35),
                    ),
                  ),
                  Positioned(
                    top: 250,
                    left: -50,
                    right: 150,
                    child: Container(
                      height: 16,
                      color: Colors.white.withOpacity(0.8),
                      transform: Matrix4.rotationZ(0.2),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    right: 80,
                    child: Transform(
                      transform: Matrix4.rotationZ(0.2),
                      child: Text(
                        "Arrabal River",
                        style: GoogleFonts.montserrat(
                          color: Colors.blue.shade300,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 300,
                    left: 20,
                    child: Text(
                      "University\nof Cebu...\nMaritime\nEducation...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Dummy map pins (Start & End)
                  Positioned(
                    top: 200,
                    left: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF19456B), width: 3),
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 30,
                          color: const Color(0xFF19456B),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 340,
                    left: MediaQuery.of(context).size.width * 0.5,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF005BAC), // Solid blue dot
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Floating Info Card at the top
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19456B), // Deep Blue color matching main theme
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "Your mechanic can view your location and is currently on the way.",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom White Card overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(top: 32.0, left: 24.0, right: 24.0, bottom: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "The mechanic is on the way",
                      style: GoogleFonts.inriaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Pickup location is shown on the map (near CIT-U)",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mechanic Profile Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Profile Row
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0F2644), // Very dark blue bg
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 38,
                                    color: const Color(0xFF19456B).withOpacity(0.8), // Inner outline color
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name & Rating
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ROMEL ESCAPE",
                                      style: GoogleFonts.inriaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "5.0",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFFFC107),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Plate or Mechanic Code
                              Text(
                                "HDHSIKE",
                                style: GoogleFonts.inriaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Chat Input Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: TextField(
                                    controller: _chatController,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.sms_outlined, color: Colors.grey.shade400, size: 22),
                                      hintText: "Chat with your mechanic",
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade500,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  if (_chatController.text.trim().isNotEmpty) {
                                    _chatController.clear();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF19456B),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Cancel Booking Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle cancel booking
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C), // Deep Red
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "CANCEL BOOKING",
                          style: GoogleFonts.inriaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Temporary Button to Navigate to UserMatchMechScreen
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserSuccessfulBookingScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "TEMP: Go to Match Mech",
                          style: GoogleFonts.inriaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Back Button overlaid on Map just for ease of testing navigation structure
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: const SizedBox.shrink(), // Add custom back arrow here if needed
          ),
        ],
      ),
    );
  }
}
