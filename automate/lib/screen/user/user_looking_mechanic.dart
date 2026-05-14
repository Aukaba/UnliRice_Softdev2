import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_dashboard_match.dart';

class UserLookingMechanicScreen extends StatefulWidget {
  const UserLookingMechanicScreen({super.key});

  @override
  State<UserLookingMechanicScreen> createState() =>
      _UserLookingMechanicScreenState();
}

class _UserLookingMechanicScreenState extends State<UserLookingMechanicScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  Timer? _checkTimer;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();

    // Setup pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ✅ Start checking for mechanic acceptance
    _startCheckingForMechanic();
  }

  // ✅ Poll for mechanic acceptance every 3 seconds
 void _startCheckingForMechanic() {
  _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
    if (_isCancelled || !mounted) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Check emergency_dispatches for accepted dispatch
      final dispatches = await Supabase.instance.client
          .from('emergency_dispatches')
          .select('*, jobs!inner(*), mechanic:mechanic_id(first_name, last_name)')
          .eq('jobs.user_id', userId)
          .eq('status', 'accepted')
          .order('created_at', ascending: false)
          .limit(1);

      if (dispatches.isNotEmpty && mounted) {
        _checkTimer?.cancel();
        
        final dispatch = dispatches.first;
        final job = dispatch['jobs'] as Map<String, dynamic>? ?? {};
        final mechanic = dispatch['mechanic'] as Map<String, dynamic>? ?? {};
        
        final mechanicName = '${mechanic['first_name'] ?? ''} ${mechanic['last_name'] ?? ''}'.trim();
        job['mechanic_name'] = mechanicName.isNotEmpty ? mechanicName : 'Mechanic';
        job['mechanic_id'] = dispatch['mechanic_id'] ?? '';
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardMatchScreen(jobData: job),
          ),
        );
      }
    } catch (e) {
      debugPrint('[LookingForMechanic] Error: $e');
    }
  });
}
  void _cancelBooking() async {
    _isCancelled = true;
    _checkTimer?.cancel();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Cancel the pending emergency job
        await Supabase.instance.client
            .from('jobs')
            .update({'status': 'cancelled'})
            .eq('user_id', userId)
            .eq('service_type', 'emergency')
            .eq('status', 'pending');
      }
    } catch (e) {
      debugPrint('Error cancelling: $e');
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map Background Placeholder
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              color: const Color(0xFFE4F0F5),
              child: Stack(
                children: [
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
                ],
              ),
            ),
          ),

          // Top info card
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 18.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19456B),
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

          // Bottom White Card
          Align(
            alignment: Alignment.bottomCenter,
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
              padding: const EdgeInsets.only(
                top: 32.0,
                left: 24.0,
                right: 24.0,
                bottom: 40.0,
              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF005BAC),
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

                  // Breathing Logo
                  Center(
                    child: SizedBox(
                      height: 120,
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

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cancelBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
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
        ],
      ),
    );
  }
}
