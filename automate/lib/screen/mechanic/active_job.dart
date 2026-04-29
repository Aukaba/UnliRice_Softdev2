import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homescreen.dart';
import 'jobs.dart';
import 'schedule.dart';
import '../messages/user_message_list.dart';
import 'profile.dart';

class MechanicActiveJobScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const MechanicActiveJobScreen({super.key, this.jobData});

  @override
  State<MechanicActiveJobScreen> createState() => _MechanicActiveJobScreenState();
}

class _MechanicActiveJobScreenState extends State<MechanicActiveJobScreen> {
  // Helpers to safely pull strings from jobData
  String _field(String key, String fallback) =>
      (widget.jobData?[key]?.toString().isNotEmpty == true)
          ? widget.jobData![key].toString()
          : fallback;

  @override
  Widget build(BuildContext context) {
    final clientName   = widget.jobData?['user_name']  as String? ?? 'Client';
    final vehicle      = _field('vehicle', 'Unknown Vehicle');
    final plate        = _field('plate_number', 'N/A');
    final phone        = _field('phone', 'N/A');
    final location     = _field('pickup_location', 'Unknown Location');
    final issue        = _field('issue_description', 'No description provided.');
    final title        = _field('title', 'Emergency Request');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: Stack(
        children: [
          // ── Map Background Placeholder ──
          Positioned.fill(
            child: Container(color: const Color(0xFFD9E2EC)),
          ),

          // ── Red Top Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFE51D1D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.black, size: 16),
                        const SizedBox(width: 4),
                        Text('Back',
                            style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.car_crash, color: Colors.black, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Sheet Content ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, -6))
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 20, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location + distance row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 18, color: Color(0xFFE51D1D)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(location,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inriaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 10),
                          Row(children: [
                            const Icon(Icons.directions_car_outlined,
                                size: 18, color: Colors.black87),
                            const SizedBox(width: 6),
                            Text('Distance unavailable',
                                style: GoogleFonts.inriaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Client Information
                      Text('Client Information',
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black)),
                      const SizedBox(height: 14),
                      _InfoRow(label: 'Name', value: clientName),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Vehicle', value: vehicle),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Plate', value: plate),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Phone', value: phone),
                      const SizedBox(height: 28),

                      // Emergency Issue
                      Text('Emergency Issue',
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black)),
                      const SizedBox(height: 10),
                      Text(issue,
                          style: GoogleFonts.inriaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.4)),
                      const SizedBox(height: 28),

                      // Diagnosis button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB703),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size.fromHeight(52),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.medical_information_outlined,
                            color: Colors.white, size: 20),
                        label: Text('Diagnosis',
                            style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagnosis feature coming soon')));
                        },
                      ),
                      const SizedBox(height: 12),

                      // Chat + Call buttons
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CC32F),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white,
                                size: 18),
                            label: Text('Chat $clientName',
                                style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening chat with $clientName')));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7A00),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.phone_outlined,
                                color: Colors.white, size: 18),
                            label: Text('Call $clientName',
                                style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling $clientName...')));
                            },
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 0,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicHomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicJobsScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const MechanicScheduleScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const UserMessageListScreen()));
          } else if (index == 4) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const MechanicProfileScreen()));
          }
        },
      ),
    );
  }
}

// ── Shared info row ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inriaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black45)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ),
      ],
    );
  }
}

// ── Bottom nav ──────────────────────────────────────────────────────────────

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
            _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => onItemTapped(0)),
            _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Jobs',
                active: currentIndex == 1,
                onTap: () => onItemTapped(1)),
            _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Schedule',
                active: currentIndex == 2,
                onTap: () => onItemTapped(2)),
            _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                active: currentIndex == 3,
                onTap: () => onItemTapped(3)),
            _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                active: currentIndex == 4,
                onTap: () => onItemTapped(4)),
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
      {required this.icon,
      required this.label,
      this.active = false,
      required this.onTap});

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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}
