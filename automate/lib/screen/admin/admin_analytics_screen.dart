import 'package:flutter/material.dart';
import 'admin_transaction_history_screen.dart';

class AdminAnalyticsContent extends StatelessWidget {
  const AdminAnalyticsContent({super.key});

  static const List<Map<String, dynamic>> _chartData = [
    {'month': 'Jan', 'value': 95},
    {'month': 'Feb', 'value': 110},
    {'month': 'Mar', 'value': 128},
    {'month': 'Apr', 'value': 102},
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
            // Blue layered backgrounds rising from bottom — original Figma design
            Positioned(
              left: 1,
              top: size.height * 0.44,
              child: Container(
                width: size.width,
                height: size.height * 0.62,
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
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 1,
              top: size.height * 0.52,
              child: Container(
                width: size.width,
                height: size.height * 0.54,
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
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 1,
              top: size.height * 0.59,
              child: Container(
                width: size.width,
                height: size.height * 0.47,
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
                      Container(
                        width: 70,
                        height: 70,
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
                        'Analytics',
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

                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction this Month
                        _StatCard(
                          title: 'Transaction this Month:',
                          value: '67',
                          percentage: '+12.5%',
                          isPositive: false,
                        ),
                        const SizedBox(height: 12),

                        // Total Revenue
                        _StatCard(
                          title: 'Total Revenue:',
                          value: '₱ 84,300.00',
                          percentage: '+9%',
                          isPositive: true,
                        ),

                        const SizedBox(height: 20),

                        // Month Breakdown label
                        const Text(
                          'Month Breakdown',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Bar chart
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0x7F203C63),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 140,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: _chartData.map((data) {
                                    final barHeight =
                                        (data['value'] / 160.0) * 110;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${data['value']}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF555555),
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              height: barHeight,
                                              decoration: const BoxDecoration(
                                                color: Color(0xCCFB8500),
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(4),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              data['month'],
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF555555),
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFB8500),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Transaction',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF555555),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Transaction History row — tapping See Here navigates to full list later
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xAA164D83),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Transaction History:',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminTransactionHistoryScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
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
          ],
        ),
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.isPositive,
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
      child: Stack(
        children: [
          SizedBox(
            width: 260,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: Text(
              percentage,
              style: TextStyle(
                color: isPositive
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
