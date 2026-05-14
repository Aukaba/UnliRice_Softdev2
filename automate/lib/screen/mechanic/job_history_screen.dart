import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Cancelled'];

  final List<_HistoryJobData> _jobs = const [
    _HistoryJobData(
      title: 'Engine Repair',
      client: 'Ron Seldizo',
      vehicle: 'Toyota Vios',
      date: 'Apr 28, 2025',
      duration: '2h 15m',
      price: '₱2,000',
      status: 'Completed',
      rating: 5,
    ),
    _HistoryJobData(
      title: 'Flat Tire Fix',
      client: 'Aaron Barnaija',
      vehicle: 'Yamaha N-115',
      date: 'Apr 27, 2025',
      duration: '45m',
      price: '₱1,200',
      status: 'Completed',
      rating: 5,
    ),
    _HistoryJobData(
      title: 'AC Repair',
      client: 'Mambaling Motorcab',
      vehicle: 'Toyota Vios',
      date: 'Apr 26, 2025',
      duration: '3h',
      price: '₱1,800',
      status: 'Completed',
      rating: 4,
    ),
    _HistoryJobData(
      title: 'Oil Change',
      client: 'Jay Mercado',
      vehicle: 'Honda Civic',
      date: 'Apr 25, 2025',
      duration: '30m',
      price: '₱800',
      status: 'Completed',
      rating: 5,
    ),
    _HistoryJobData(
      title: 'Brake Check',
      client: 'Liza Santos',
      vehicle: 'Mitsubishi Mirage',
      date: 'Apr 24, 2025',
      duration: '-',
      price: '₱0',
      status: 'Cancelled',
      rating: 0,
    ),
    _HistoryJobData(
      title: 'Transmission Flush',
      client: 'Bert Quizon',
      vehicle: 'Ford Ranger',
      date: 'Apr 23, 2025',
      duration: '1h 30m',
      price: '₱2,500',
      status: 'Completed',
      rating: 4,
    ),
  ];

  List<_HistoryJobData> get _filtered {
    if (_selectedFilter == 'All') return _jobs;
    return _jobs.where((j) => j.status == _selectedFilter).toList();
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
              left: -70,
              top: 160,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -60,
              bottom: 200,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  color: Color(0x1FFFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 60,
              child: Container(
                width: 150,
                height: 150,
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
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Job History',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${_filtered.length} jobs found',
                                  style: GoogleFonts.inriaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: _filters.map((f) {
                          final active = _selectedFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFilter = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: active ? Colors.black : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  f,
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
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No $_selectedFilter jobs',
                            style: GoogleFonts.inriaSans(
                              fontSize: 15,
                              color: Colors.black38,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 20, 16, 24),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) =>
                              _HistoryCard(job: _filtered[i]),
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

class _HistoryJobData {
  final String title;
  final String client;
  final String vehicle;
  final String date;
  final String duration;
  final String price;
  final String status;
  final int rating;

  const _HistoryJobData({
    required this.title,
    required this.client,
    required this.vehicle,
    required this.date,
    required this.duration,
    required this.price,
    required this.status,
    required this.rating,
  });
}

class _HistoryCard extends StatelessWidget {
  final _HistoryJobData job;
  const _HistoryCard({required this.job});

  bool get _isCompleted => job.status == 'Completed';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _isCompleted
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  size: 22,
                  color: _isCompleted
                      ? const Color(0xFF2F8A48)
                      : const Color(0xFFD72B2B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${job.client} · ${job.vehicle}',
                      style: GoogleFonts.inriaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? const Color(0xFFE8F7EA)
                      : const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.status,
                  style: GoogleFonts.inriaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isCompleted
                        ? const Color(0xFF2F8A48)
                        : const Color(0xFFD72B2B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF0F0F0)),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                job.date,
                style: GoogleFonts.inriaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.timer_outlined,
                  size: 13, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                job.duration,
                style: GoogleFonts.inriaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              ),
              const Spacer(),
              if (_isCompleted && job.rating > 0)
                Row(
                  children: List.generate(
                    job.rating,
                    (_) => const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFFFB703)),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                job.price,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF121212),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}