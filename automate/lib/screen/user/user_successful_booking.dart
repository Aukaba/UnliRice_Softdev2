import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSuccessfulBookingScreen extends StatelessWidget {
  const UserSuccessfulBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF19456B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "March 31, 2026 | 09:03pm",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Booking ID Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking ID",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "A-98HVDJSAHJSJHAS",
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy_outlined, size: 18, color: Colors.black87),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate the mechanic's service and performance.",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(Icons.star, size: 40, color: Color(0xFFB0BEC5)), // Grey stars
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mechanic Profile Card
            _buildCard(
              child: Column(
                children: [
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
                  // Chat Box Button Area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sms_outlined, // Speech bubble with dots
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Chat with your mechanic",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Consumables Used Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Consumables Used:",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tire: ₱2,500", style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Text("Gear Oil: ₱200", style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Travel Cost: ₱40", style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Text("Labor: ₱700", style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Partial divider on the left side
                  Divider(color: Colors.grey.shade300, endIndent: MediaQuery.of(context).size.width * 0.45),
                  const SizedBox(height: 8),
                  Text(
                    "Total Bill: ₱3,440",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Map and Location Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 140, // Map height
                      color: const Color(0xFFE4F0F5),
                      child: Stack(
                        children: [
                          // Dummy map lines and details mimicking the reference image
                          Positioned(
                            top: 60,
                            left: 20,
                            right: -100,
                            child: Container(
                              height: 12,
                              color: Colors.white.withOpacity(0.8),
                              transform: Matrix4.rotationZ(-0.25),
                            ),
                          ),
                          Positioned(
                            top: 100,
                            left: 100,
                            child: Transform(
                              transform: Matrix4.rotationZ(0.2),
                              child: Text(
                                "Arrabal River",
                                style: GoogleFonts.montserrat(
                                  color: Colors.blue.shade300,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "2.42 km - 5 km",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
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
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}
