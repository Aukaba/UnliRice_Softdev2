import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {

  bool _isLoading = true;
  List<_HistoryJobData> _jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchJobHistory();
  }

  Future<void> _fetchJobHistory() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch completed jobs for this mechanic
      final jobsList = await Supabase.instance.client
          .from('jobs')
          .select('id, title, status, created_at, scheduled_date, user_id, vehicle')
          .eq('mechanic_id', uid)
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      final userIds = jobsList
          .map((j) => j['user_id'])
          .where((id) => id != null)
          .toSet()
          .toList();
      final jobIds = jobsList.map((j) => j['id']).toList();

      // Fetch user names
      Map<String, String> userNameMap = {};
      if (userIds.isNotEmpty) {
        try {
          final usersRes = await Supabase.instance.client
              .from('user')
              .select('uid, first_name, last_name')
              .inFilter('uid', userIds);
          for (var u in usersRes) {
            final name =
                '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
            userNameMap[u['uid']] = name.isEmpty ? 'Unknown Client' : name;
          }
        } catch (_) {}
      }

      // Fetch diagnosis bills for completed jobs
      Map<String, double> diagMap = {};
      if (jobIds.isNotEmpty) {
        try {
          final diagRes = await Supabase.instance.client
              .from('job_diagnosis')
              .select('job_id, total_bill')
              .inFilter('job_id', jobIds);
          for (var d in diagRes) {
            diagMap[d['job_id']] =
                double.tryParse(d['total_bill']?.toString() ?? '0') ?? 0.0;
          }
        } catch (_) {}
      }

      // Fetch ratings for completed jobs
      Map<String, int> ratingMap = {};
      if (jobIds.isNotEmpty) {
        try {
          final ratingsRes = await Supabase.instance.client
              .from('job_ratings')
              .select('job_id, rating')
              .inFilter('job_id', jobIds);
          for (var r in ratingsRes) {
            ratingMap[r['job_id']] =
                (r['rating'] as num?)?.round() ?? 0;
          }
        } catch (_) {}
      }

      final List<_HistoryJobData> loaded = [];
      for (var job in jobsList) {
        final rawDate = job['scheduled_date'] ?? job['created_at'];
        final date = rawDate != null
            ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
            : DateTime.now();
        final dateStr = DateFormat('MMM d, yyyy').format(date);

        final bill = diagMap[job['id']] ?? 0.0;
        final isCompleted = job['status'] == 'completed';

        loaded.add(_HistoryJobData(
          title: job['title']?.toString() ?? 'Job',
          client: userNameMap[job['user_id']] ?? 'Unknown Client',
          vehicle: job['vehicle']?.toString() ?? '-',
          date: dateStr,
          price: isCompleted
              ? '₱${NumberFormat('#,##0').format(bill + 200)}'
              : '₱0',
          status: 'Completed',
          rating: ratingMap[job['id']] ?? 0,
        ));
      }

      if (mounted) {
        setState(() {
          _jobs = loaded;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching job history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
                                  _isLoading
                                      ? 'Loading...'
                                      : '${_jobs.length} jobs found',
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
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFFB703)))
                      : _jobs.isEmpty
                          ? Center(
                              child: Text(
                                'No completed jobs',
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
                              itemCount: _jobs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) =>
                                  _HistoryCard(job: _jobs[i]),
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
  final String price;
  final String status;
  final int rating;

  const _HistoryJobData({
    required this.title,
    required this.client,
    required this.vehicle,
    required this.date,
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