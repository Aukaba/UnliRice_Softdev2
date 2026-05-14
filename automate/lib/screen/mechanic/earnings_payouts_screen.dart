import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EarningsPayoutsScreen extends StatefulWidget {
  const EarningsPayoutsScreen({super.key});

  @override
  State<EarningsPayoutsScreen> createState() => _EarningsPayoutsScreenState();
}

class _EarningsPayoutsScreenState extends State<EarningsPayoutsScreen> {
  String _selectedPeriod = 'This Week';
  final List<String> _periods = ['Today', 'This Week', 'This Month'];

  bool _isLoading = true;

  Map<String, Map<String, String>> _summaryByPeriod = {
    'Today': {'earned': '₱0', 'pending': '₱0', 'jobs': '0 Jobs'},
    'This Week': {'earned': '₱0', 'pending': '₱0', 'jobs': '0 Jobs'},
    'This Month': {'earned': '₱0', 'pending': '₱0', 'jobs': '0 Jobs'},
  };

  List<_PayoutData> _payouts = [];

  @override
  void initState() {
    super.initState();
    _fetchEarningsData();
  }

  Future<void> _fetchEarningsData() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch jobs
      final jobsList = await Supabase.instance.client
          .from('jobs')
          .select('id, title, status, created_at, scheduled_date, user_id')
          .eq('mechanic_id', uid)
          .inFilter('status', ['completed', 'in_progress', 'accepted', 'pending_payment'])
          .order('created_at', ascending: false);

      final userIds = jobsList.map((j) => j['user_id']).where((id) => id != null).toSet().toList();
      final jobIds = jobsList.map((j) => j['id']).toList();

      // Fetch related users
      Map<String, Map<String, dynamic>> userMap = {};
      if (userIds.isNotEmpty) {
        try {
          final usersRes = await Supabase.instance.client
              .from('user')
              .select('uid, first_name, last_name')
              .inFilter('uid', userIds);
          for (var u in usersRes) {
            userMap[u['uid']] = u;
          }
        } catch (_) {}
      }

      // Fetch related diagnoses
      Map<String, double> diagMap = {};
      if (jobIds.isNotEmpty) {
        try {
          final diagRes = await Supabase.instance.client
              .from('job_diagnosis')
              .select('job_id, total_bill')
              .inFilter('job_id', jobIds);
          for (var d in diagRes) {
            diagMap[d['job_id']] = double.tryParse(d['total_bill']?.toString() ?? '0') ?? 0.0;
          }
        } catch (_) {}
      }

      final now = DateTime.now();
      
      double earnedToday = 0; int jobsToday = 0;
      double earnedWeek = 0; int jobsWeek = 0;
      double earnedMonth = 0; int jobsMonth = 0;

      List<_PayoutData> loadedPayouts = [];

      for (var job in jobsList) {
        final status = job['status'];
        final isCompleted = status == 'completed';
        
        final userObj = userMap[job['user_id']];
        String clientName = 'Unknown Client';
        if (userObj != null) {
          clientName = '${userObj['first_name'] ?? ''} ${userObj['last_name'] ?? ''}'.trim();
          if (clientName.isEmpty) clientName = 'Unknown Client';
        }

        final rawDate = job['scheduled_date'] ?? job['created_at'];
        final date = rawDate != null ? DateTime.tryParse(rawDate.toString()) ?? now : now;
        final dateStr = DateFormat('MMM d, yyyy').format(date);

        double bill = diagMap[job['id']] ?? 0.0;

        // Add ₱200 labor fee for completed jobs
        final totalAmount = isCompleted ? bill + 200 : bill;

        loadedPayouts.add(_PayoutData(
          jobTitle: job['title']?.toString() ?? 'Job',
          client: clientName,
          date: dateStr,
          amount: '₱${NumberFormat('#,##0').format(totalAmount)}',
          status: isCompleted ? 'Paid' : 'Pending',
        ));

        // Time checks
        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
        
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final isThisWeek = date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                           date.isBefore(endOfWeek.add(const Duration(days: 1)));
                           
        final isThisMonth = date.year == now.year && date.month == now.month;

        if (isToday) {
          if (isCompleted) { earnedToday += bill + 200; jobsToday++; }
        }
        if (isThisWeek) {
          if (isCompleted) { earnedWeek += bill + 200; jobsWeek++; }
        }
        if (isThisMonth) {
          if (isCompleted) { earnedMonth += bill + 200; jobsMonth++; }
        }
      }

      if (mounted) {
        setState(() {
          _summaryByPeriod = {
            'Today': {
              'earned': '₱${NumberFormat('#,##0').format(earnedToday)}',
              'jobs': '$jobsToday Jobs'
            },
            'This Week': {
              'earned': '₱${NumberFormat('#,##0').format(earnedWeek)}',
              'jobs': '$jobsWeek Jobs'
            },
            'This Month': {
              'earned': '₱${NumberFormat('#,##0').format(earnedMonth)}',
              'jobs': '$jobsMonth Jobs'
            },
          };
          _payouts = loadedPayouts;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching earnings: $e\\n$st');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

            _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB703)))
                : Column(
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
                                label: 'JOBS COMPLETED',
                                value: summary['jobs']!,
                                icon: Icons.build_circle_outlined,
                              ),
                            ),
                          ],
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