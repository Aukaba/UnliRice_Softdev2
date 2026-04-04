import 'package:flutter/material.dart';

class AdminTransactionHistoryScreen extends StatelessWidget {
  const AdminTransactionHistoryScreen({super.key});

  // Dummy data — replace with Supabase later
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Blue layered backgrounds rising from top — original Figma design
            Positioned(
              left: 0,
              top: 87,
              child: Container(
                width: size.width,
                height: size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x38164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
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
              ),
            ),
            Positioned(
              left: 1,
              top: size.height * 0.36,
              child: Container(
                width: size.width,
                height: size.height * 0.70,
                decoration: ShapeDecoration(
                  color: const Color(0x7F164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
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
              ),
            ),
            Positioned(
              left: 1,
              top: size.height * 0.61,
              child: Container(
                width: size.width,
                height: size.height * 0.45,
                decoration: ShapeDecoration(
                  color: const Color(0xAA164D83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
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
              ),
            ),

            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF19456B),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: ShapeDecoration(
                          image: const DecorationImage(
                            image: NetworkImage("https://placehold.co/98x98"),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
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
                      const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF19456B),
                        size: 28,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Transaction cards list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(36, 0, 36, 24),
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
          ],
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
          // Service number
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
          const SizedBox(height: 4),

          _InfoRow(label: 'Driver:', value: transaction['driver'] ?? '—'),
          _InfoRow(label: 'Mechanic:', value: transaction['mechanic'] ?? '—'),
          _InfoRow(
            label: 'Tot. Payment:',
            value: transaction['payment'] ?? '—',
          ),
          _InfoRow(label: 'Date:', value: transaction['date'] ?? '—'),

          // Status row
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'Status:',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.69,
                  ),
                ),
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
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 1.69,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.69,
            ),
          ),
        ),
      ],
    );
  }
}
