import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_successful_booking.dart';

class UserDashboardMatchScreen extends StatefulWidget {
  /// Pass the job map so we can read job lat/lng and mechanic_id.
  final Map<String, dynamic>? jobData;

  const UserDashboardMatchScreen({super.key, this.jobData});

  @override
  State<UserDashboardMatchScreen> createState() =>
      _UserDashboardMatchScreenState();
}

class _UserDashboardMatchScreenState extends State<UserDashboardMatchScreen> {
  final _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();

  LatLng? _mechanicLatLng;
  List<LatLng> _routePoints = [];
  String _distanceText = 'Calculating...';
  String _mechanicName = 'Mechanic';
  String _mechanicId = '';
  String _jobId = '';

  Timer? _pollTimer;
  bool _isFetching = false;
  bool _navigatedAway = false;

  @override
  void initState() {
    super.initState();
    _jobId = widget.jobData?['id']?.toString() ?? '';
    _mechanicId = widget.jobData?['mechanic_id']?.toString() ?? '';
    _mechanicName = widget.jobData?['mechanic_name']?.toString() ?? 'Mechanic';

    _fetchAndDraw();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchAndDraw();
      _checkJobCompletion();
    });
    _checkJobCompletion(); // also run immediately
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Fetch mechanic location from DB and draw OSRM route ──────────────────────
  Future<void> _fetchAndDraw() async {
    if (_isFetching || _mechanicId.isEmpty) return;
    _isFetching = true;

    try {
      // 1. Read mechanic's last-known location from DB
      final mRes = await _supabase
          .from('mechanic')
          .select('latitude, longitude, first_name, last_name')
          .eq('uid', _mechanicId)
          .maybeSingle();

      if (mRes == null) return;

      final mLat = double.tryParse(mRes['latitude']?.toString() ?? '');
      final mLng = double.tryParse(mRes['longitude']?.toString() ?? '');

      if (mLat == null || mLng == null) return;

      final mechLatLng = LatLng(mLat, mLng);

      // Also refresh mechanic name
      final first = mRes['first_name'] ?? '';
      final last = mRes['last_name'] ?? '';
      final name = '$first $last'.trim();
      if (name.isNotEmpty && mounted) {
        setState(() => _mechanicName = name);
      }

      // 2. Job location
      final jobLat = double.tryParse(
              widget.jobData?['latitude']?.toString() ?? '') ??
          10.2974;
      final jobLng = double.tryParse(
              widget.jobData?['longitude']?.toString() ?? '') ??
          123.8687;
      final jobLatLng = LatLng(jobLat, jobLng);

      // 3. Fetch OSRM route
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${mechLatLng.longitude},${mechLatLng.latitude};'
        '${jobLatLng.longitude},${jobLatLng.latitude}'
        '?geometries=geojson&overview=full',
      );
      final response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final distM = route['distance'] as num?;
          String distText = 'Distance unavailable';
          if (distM != null) {
            distText = distM >= 1000
                ? '${(distM / 1000).toStringAsFixed(1)} km'
                : '${distM.toStringAsFixed(0)} m';
          }
          final coords = route['geometry']?['coordinates'] as List?;
          final points = coords
                  ?.map((c) =>
                      LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
                  .toList() ??
              [];

          if (mounted) {
            setState(() {
              _mechanicLatLng = mechLatLng;
              _routePoints = points;
              _distanceText = distText;
            });

            // Fit camera to both markers
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final bounds = LatLngBounds.fromPoints(
                    [mechLatLng, jobLatLng, ...points]);
                _mapController.fitCamera(
                  CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(60)),
                );
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[UserDashboardMatch] route error: $e');
    } finally {
      _isFetching = false;
    }
  }

  // ── Poll job status and auto-navigate when completed ─────────────────────────
  Future<void> _checkJobCompletion() async {
    if (_jobId.isEmpty || _navigatedAway) return;
    try {
      final res = await _supabase
          .from('jobs')
          .select('status')
          .eq('id', _jobId)
          .maybeSingle();

      if (res != null && res['status'] == 'completed' && mounted && !_navigatedAway) {
        _navigatedAway = true;
        _pollTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const UserSuccessfulBookingScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('[UserDashboardMatch] status check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Job location (used for the red pin)
    final jobLat =
        double.tryParse(widget.jobData?['latitude']?.toString() ?? '') ??
            10.2974;
    final jobLng =
        double.tryParse(widget.jobData?['longitude']?.toString() ?? '') ??
            123.8687;
    final jobLatLng = LatLng(jobLat, jobLng);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── 1. Full-screen Map ────────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: jobLatLng,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.automate',
                ),
                // Route polyline
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5.0,
                        color: const Color(0xFF1A73E8),
                      ),
                    ],
                  ),
                // Markers
                MarkerLayer(
                  markers: [
                    // Job/destination pin (red)
                    Marker(
                      point: jobLatLng,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Color(0xFFE51D1D),
                      ),
                    ),
                    // Mechanic pin (blue dot)
                    if (_mechanicLatLng != null)
                      Marker(
                        point: _mechanicLatLng!,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A73E8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.engineering,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── 2. Top info banner ────────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19456B),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your mechanic is on the way · $_distanceText',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Bottom sheet ───────────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                  top: 24.0, left: 24.0, right: 24.0, bottom: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The mechanic is on the way',
                    style: GoogleFonts.inriaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.jobData?['pickup_location'] != null
                        ? 'Pickup: ${widget.jobData!['pickup_location']}'
                        : 'Pickup location shown on the map',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mechanic profile card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Avatar
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
                        // Name & distance
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
                                  const Icon(Icons.route,
                                      size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    _distanceText,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Cancel Booking Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'CANCEL BOOKING',
                        style: GoogleFonts.inriaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
