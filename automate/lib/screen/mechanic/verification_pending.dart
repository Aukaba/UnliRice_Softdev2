import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';

class MechanicPendingVerificationScreen extends StatefulWidget {
  final String submittedId;

  const MechanicPendingVerificationScreen({
    super.key,
    required this.submittedId,
  });

  @override
  State<MechanicPendingVerificationScreen> createState() =>
      _MechanicPendingVerificationScreenState();
}

class _MechanicPendingVerificationScreenState
    extends State<MechanicPendingVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // DEV-ONLY: tap the icon 5 times to skip to homescreen
  int _devTapCount = 0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _devSkip() {
    _devTapCount++;
    if (_devTapCount >= 5) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MechanicHomeScreen()),
      );
    }
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
              right: -80,
              top: 80,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Color(0x20FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -90,
              bottom: 140,
              child: Container(
                width: 320,
                height: 320,
                decoration: const BoxDecoration(
                  color: Color(0x18FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 40,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0x2FFFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ── Content ──
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // ── Pulsing icon ──
                      GestureDetector(
                        onTap: _devSkip,
                        child: ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB703),
                              borderRadius: BorderRadius.circular(38),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFFB703).withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.hourglass_top_rounded,
                              size: 56,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Title ──
                      Text(
                        'Pending\nVerification',
                        style: GoogleFonts.montserrat(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Your ID has been submitted.\nOur admin team will review it shortly.',
                        style: GoogleFonts.inriaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 36),

                      // ── Submitted ID card ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3CC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.credit_card_outlined,
                                size: 20,
                                color: Color(0xFFB07D00),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Submitted ID',
                                    style: GoogleFonts.inriaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.submittedId,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Pending',
                                style: GoogleFonts.inriaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB07D00),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Steps ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What happens next?',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _StepRow(
                              number: '1',
                              text: 'Admin reviews your submitted ID',
                              isDone: true,
                            ),
                            const SizedBox(height: 12),
                            _StepRow(
                              number: '2',
                              text:
                                  'You\'ll receive a notification once approved',
                              isDone: false,
                            ),
                            const SizedBox(height: 12),
                            _StepRow(
                              number: '3',
                              text:
                                  'Start accepting jobs on the platform',
                              isDone: false,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),

                      // ── Bottom note ──
                      Text(
                        'Usually takes 1–2 business days.\nYou\'ll be notified via the app.',
                        style: GoogleFonts.inriaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black38,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),
                    ],
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

class _StepRow extends StatelessWidget {
  final String number;
  final String text;
  final bool isDone;

  const _StepRow({
    required this.number,
    required this.text,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFFFFB703)
                : const Color(0xFFF0F0F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded,
                    size: 14, color: Colors.black)
                : Text(
                    number,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black45,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: GoogleFonts.inriaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDone ? Colors.black87 : Colors.black45,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}