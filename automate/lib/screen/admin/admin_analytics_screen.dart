import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_transaction_history_screen.dart';

class AdminAnalyticsContent extends StatefulWidget {
  const AdminAnalyticsContent({super.key});

  @override
  State<AdminAnalyticsContent> createState() => _AdminAnalyticsContentState();
}

class _AdminAnalyticsContentState extends State<AdminAnalyticsContent> {
  bool _isLoading = true;
  int _monthlyTransactions = 0;
  double _monthlyPercentage = 0.0;
  List<Map<String, dynamic>> _chartData = [];

  @override
  void initState() {
    super.initState();
    debugPrint('=== ANALYTICS INIT STATE ===');
    _loadAnalytics();
  }

Future<void> _loadAnalytics() async {
  debugPrint('=== LOAD ANALYTICS STARTED ===');
  
  try {
    // Use raw query to bypass any Supabase client issues
    final response = await Supabase.instance.client
        .from('jobs')
        .select('*')
        .eq('status', 'completed');
    
    debugPrint('=== RAW RESPONSE TYPE: ${response.runtimeType} ===');
    debugPrint('=== RAW RESPONSE: $response ===');
    
    final List<dynamic> jobs;
    if (response is List) {
      jobs = response;
    } else {
      jobs = [];
    }
    
    debugPrint('=== COMPLETED JOBS COUNT: ${jobs.length} ===');
    
    // Print each job's created_at
    for (final job in jobs) {
      debugPrint('=== JOB: ${job['id']} | created: ${job['created_at']} ===');
    }

    if (mounted) {
      setState(() {
        _monthlyTransactions = jobs.length;
        _chartData = [
          {'month': 'Jan', 'value': 0},
          {'month': 'Feb', 'value': 0},
          {'month': 'Mar', 'value': 0},
          {'month': 'Apr', 'value': jobs.length},
        ];
        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('=== ANALYTICS ERROR: $e ===');
    if (mounted) setState(() {
      _monthlyTransactions = 0;
      _isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    debugPrint('=== ANALYTICS BUILD: $_isLoading, $_monthlyTransactions ===');
    
    final size = MediaQuery.of(context).size;
    final maxValue = _chartData.fold<int>(0, (max, item) {
      final v = item['value'] as int;
      return v > max ? v : max;
    });
    final chartMax = maxValue > 0 ? (maxValue * 1.2).ceil() : 10;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 1, top: size.height * 0.44,
              child: Container(
                width: size.width, height: size.height * 0.62,
                decoration: ShapeDecoration(
                  color: const Color(0x38164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                  shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
                ),
              ),
            ),
            Positioned(
              left: 1, top: size.height * 0.52,
              child: Container(
                width: size.width, height: size.height * 0.54,
                decoration: ShapeDecoration(
                  color: const Color(0x7F164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                  shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
                ),
              ),
            ),
            Positioned(
              left: 1, top: size.height * 0.59,
              child: Container(
                width: size.width, height: size.height * 0.47,
                decoration: ShapeDecoration(
                  color: const Color(0xAA164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                  shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF164D83),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: const Icon(Icons.analytics, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 12),
                      const Text('Analytics', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF19456B), size: 28),
                        onPressed: _loadAnalytics,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF164D83)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatCard(
                                title: 'Transaction this Month:',
                                value: '$_monthlyTransactions',
                                percentage: '+0%',
                                isPositive: true,
                              ),
                              const SizedBox(height: 20),
                              const Text('Month Breakdown', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0x7F203C63)), borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 140,
                                      child: _chartData.isEmpty
                                          ? const Center(child: Text('No data'))
                                          : Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: _chartData.map((data) {
                                                final value = (data['value'] as int?) ?? 0;
                                                final barHeight = chartMax > 0 ? (value / chartMax) * 110 : 0.0;
                                                return Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Text('$value', style: const TextStyle(fontSize: 10, color: Color(0xFF555555), fontFamily: 'Inter')),
                                                        const SizedBox(height: 4),
                                                        Container(height: barHeight, decoration: const BoxDecoration(color: Color(0xCCFB8500), borderRadius: BorderRadius.vertical(top: Radius.circular(4)))),
                                                        const SizedBox(height: 6),
                                                        Text(data['month'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF555555), fontFamily: 'Inter')),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Row(
                                      children: [
                                        Icon(Icons.square, size: 12, color: Color(0xFFFB8500)),
                                        SizedBox(width: 6),
                                        Text('Transactions', style: TextStyle(fontSize: 11, color: Color(0xFF555555), fontFamily: 'Inter')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: ShapeDecoration(color: const Color(0xAA164D83), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Transaction History:', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionHistoryScreen())),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1), borderRadius: BorderRadius.circular(60)),
                                        child: const Text('See Here', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final bool isPositive;
  const _StatCard({required this.title, required this.value, required this.percentage, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white, shape: RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12)),
        shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: Stack(
        children: [
          SizedBox(width: 260, child: Text(title, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
          Positioned(right: 0, top: 4, child: Text(percentage, style: TextStyle(color: isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500))),
          Padding(padding: const EdgeInsets.only(top: 36), child: SizedBox(width: double.infinity, child: Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 28, fontFamily: 'Inter', fontWeight: FontWeight.w700)))),
        ],
      ),
    );
  }
}