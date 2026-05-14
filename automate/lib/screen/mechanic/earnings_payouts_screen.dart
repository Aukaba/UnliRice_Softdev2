import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EarningsPayoutsScreen extends StatefulWidget {
  const EarningsPayoutsScreen({super.key});

  @override
  State<EarningsPayoutsScreen> createState() => _EarningsPayoutsScreenState();
}

class _EarningsPayoutsScreenState extends State<EarningsPayoutsScreen> {
  String _selectedPeriod = 'This Week';
  final List<String> _periods = ['Today', 'This Week', 'This Month'];

  // Dummy data per period — swap with Supabase later
  final Map<String, Map<String, String>> _summaryByPeriod = {
    'Today': {'earned': '₱4,500', 'pending': '₱0', 'jobs': '3 Jobs'},
    'This Week': {'earned': '₱23,800', 'pending': '₱1,800', 'jobs': '14 Jobs'},
    'This Month': {'earned': '₱87,200', 'pending': '₱3,200', 'jobs': '52 Jobs'},
  };

  final List<_PayoutData> _payouts = const [
    _PayoutData(
      jobTitle: 'Engine Repair',
      client: 'Ron Seldizo',
      date: 'Apr 28, 2025',
      amount: '₱2,000',
      status: 'Paid',
    ),
    _PayoutData(
      jobTitle: 'Flat Tire Fix',
      client: 'Aaron Barnaija',
      date: 'Apr 27, 2025',
      amount: '₱1,200',
      status: 'Paid',
    ),
    _PayoutData(
      jobTitle: 'AC Repair',
      client: 'Mambaling Motorcab',
      date: 'Apr 26, 2025',
      amount: '₱1,800',
      status: 'Pending',
    ),
    _PayoutData(
      jobTitle: 'Oil Change',
      client: 'Jay Mercado',
      date: 'Apr 25, 2025',
      amount: '₱800',
      status: 'Paid',
    ),
    _PayoutData(
      jobTitle: 'Brake Replacement',
      client: 'Liza Santos',
      date: 'Apr 24, 2025',
      amount: '₱2,500',
      status: 'Paid',
    ),
    _PayoutData(
      jobTitle: 'Transmission Check',
      client: 'Bert Quizon',
      date: 'Apr 23, 2025',
      amount: '₱3,000',
      status: 'Paid',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final summary = _summaryByPeriod[_selectedPeriod]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Decorative amber blobs ──
            Positioned(
              right: -70,
              top: 120,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: 160,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Color(0x1FFFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -40,
              bottom: 60,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB703),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFFFFB703),
                                  size: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Earnings & Payouts',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // ── Period filter ──
                      Row(
                        children: _periods.map((p) {
                          final active = _selectedPeriod == p;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPeriod = p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.black
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p,
                                  style: GoogleFonts.inriaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? const Color(0xFFFFB703)
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Summary cards ──
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                label: 'TOTAL EARNED',
                                value: summary['earned']!,
                                icon: Icons.trending_up_rounded,
                                dark: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                label: 'PENDING',
                                value: summary['pending']!,
                                icon: Icons.hourglass_bottom_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SummaryCard(
                          label: 'JOBS COMPLETED',
                          value: summary['jobs']!,
                          icon: Icons.build_circle_outlined,
                          wide: true,
                        ),

                        const SizedBox(height: 28),

                        // ── Payment history header ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment History',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '${_payouts.length} transactions',
                              style: GoogleFonts.inriaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Payout list ──
                        ..._payouts.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _PayoutCard(data: p),
                            )),
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

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool dark;
  final bool wide;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.dark = false,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF121212) : Colors.white;
    final valueColor = dark ? Colors.white : const Color(0xFF121212);
    final labelColor = dark ? Colors.white38 : Colors.black38;
    final iconColor = dark ? const Color(0xFFFFB703) : Colors.black54;

    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: wide
          ? Row(
              children: [
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: valueColor)),
                    const SizedBox(height: 4),
                    Text(label,
                        style: GoogleFonts.inriaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: labelColor)),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(height: 10),
                Text(value,
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: valueColor)),
                const SizedBox(height: 4),
                Text(label,
                    style: GoogleFonts.inriaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: labelColor)),
              ],
            ),
    );
  }
}

// ── Payout data model ─────────────────────────────────────────────────────────

class _PayoutData {
  final String jobTitle;
  final String client;
  final String date;
  final String amount;
  final String status;

  const _PayoutData({
    required this.jobTitle,
    required this.client,
    required this.date,
    required this.amount,
    required this.status,
  });
}

// ── Payout card ───────────────────────────────────────────────────────────────

class _PayoutCard extends StatelessWidget {
  final _PayoutData data;
  const _PayoutCard({required this.data});

  bool get _isPaid => data.status == 'Paid';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 20, color: Color(0xFF121212)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.jobTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${data.client} · ${data.date}',
                  style: GoogleFonts.inriaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF121212),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isPaid
                      ? const Color(0xFFE8F7EA)
                      : const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data.status,
                  style: GoogleFonts.inriaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isPaid
                        ? const Color(0xFF2F8A48)
                        : const Color(0xFFB07D00),
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