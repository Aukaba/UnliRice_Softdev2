import 'package:flutter/material.dart';

class AdminMechanicVerificationContent extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const AdminMechanicVerificationContent({super.key, this.onSwitchTab});

  @override
  State<AdminMechanicVerificationContent> createState() =>
      _AdminMechanicVerificationContentState();
}

class _AdminMechanicVerificationContentState
    extends State<AdminMechanicVerificationContent> {
  final List<Map<String, dynamic>> _pendingMechanics = [
    {
      'id': 1,
      'name': 'Aaron Barnaija',
      'email': 'AaronBarnaija@gmail.com',
      'contact': '09123456789',
    },
    {
      'id': 2,
      'name': 'Vince Bernante',
      'email': 'VinceBernante@gmail.com',
      'contact': '09987654321',
    },
    {
      'id': 3,
      'name': 'Maria Santos',
      'email': 'MariaSantos@gmail.com',
      'contact': '09112345678',
    },
  ];

  void _removeCard(int mechanicId, String action) {
    setState(() {
      _pendingMechanics.removeWhere((m) => m['id'] == mechanicId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'approved'
              ? 'Mechanic approved successfully.'
              : 'Mechanic rejected.',
        ),
        backgroundColor: action == 'approved'
            ? const Color(0xFF009227)
            : const Color(0xFFBF2D2D),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/AutoMate_logo.png',
                    width: 44,
                    height: 44,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF164D83).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings,
                          color: Color(0xFF164D83), size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mechanic Verification',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 17,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF164D83), size: 26),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // ── Body with gradient background ─────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Gradient background — top: 302 equivalent, fades toward bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF164D83),
                            const Color(0xFF164D83).withOpacity(0.8),
                            const Color(0xFF164D83).withOpacity(0.4),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(19),
                          topRight: Radius.circular(19),
                        ),
                      ),
                    ),
                  ),

                  // Cards list
                  _pendingMechanics.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                          itemCount: _pendingMechanics.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final mechanic = _pendingMechanics[index];
                            return _MechanicCard(
                              mechanic: mechanic,
                              onApprove: () => _removeCard(
                                  mechanic['id'] as int, 'approved'),
                              onReject: () => _removeCard(
                                  mechanic['id'] as int, 'rejected'),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No pending mechanics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All mechanics have been reviewed.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ── Mechanic card ────────────────────────────────────────────────────────────

class _MechanicCard extends StatelessWidget {
  final Map<String, dynamic> mechanic;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _MechanicCard({
    required this.mechanic,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Name:',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              )),
          Text(mechanic['name'] ?? '—',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 8),
          const Text('Email:',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              )),
          Text(mechanic['email'] ?? '—',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 8),
          const Text('Contact:',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              )),
          Text(mechanic['contact'] ?? '—',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 12),
          const Text('CERTIFICATION:',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              )),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 31, vertical: 8),
              decoration: ShapeDecoration(
                color: const Color(0xFF203C63),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1, color: Colors.black.withOpacity(0.50)),
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: const Text(
                'See Certification Here',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Waiting for approval',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                        color: Color(0xFFBF2D2D), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(49)),
                  ),
                  child: const Text('Reject',
                      style: TextStyle(
                        color: Color(0xFFBF2D2D),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009227),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF22C55E)),
                      borderRadius: BorderRadius.circular(49),
                    ),
                  ),
                  child: const Text('Approve',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}