import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../messages/user_chat_session.dart';

class UserSuccessfulBookingScreen extends StatefulWidget {
  /// Job data passed from the tracking screen.
  final Map<String, dynamic>? jobData;

  const UserSuccessfulBookingScreen({super.key, this.jobData});

  @override
  State<UserSuccessfulBookingScreen> createState() =>
      _UserSuccessfulBookingScreenState();
}

class _UserSuccessfulBookingScreenState
    extends State<UserSuccessfulBookingScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<Map<String, dynamic>> _diagnosisItems = [];
  double _totalBill = 0.0;
  double _diagnosisFee = 0.0;
  int _rating = 0;

  // Resolved from DB
  String _mechanicName = 'Mechanic';
  String _mechanicId = '';

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _field(String key, String fallback) {
    final v = widget.jobData?[key]?.toString();
    return (v != null && v.isNotEmpty) ? v : fallback;
  }

  String get _jobId {
    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    return widget.jobData?['id']?.toString() ??
        widget.jobData?['job_id']?.toString() ??
        jobMap?['id']?.toString() ??
        '';
  }

  String get _bookingId {
    if (_jobId.isEmpty) return 'N/A';
    final short = _jobId.length < 8 ? _jobId : _jobId.substring(0, 8);
    return 'A-${short.toUpperCase()}';
  }

  String get _completedDateLabel {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final h = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'pm' : 'am';
    return '${months[now.month - 1]} ${now.day}, ${now.year} | $h:$m$ampm';
  }

  @override
  void initState() {
    super.initState();
    _mechanicId = _field('mechanic_id', '');
    _mechanicName = _field('mechanic_name', 'Mechanic');
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // 1. Fetch mechanic name if not already present
      if (_mechanicId.isNotEmpty && _mechanicName == 'Mechanic') {
        final mRes = await _supabase
            .from('mechanic')
            .select('first_name, last_name')
            .eq('uid', _mechanicId)
            .maybeSingle();
        if (mRes != null && mounted) {
          final first = mRes['first_name'] ?? '';
          final last = mRes['last_name'] ?? '';
          setState(() => _mechanicName = '$first $last'.trim());
        }
      }

      // 2. Fetch job diagnosis
      if (_jobId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final diagRes = await _supabase
          .from('job_diagnosis')
          .select('id, total_bill, diagnosis_fee')
          .eq('job_id', _jobId)
          .maybeSingle();

      if (diagRes == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final diagnosisId = diagRes['id']?.toString();
      final totalBill =
          double.tryParse(diagRes['total_bill']?.toString() ?? '') ?? 0.0;
      final diagFee =
          double.tryParse(diagRes['diagnosis_fee']?.toString() ?? '') ?? 0.0;

      // 3. Fetch diagnosis items
      List<Map<String, dynamic>> items = [];
      if (diagnosisId != null) {
        final itemsRes = await _supabase
            .from('job_diagnosis_items')
            .select('item_name, price')
            .eq('job_diagnosis_id', diagnosisId);
        items = List<Map<String, dynamic>>.from(itemsRes as List);
      }

      if (mounted) {
        setState(() {
          _diagnosisItems = items;
          _totalBill = totalBill;
          _diagnosisFee = diagFee;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SuccessfulBooking] fetchData error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = _field('pickup_location', 'Unknown Location');
    final jobLat =
        double.tryParse(widget.jobData?['latitude']?.toString() ?? '');
    final jobLng =
        double.tryParse(widget.jobData?['longitude']?.toString() ?? '');
    final jobLatLng = (jobLat != null && jobLng != null)
        ? LatLng(jobLat, jobLng)
        : const LatLng(10.2974, 123.8687);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF19456B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _completedDateLabel,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ── Booking ID ────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking ID',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _bookingId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Booking ID copied'),
                                duration: Duration(seconds: 1)),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              _bookingId,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.copy_outlined,
                                size: 18, color: Colors.black87),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Rating ────────────────────────────────────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rate the mechanic's service and performance.",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final filled = index < _rating;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _rating = index + 1),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  filled ? Icons.star : Icons.star_border,
                                  size: 40,
                                  color: filled
                                      ? const Color(0xFFFFC107)
                                      : const Color(0xFFB0BEC5),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_rating > 0) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              ['', 'Poor', 'Fair', 'Good', 'Very Good',
                                  'Excellent'][_rating],
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFC107),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Mechanic Profile Card ──────────────────────────────────────
                  _buildCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0F2644),
                              ),
                              child: const Icon(Icons.person,
                                  size: 34, color: Color(0xFF19456B)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _mechanicName.toUpperCase(),
                                    style: GoogleFonts.inriaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _rating > 0
                                            ? _rating.toStringAsFixed(1)
                                            : '—',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.star,
                                          color: Color(0xFFFFC107), size: 14),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Chat button
                        if (_mechanicId.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserChatSessionScreen(
                                    mechanicName: _mechanicName,
                                    partnerId: _mechanicId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.sms_outlined,
                                      color: Colors.grey.shade400, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Chat with your mechanic',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF19456B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.send_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Consumables / Bill ────────────────────────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consumables Used:',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_diagnosisItems.isEmpty)
                          Text(
                            'No consumable items recorded.',
                            style: GoogleFonts.montserrat(
                                color: Colors.black54, fontSize: 13),
                          )
                        else
                          _buildTwoColumnItems(_diagnosisItems),
                        const SizedBox(height: 12),
                        Divider(
                          color: Colors.grey.shade300,
                          endIndent:
                              MediaQuery.of(context).size.width * 0.45,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Bill: ₱${_totalBill.toStringAsFixed(0)}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Map + Location ─────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: SizedBox(
                            height: 160,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: jobLatLng,
                                initialZoom: 15.5,
                                interactionOptions:
                                    const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.automate',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: jobLatLng,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        size: 40,
                                        color: Color(0xFF19456B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF005BAC),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pickup,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  /// Renders diagnosis items in a 2-column grid.
  Widget _buildTwoColumnItems(List<Map<String, dynamic>> items) {
    final left = <Map<String, dynamic>>[];
    final right = <Map<String, dynamic>>[];
    for (var i = 0; i < items.length; i++) {
      if (i.isEven) {
        left.add(items[i]);
      } else {
        right.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: left
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${item['item_name']}: ₱${double.tryParse(item['price']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: right
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${item['item_name']}: ₱${double.tryParse(item['price']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}
