import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminTransactionHistoryScreen extends StatefulWidget {
  const AdminTransactionHistoryScreen({super.key});

  @override
  State<AdminTransactionHistoryScreen> createState() =>
      _AdminTransactionHistoryScreenState();
}

class _AdminTransactionHistoryScreenState
    extends State<AdminTransactionHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      // Get completed jobs
      final jobsData = await Supabase.instance.client
          .from('jobs')
          .select('*')
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(50);

      final jobs = jobsData as List;
      final List<Map<String, dynamic>> transactions = [];

      for (final job in jobs) {
        final jobId = job['id'] as String;
        final userId = job['user_id'] as String?;
        final mechanicId = job['mechanic_id'] as String?;

        // Get user name
        String driverName = 'Unknown';
        if (userId != null) {
          try {
            final userData = await Supabase.instance.client
                .from('user')
                .select('first_name, last_name')
                .eq('uid', userId)
                .maybeSingle();
            if (userData != null) {
              driverName = '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
              if (driverName.isEmpty) driverName = 'Unknown';
            }
          } catch (_) {}
        }

        // Get mechanic name
        String mechanicName = 'Unknown';
        if (mechanicId != null) {
          try {
            final mechData = await Supabase.instance.client
                .from('mechanic')
                .select('first_name, last_name')
                .eq('uid', mechanicId)
                .maybeSingle();
            if (mechData != null) {
              mechanicName = '${mechData['first_name'] ?? ''} ${mechData['last_name'] ?? ''}'.trim();
              if (mechanicName.isEmpty) mechanicName = 'Unknown';
            }
          } catch (_) {}
        }

        // Get total bill from job_diagnosis
        double totalBill = 0.0;
        try {
          final diagnosis = await Supabase.instance.client
              .from('job_diagnosis')
              .select('total_bill')
              .eq('job_id', jobId)
              .maybeSingle();
          if (diagnosis != null) {
            totalBill = (diagnosis['total_bill'] as num?)?.toDouble() ?? 0.0;
          }
        } catch (_) {}

        // Format date
        final dateStr = job['created_at'] as String?;
        String formattedDate = '—';
        if (dateStr != null) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            const months = [
              'January', 'February', 'March', 'April', 'May', 'June',
              'July', 'August', 'September', 'October', 'November', 'December'
            ];
            formattedDate = '${months[date.month - 1]} ${date.day}, ${date.year}';
          }
        }

        transactions.add({
          'service': 'Service #${jobId.substring(0, 8)}',
          'driver': driverName,
          'mechanic': mechanicName,
          'payment': 'P ${totalBill.toStringAsFixed(2)}',
          'date': formattedDate,
          'status': job['status'] ?? 'Completed',
        });
      }

      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 0, top: 87,
              child: Container(
                width: size.width, height: size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x38164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),
            Positioned(
              left: 1, top: size.height * 0.36,
              child: Container(
                width: size.width, height: size.height * 0.70,
                decoration: ShapeDecoration(
                  color: const Color(0x7F164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),
            Positioned(
              left: 1, top: size.height * 0.61,
              child: Container(
                width: size.width, height: size.height * 0.45,
                decoration: ShapeDecoration(
                  color: const Color(0xAA164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF19456B), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF164D83),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.receipt_long, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 12),
                      const Text('Transaction History',
                        style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF19456B), size: 28),
                        onPressed: _loadTransactions,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF164D83)))
                      : _transactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text('No transactions yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                                ],
                              ),
                            )
                          : ListView.separated(
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

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCompleted = transaction['status'] == 'Completed';

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(4)),
        shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(transaction['service'] ?? '—',
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          _InfoRow(label: 'Driver:', value: transaction['driver'] ?? '—'),
          _InfoRow(label: 'Mechanic:', value: transaction['mechanic'] ?? '—'),
          _InfoRow(label: 'Tot. Payment:', value: transaction['payment'] ?? '—'),
          _InfoRow(label: 'Date:', value: transaction['date'] ?? '—'),
          Row(
            children: [
              const SizedBox(width: 100, child: Text('Status:', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
              Text(transaction['status'] ?? '—',
                style: TextStyle(color: isCompleted ? const Color(0xFF29A017) : const Color(0xFFEF4444), fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500))),
      ],
    );
  }
}