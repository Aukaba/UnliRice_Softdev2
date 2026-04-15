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
      'name': 'Bernante, Vince',
      'email': 'VinceBernante@gmail.com',
      'contact': '09987654321',
    },
    {
      'id': 2,
      'name': 'Aaron, Barnaija',
      'email': 'AaronBarnaija@gmail.com',
      'contact': '09123456789',
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
      body: Stack(
        children: [
          // Full screen background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF164D83),
                    Color(0xFF1A5A96),
                    Color(0xFFD6E4F0),
                    Color(0xFFF0F5FA),
                  ],
                  stops: [0.0, 0.25, 0.65, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Management System',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Cards list ────────────────────────────────────────
                Expanded(
                  child: _pendingMechanics.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text(
            'No pending mechanics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All mechanics have been reviewed.',
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

// ── Mechanic card — matching image 3 ─────────────────────────────────────────

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name
          Text(
            mechanic['name'] ?? '—',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Pending label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pending Approval',
              style: TextStyle(
                color: Color(0xFF856404),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // Email row
          _InfoRow(label: 'Email:', value: mechanic['email'] ?? '—'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Contact:', value: mechanic['contact'] ?? '—'),
          const SizedBox(height: 12),

          // Certification link
          Row(
            children: [
              const Text(
                'CERTIFICATION:  ',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See Certification Here',
                  style: TextStyle(
                    color: Color(0xFF164D83),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Approve / Reject buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                        color: Color(0xFFEF4444), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              )),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              )),
        ),
      ],
    );
  }
}