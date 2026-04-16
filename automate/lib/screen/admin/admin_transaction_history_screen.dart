import 'package:flutter/material.dart';

class AdminTransactionHistoryScreen extends StatelessWidget {
  const AdminTransactionHistoryScreen({super.key});

  static const List<Map<String, String>> _transactions = [
    {
      'service': 'Service #1234',
      'driver': 'John Smith',
      'mechanic': 'Aaron, Barnaija',
      'payment': 'P 1,354.00',
      'date': 'March 12, 2026',
      'status': 'Completed',
    },
    {
      'service': 'Service #1324',
      'driver': 'Mark Diaz',
      'mechanic': 'Aaron, Barnaija',
      'payment': 'P 1,250.00',
      'date': 'March 9, 2026',
      'status': 'Completed',
    },
    {
      'service': 'Service #1198',
      'driver': 'Maria Santos',
      'mechanic': 'Vince Bernante',
      'payment': 'P 2,100.00',
      'date': 'March 5, 2026',
      'status': 'Completed',
    },
    {
      'service': 'Service #1101',
      'driver': 'Pedro Reyes',
      'mechanic': 'Vince Bernante',
      'payment': 'P 850.00',
      'date': 'Feb 28, 2026',
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Subtle diagonal gradient: pale navy top-left → white bottom-right
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x1A164D83),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF164D83),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                      'Transaction History',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
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

              // ── Transaction cards ─────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  itemCount: _transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final t = _transactions[index];
                    return _TransactionCard(transaction: t);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Transaction card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final Map<String, String> transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCompleted = transaction['status'] == 'Completed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(4),
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
          // Service number with colored left border accent
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF164D83),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                transaction['service'] ?? '—',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Driver:', value: transaction['driver'] ?? '—'),
          _InfoRow(label: 'Mechanic:', value: transaction['mechanic'] ?? '—'),
          _InfoRow(
              label: 'Tot. Payment:', value: transaction['payment'] ?? '—'),
          _InfoRow(label: 'Date:', value: transaction['date'] ?? '—'),
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text('Status:',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.69,
                    )),
              ),
              Text(
                transaction['status'] ?? '—',
                style: TextStyle(
                  color: isCompleted
                      ? const Color(0xFF29A017)
                      : const Color(0xFFEF4444),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.69,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                height: 1.69,
              )),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 1.69,
              )),
        ),
      ],
    );
  }
}