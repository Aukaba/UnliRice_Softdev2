import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserLookingMechanicScreen extends StatefulWidget {
  const UserLookingMechanicScreen({super.key});

  @override
  State<UserLookingMechanicScreen> createState() => _UserLookingMechanicScreenState();
}

class _UserLookingMechanicScreenState extends State<UserLookingMechanicScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Setup pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
                    "Currently searching for a mechanic.",
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
                      "Looking for a mechanic",
                      style: GoogleFonts.inriaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Box
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          // Blue ring icon
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF005BAC), // Inner solid blue
                            ),
                            child: Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Cebu Institute of Technology - University",
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Breathing Logo Area
                    Center(
                      child: SizedBox(
                        height: 120, // Control logo size
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            'assets/images/AutoMate_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Cancel Booking Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle cancel searching
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
