import 'package:flutter/material.dart';

class AdminTransactionHistoryScreen extends StatelessWidget {
  const AdminTransactionHistoryScreen({super.key});

  static const List<Map<String, String>> _transactions = [
    {
      'service': 'Service #1234',
      'driver': 'Alerta',
      'mechanic': 'Doman',
      'payment': '\$139.00',
      'status': 'Complete',
    },
    {
      'service': 'Service #1324',
      'driver': 'Alerta',
      'mechanic': 'Mechanic',
      'payment': '\$150.00',
      'status': 'Complete',
    },
    {
      'service': 'Service #1198',
      'driver': 'Alerta',
      'mechanic': 'Mechanic',
      'payment': '\$130.00',
      'status': 'Complete',
    },
    {
      'service': 'Service #1101',
      'driver': 'Alerta',
      'mechanic': 'Mechanic',
      'payment': '\$100.00',
      'status': 'Complete',
    },
  ];

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
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Transaction cards ─────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: _transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final t = _transactions[index];
                      return _TransactionCard(transaction: t);
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
}

// ── Transaction card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final Map<String, String> transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isComplete = transaction['status'] == 'Complete';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service number + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction['service'] ?? '—',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction['status'] ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Driver
          Row(
            children: [
              Text(
                'Driver: ',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                transaction['driver'] ?? '—',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Mechanic
          Row(
            children: [
              Text(
                'Mechanic: ',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                transaction['mechanic'] ?? '—',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                transaction['payment'] ?? '—',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
