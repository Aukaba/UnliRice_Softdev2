import 'package:flutter/material.dart';
import 'admin_transaction_history_screen.dart';

class AdminAnalyticsContent extends StatelessWidget {
  const AdminAnalyticsContent({super.key});

  static const List<Map<String, dynamic>> _chartData = [
    {'month': 'Jan', 'value': 60},
    {'month': 'Feb', 'value': 75},
    {'month': 'Mar', 'value': 85},
    {'month': 'Apr', 'value': 65},
    {'month': 'May', 'value': 70},
    {'month': 'Jun', 'value': 80},
    {'month': 'Det', 'value': 55},
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
                      Container(
                        width: 52,
                        height: 52,
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
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Analytics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat cards row
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStatCard(
                                title: 'Transaction\nthis Month',
                                value: '1,388',
                                subtitle: 'Transaction',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniStatCard(
                                title: 'Total\nRevenue',
                                value: '\$139.6K',
                                subtitle: 'Total Revenu',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Month Breakdown chart card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                              const Text(
                                'Month Breakdown',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Y axis labels + bars
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Y axis
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children:
                                        ['100', '80', '60', '40', '20', '0']
                                            .map(
                                              (v) => SizedBox(
                                                height: 20,
                                                child: Text(
                                                  v,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                  const SizedBox(width: 8),
                                  // Bars
                                  Expanded(
                                    child: SizedBox(
                                      height: 120,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: _chartData.map((data) {
                                          final barH =
                                              (data['value'] / 100.0) * 110;
                                          return Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 3,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    height: barH,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF164D83,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  4,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // X axis labels
                              Padding(
                                padding: const EdgeInsets.only(left: 28),
                                child: Row(
                                  children: _chartData.map((data) {
                                    return Expanded(
                                      child: Text(
                                        data['month'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Transaction History row
                        Container(
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Transaction History',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminTransactionHistoryScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'See Here',
                                      style: TextStyle(
                                        color: Color(0xFF164D83),
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Summary',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '0xFF164D83',
                                style: TextStyle(
                                  color: Color(0xFF164D83),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminTransactionHistoryScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF164D83),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'See Here',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
