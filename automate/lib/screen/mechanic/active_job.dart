import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../Logic/jobs/jobs_logic.dart';
import 'homescreen.dart';

const String kOsrmRoutingBaseUrl = String.fromEnvironment(
  'OSRM_ROUTING_BASE_URL',
  defaultValue: 'https://router.project-osrm.org',
);

class MechanicActiveJobScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const MechanicActiveJobScreen({super.key, this.jobData});

  @override
  State<MechanicActiveJobScreen> createState() =>
      _MechanicActiveJobScreenState();
}

class _MechanicActiveJobScreenState extends State<MechanicActiveJobScreen> {
  final _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();

  LatLng? _mechanicLatLng;
  List<LatLng> _routePoints = [];
  bool _isFirstCameraFit = true;
  bool _isFetchingRoute = false;
  Timer? _locationTimer;

  // Turn-by-turn state
  String? _nextInstruction;
  IconData? _nextTurnIcon;
  String _totalDistanceText = 'Distance unavailable';

  String _phoneNumber = 'Loading...';

  // Helpers to safely pull strings from jobData
  String _field(String key, String fallback) =>
      (widget.jobData?[key]?.toString().isNotEmpty == true)
      ? widget.jobData![key].toString()
      : fallback;

  @override
  void initState() {
    super.initState();
    // Mark the job as in-progress in the DB as soon as the screen opens
    final jobId =
        widget.jobData?['id']?.toString() ??
        widget.jobData?['job_id']?.toString();
    if (jobId != null) {
      JobsLogic().setJobInProgress(jobId).catchError((e) {
        debugPrint('[ActiveJob] setJobInProgress error: $e');
      });
    }
    _fetchPhoneNumber();
    _startLocationTracking();
  }

  Future<void> _fetchPhoneNumber() async {
    final passedPhone = _field('phone_number', _field('phone', ''));
    if (passedPhone.isNotEmpty) {
      if (mounted) setState(() => _phoneNumber = passedPhone);
      return;
    }

    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    final userId =
        widget.jobData?['user_id']?.toString() ??
        jobMap?['user_id']?.toString();

    if (userId != null) {
      try {
        final res = await _supabase
            .from('user')
            .select('phone_number')
            .eq('uid', userId)
            .maybeSingle();
        if (res != null && res['phone_number'] != null) {
          if (mounted)
            setState(() => _phoneNumber = res['phone_number'].toString());
        } else {
          if (mounted) setState(() => _phoneNumber = 'N/A');
        }
      } catch (e) {
        debugPrint('[ActiveJob] Error fetching phone: $e');
        if (mounted) setState(() => _phoneNumber = 'N/A');
      }
    } else {
      if (mounted) setState(() => _phoneNumber = 'N/A');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  /// Gets real GPS, saves to DB, then fetches the OSRM route.
  Future<void> _startLocationTracking() async {
    await _loadRoute(); // immediate first run
    // Then refresh every 15 seconds
    _locationTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadRoute(),
    );
  }

  Future<LatLng?> _getRealLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('[ActiveJob] GPS error: $e');
      return null;
    }
  }

  Future<void> _loadRoute() async {
    if (_isFetchingRoute) return;
    _isFetchingRoute = true;

    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    final latStr =
        widget.jobData?['latitude']?.toString() ??
        jobMap?['latitude']?.toString();
    final lngStr =
        widget.jobData?['longitude']?.toString() ??
        jobMap?['longitude']?.toString();
    final jobLat = double.tryParse(latStr ?? '') ?? 10.2974;
    final jobLng = double.tryParse(lngStr ?? '') ?? 123.8687;
    final jobLatLng = LatLng(jobLat, jobLng);

    // 1. Get real GPS location from device
    LatLng mechLatLng = const LatLng(10.3180, 123.9006); // fallback: Cebu City
    final gpsLatLng = await _getRealLocation();
    if (gpsLatLng != null) {
      mechLatLng = gpsLatLng;
      // Save to mechanic table so other screens can read it
      try {
        final uid = _supabase.auth.currentUser?.id;
        if (uid != null) {
          await _supabase
              .from('mechanic')
              .update({
                'latitude': gpsLatLng.latitude,
                'longitude': gpsLatLng.longitude,
              })
              .eq('uid', uid);
        }
      } catch (e) {
        debugPrint('[ActiveJob] mechanic location save error: $e');
      }
    } else {
      // Fallback: try reading last-known from DB
      try {
        final uid = _supabase.auth.currentUser?.id;
        if (uid != null) {
          final res = await _supabase
              .from('mechanic')
              .select('latitude, longitude')
              .eq('uid', uid)
              .maybeSingle();
          final mLat = double.tryParse(res?['latitude']?.toString() ?? '');
          final mLng = double.tryParse(res?['longitude']?.toString() ?? '');
          if (mLat != null && mLng != null) mechLatLng = LatLng(mLat, mLng);
        }
      } catch (e) {
        debugPrint('[ActiveJob] mechanic location fetch error: $e');
      }
    }

    if (mounted) setState(() => _mechanicLatLng = mechLatLng);

    // 2. Fetch OSRM route
    try {
      final url = Uri.parse(
        '$kOsrmRoutingBaseUrl/route/v1/driving/'
        '${mechLatLng.longitude},${mechLatLng.latitude};'
        '${jobLatLng.longitude},${jobLatLng.latitude}'
        '?geometries=geojson&overview=full&steps=true',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];

          // Total distance
          final distanceMeters = route['distance'] as num?;
          String distText = 'Distance unavailable';
          if (distanceMeters != null) {
            if (distanceMeters >= 1000) {
              distText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
            } else {
              distText = '${distanceMeters.toStringAsFixed(0)} m';
            }
          }

          // Turn-by-turn
          String? nextInst;
          IconData? turnIcon;
          final legs = route['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            final steps = legs[0]['steps'] as List?;
            if (steps != null && steps.length > 1) {
              // steps[0] is usually "depart". steps[1] is the first actual maneuver.
              final nextStep = steps[1];
              final maneuver = nextStep['maneuver'] as Map<String, dynamic>?;
              final modifier = maneuver?['modifier'] as String?;
              final type = maneuver?['type'] as String?;
              final stepDistance = nextStep['distance'] as num?;

              if (modifier != null && stepDistance != null) {
                String distStr = stepDistance >= 1000
                    ? '${(stepDistance / 1000).toStringAsFixed(1)} km'
                    : '${stepDistance.toStringAsFixed(0)} m';

                nextInst = 'Turn $modifier in $distStr';

                if (modifier.contains('left')) {
                  turnIcon = Icons.turn_left;
                } else if (modifier.contains('right')) {
                  turnIcon = Icons.turn_right;
                } else if (modifier.contains('straight')) {
                  turnIcon = Icons.straight;
                } else if (modifier.contains('uturn')) {
                  turnIcon = Icons.u_turn_left;
                } else {
                  turnIcon = Icons.navigation;
                }

                if (type == 'arrive') {
                  nextInst = 'Arrive in $distStr';
                  turnIcon = Icons.flag;
                }
              }
            } else if (steps != null && steps.length == 1) {
              nextInst = 'Arriving shortly';
              turnIcon = Icons.flag;
            }
          }

          final coords = route['geometry']?['coordinates'] as List?;
          if (coords != null) {
            final points = coords
                .map(
                  (c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ),
                )
                .toList();
            if (mounted) {
              setState(() {
                _routePoints = points;
                _totalDistanceText = distText;
                _nextInstruction = nextInst;
                _nextTurnIcon = turnIcon;
              });
              // Fit camera to show both markers ONLY on the first load
              if (points.isNotEmpty && _isFirstCameraFit) {
                _isFirstCameraFit = false;
                final bounds = LatLngBounds.fromPoints([
                  mechLatLng,
                  jobLatLng,
                  ...points,
                ]);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.fitCamera(
                    CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.fromLTRB(40, 150, 40, 300),
                    ),
                  );
                });
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ActiveJob] OSRM route error: $e');
    } finally {
      _isFetchingRoute = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    final serviceType = _field(
      'service_type',
      jobMap?['service_type']?.toString() ?? 'emergency',
    );
    final isScheduled = serviceType.toLowerCase() == 'scheduled';
    final headerColor = isScheduled
        ? const Color(0xFFFFB703)
        : const Color(0xFFE51D1D);

    final clientName = widget.jobData?['user_name'] as String? ?? 'Client';
    final vehicle = _field('vehicle', 'Unknown Vehicle');
    final plate = _field('plate_number', 'N/A');
    final location = _field('pickup_location', 'Unknown Location');
    final issue = _field('issue_description', 'No description provided.');
    final title = _field(
      'title',
      isScheduled ? 'Scheduled Request' : 'Emergency Request',
    );
    final latStr =
        widget.jobData?['latitude']?.toString() ??
        jobMap?['latitude']?.toString();
    final lngStr =
        widget.jobData?['longitude']?.toString() ??
        jobMap?['longitude']?.toString();
    final lat = double.tryParse(latStr ?? '') ?? 10.2974;
    final lng = double.tryParse(lngStr ?? '') ?? 123.8687;
    final mapCenter = LatLng(lat, lng);
    final mechLatLng = _mechanicLatLng ?? const LatLng(10.3180, 123.9006);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: Stack(
        children: [
          // ── Map Background ──
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                MarkerLayer(
                  markers: [
                    // Job location pin
                    Marker(
                      point: mapCenter,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_on,
                        size: 50,
                        color: headerColor,
                      ),
                    ),
                    // Mechanic location pin
                    Marker(
                      point: mechLatLng,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x551A73E8), blurRadius: 8),
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

          // ── Red Top Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Back',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.car_crash,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Turn-by-Turn Overlay ──
          if (_nextInstruction != null)
            Positioned(
              top: 120, // Below the red/yellow header
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
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
                    Icon(
                      _nextTurnIcon ?? Icons.navigation,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _nextInstruction!,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Draggable Bottom Sheet Content ──
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.06,
            maxChildSize: 0.9,
            expand: true,
            snap: true,
            snapSizes: const [0.06, 0.5, 0.9],
            builder: (context, scrollController) {
              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        top: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Location + distance row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: Color(0xFFE51D1D),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inriaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      Icons.directions_car_outlined,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _totalDistanceText,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inriaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Client Information
                          Text(
                            'Client Information',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(label: 'Name', value: clientName),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'Vehicle', value: vehicle),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'Plate', value: plate),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'Phone', value: _phoneNumber),
                          const SizedBox(height: 28),

                          // Issue
                          Text(
                            isScheduled ? 'Issue' : 'Emergency Issue',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            issue,
                            style: GoogleFonts.inriaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Diagnosis button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB703),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: const Size.fromHeight(52),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.medical_information_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              'Diagnosis',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    _DiagnosisDialog(jobData: widget.jobData),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Chat + Call buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CC32F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Chat $clientName',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Opening chat with $clientName',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE51D1D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.flag_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'End Job',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MechanicJobCompleteScreen(
                                              jobData: widget.jobData,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ), // Column
                    ), // SingleChildScrollView
                  ), // ScrollConfiguration
                ), // ClipRRect
              ); // Container
            },
          ),
        ],
      ),
    );
  }
}

// ── Shared info row ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inriaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Diagnosis Dialog ────────────────────────────────────────────────────────

class _DiagnosisDialog extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const _DiagnosisDialog({this.jobData});

  @override
  State<_DiagnosisDialog> createState() => _DiagnosisDialogState();
}

class _DiagnosisDialogState extends State<_DiagnosisDialog> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  bool _isSaving = false;
  final Set<String> _selectedItemIds = {};
  double _totalBill = 200.0; // 200 pesos fixed diagnosis fee
  String? _existingDiagnosisId; // tracks if a record already exists

  @override
  void initState() {
    super.initState();
    _fetchItemsAndExisting();
  }

  Future<void> _fetchItemsAndExisting() async {
    final fallbackItems = [
      {
        'id': 'f1',
        'category': 'Fluids',
        'item_name': 'Engine Oil (Fully Synthetic)',
        'price': 550,
      },
      {
        'id': 'f2',
        'category': 'Fluids',
        'item_name': 'Gear Oil (Scooter)',
        'price': 150,
      },
      {
        'id': 'f3',
        'category': 'Fluids',
        'item_name': 'Coolant Flush (1L)',
        'price': 350,
      },
      {
        'id': 'f4',
        'category': 'Fluids',
        'item_name': 'Brake Fluid Top-up/Bleed',
        'price': 250,
      },
      {
        'id': 'fl1',
        'category': 'Filters',
        'item_name': 'Air Filter (Standard)',
        'price': 450,
      },
      {
        'id': 'fl2',
        'category': 'Filters',
        'item_name': 'Oil Filter (Cartridge/Spin-on)',
        'price': 400,
      },
      {
        'id': 'fl3',
        'category': 'Filters',
        'item_name': 'Cabin/AC Filter',
        'price': 600,
      },
      {
        'id': 'fl4',
        'category': 'Filters',
        'item_name': 'Fuel Filter (External type)',
        'price': 800,
      },
      {
        'id': 'ig1',
        'category': 'Ignition/Elec.',
        'item_name': 'Spark Plug (Standard)',
        'price': 180,
      },
      {
        'id': 'ig2',
        'category': 'Ignition/Elec.',
        'item_name': 'Battery (Maintenance Free)',
        'price': 2800,
      },
      {
        'id': 'ig3',
        'category': 'Ignition/Elec.',
        'item_name': 'Fuse Replacement (Set)',
        'price': 50,
      },
      {
        'id': 'ig4',
        'category': 'Ignition/Elec.',
        'item_name': 'Headlight/Signal Bulb',
        'price': 250,
      },
      {
        'id': 'br1',
        'category': 'Braking',
        'item_name': 'Brake Pads (Front Set)',
        'price': 650,
      },
      {
        'id': 'br2',
        'category': 'Braking',
        'item_name': 'Brake Shoes (Rear)',
        'price': 550,
      },
      {
        'id': 'dr1',
        'category': 'Drivetrain',
        'item_name': 'Chain Clean & Lube',
        'price': 0,
      },
      {
        'id': 'dr2',
        'category': 'Drivetrain',
        'item_name': 'CVT Belt Replacement',
        'price': 1200,
      },
      {
        'id': 'wt1',
        'category': 'Wear & Tear',
        'item_name': 'Wiper Blades (Pair)',
        'price': 750,
      },
      {
        'id': 'wt2',
        'category': 'Wear & Tear',
        'item_name': 'Tire Repair (Plug/Vulcanize)',
        'price': 50,
      },
    ];

    try {
      final res = await _supabase
          .from('diagnosis_items')
          .select()
          .order('category');
      if (mounted) {
        setState(() {
          _items = (res as List).isNotEmpty
              ? List<Map<String, dynamic>>.from(res)
              : fallbackItems;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = fallbackItems;
        });
        debugPrint('DB error fetching diagnosis items, using fallback: $e');
      }
    }

    // After items are loaded, check if a prior diagnosis exists for this job
    await _fetchExistingDiagnosis();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchExistingDiagnosis() async {
    final jobId = _resolveJobId();
    if (jobId == null) return;

    try {
      final diagRes = await _supabase
          .from('job_diagnosis')
          .select('id, total_bill')
          .eq('job_id', jobId)
          .maybeSingle();

      if (diagRes == null || !mounted) return;

      _existingDiagnosisId = diagRes['id']?.toString();

      // Load previously selected items
      final itemsRes = await _supabase
          .from('job_diagnosis_items')
          .select('item_id')
          .eq('job_diagnosis_id', _existingDiagnosisId!);

      if (!mounted) return;

      final savedIds = (itemsRes as List)
          .map((r) => r['item_id'].toString())
          .toSet();

      setState(() {
        _selectedItemIds.addAll(savedIds);
        // Recompute total from saved selections
        _totalBill = 200.0;
        for (final item in _items) {
          if (savedIds.contains(item['id'].toString())) {
            _totalBill += (double.tryParse(item['price'].toString()) ?? 0.0);
          }
        }
      });
    } catch (e) {
      debugPrint('Could not load existing diagnosis: $e');
    }
  }

  String? _resolveJobId() {
    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    return widget.jobData?['id']?.toString() ??
        widget.jobData?['job_id']?.toString() ??
        jobMap?['id']?.toString();
  }

  void _toggleItem(Map<String, dynamic> item, bool? selected) {
    setState(() {
      final id = item['id'].toString();
      final price = double.tryParse(item['price'].toString()) ?? 0.0;

      if (selected == true) {
        _selectedItemIds.add(id);
        _totalBill += price;
      } else {
        _selectedItemIds.remove(id);
        _totalBill -= price;
      }
    });
  }

  Future<void> _saveDiagnosis() async {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item.')),
      );
      return;
    }

    final jobId = _resolveJobId();
    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    final mechanicId =
        widget.jobData?['mechanic_id']?.toString() ??
        jobMap?['mechanic_id']?.toString() ??
        _supabase.auth.currentUser?.id;

    if (jobId == null || mechanicId == null) {
      final missingFields = [
        if (jobId == null) 'job_id',
        if (mechanicId == null) 'mechanic_id',
      ].join(' and ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot save diagnosis: Missing $missingFields.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String diagnosisId;

      if (_existingDiagnosisId != null) {
        // ── UPDATE existing record ──────────────────────────────────────────
        await _supabase
            .from('job_diagnosis')
            .update({'total_bill': _totalBill})
            .eq('id', _existingDiagnosisId!);

        diagnosisId = _existingDiagnosisId!;

        // Delete old items so we can re-insert the current selection cleanly
        await _supabase
            .from('job_diagnosis_items')
            .delete()
            .eq('job_diagnosis_id', diagnosisId);
      } else {
        // ── INSERT new record ───────────────────────────────────────────────
        final diagnosisRes = await _supabase
            .from('job_diagnosis')
            .insert({
              'job_id': jobId,
              'mechanic_id': mechanicId,
              'total_bill': _totalBill,
              'diagnosis_fee': 200.0,
            })
            .select()
            .single();

        diagnosisId = diagnosisRes['id'].toString();
        _existingDiagnosisId = diagnosisId; // cache for future saves
      }

      // Insert currently selected items
      final selectedItemsData = _items
          .where((item) => _selectedItemIds.contains(item['id'].toString()))
          .map(
            (item) => {
              'job_diagnosis_id': diagnosisId,
              'item_id': item['id'].toString(),
              'item_name': item['item_name'].toString(),
              'price': double.tryParse(item['price'].toString()) ?? 0.0,
            },
          )
          .toList();

      await _supabase.from('job_diagnosis_items').insert(selectedItemsData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnosis saved successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save diagnosis: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = <String, List<Map<String, dynamic>>>{};
    for (var item in _items) {
      final cat = item['category']?.toString() ?? 'Other';
      groupedItems.putIfAbsent(cat, () => []).add(item);
    }

    return AlertDialog(
      title: Text(
        'Diagnosis & Bill',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? Text(
                'No diagnosis items found. Please ask the admin to run the SQL script to insert items.',
                style: GoogleFonts.inriaSans(),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: groupedItems.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                entry.key,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            ...entry.value.map((item) {
                              final id = item['id'].toString();
                              final price =
                                  double.tryParse(item['price'].toString()) ??
                                  0.0;
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  item['item_name']?.toString() ?? 'Unknown',
                                  style: GoogleFonts.inriaSans(fontSize: 14),
                                ),
                                subtitle: Text(
                                  '₱${price.toStringAsFixed(2)}',
                                  style: GoogleFonts.inriaSans(
                                    color: const Color(0xFF4CC32F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                value: _selectedItemIds.contains(id),
                                onChanged: _isSaving
                                    ? null
                                    : (val) => _toggleItem(item, val),
                              );
                            }),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Diagnosis Fee',
                              style: GoogleFonts.inriaSans(),
                            ),
                            Text(
                              '₱200.00',
                              style: GoogleFonts.inriaSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Bill',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₱${_totalBill.toStringAsFixed(2)}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFFE51D1D),
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
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.montserrat(color: Colors.black54),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CC32F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isSaving ? null : _saveDiagnosis,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Confirm',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Job Complete Screen ───────────────────────────────────────────────────────

class MechanicJobCompleteScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;
  const MechanicJobCompleteScreen({super.key, this.jobData});

  @override
  State<MechanicJobCompleteScreen> createState() =>
      _MechanicJobCompleteScreenState();
}

class _MechanicJobCompleteScreenState extends State<MechanicJobCompleteScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<Map<String, dynamic>> _diagnosisItems = [];
  double _totalBill = 200.0;

  String _field(String key, String fallback) {
    final v = widget.jobData?[key]?.toString();
    return (v != null && v.isNotEmpty) ? v : fallback;
  }

  String get _bookingId {
    final id = widget.jobData?['id']?.toString() ?? '';
    if (id.isEmpty) return 'N/A';
    return 'A-${id.substring(0, id.length < 8 ? id.length : 8).toUpperCase()}';
  }

  String? get _jobId {
    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    return widget.jobData?['id']?.toString() ??
        widget.jobData?['job_id']?.toString() ??
        jobMap?['id']?.toString();
  }

  @override
  void initState() {
    super.initState();
    _fetchDiagnosis();
  }

  Future<void> _fetchDiagnosis() async {
    if (_jobId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch the diagnosis record for this job
      final diagRes = await _supabase
          .from('job_diagnosis')
          .select('id, total_bill, diagnosis_fee')
          .eq('job_id', _jobId!)
          .maybeSingle();

      if (diagRes == null) {
        setState(() => _isLoading = false);
        return;
      }

      final diagnosisId = diagRes['id']?.toString();
      final totalBill =
          double.tryParse(diagRes['total_bill']?.toString() ?? '') ?? 200.0;

      // Fetch the individual items
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
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching diagnosis for complete screen: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientName = _field('user_name', 'Client');
    final vehicle = _field('vehicle', 'Unknown Vehicle');
    final location = _field('pickup_location', 'Unknown Location');
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dateLabel = '${months[now.month - 1]} ${now.day}, ${now.year}';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final timeLabel = '$hour:$minute$ampm';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: Column(
        children: [
          // Header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 52,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFE51D1D),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$dateLabel  |  $timeLabel',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Booking ID
                    _CompleteCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking ID',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    _bookingId,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Client card
                    _CompleteCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE51D1D),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clientName.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  vehicle,
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
                    ),
                    const SizedBox(height: 12),

                    // Receipt card
                    _CompleteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Items & Consumables:',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Diagnosis fee row
                          _ReceiptItemRow('Diagnosis Fee', 200.0),
                          // Dynamic items from DB
                          if (_diagnosisItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'No items added in diagnosis.',
                                style: GoogleFonts.inriaSans(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                            )
                          else
                            ..._diagnosisItems.map((item) {
                              final name =
                                  item['item_name']?.toString() ?? 'Item';
                              final price =
                                  double.tryParse(
                                    item['price']?.toString() ?? '0',
                                  ) ??
                                  0.0;
                              return _ReceiptItemRow(name, price);
                            }),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Bill:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '₱${_totalBill.toStringAsFixed(2)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE51D1D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Map placeholder card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 160,
                        color: const Color(0xFFD9E2EC),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.map_outlined,
                                size: 48,
                                color: Colors.black26,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF1A3A5C),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: GoogleFonts.inriaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Done button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB703),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(52),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final jobId = _jobId;
                        if (jobId != null) {
                          JobsLogic().setJobCompleted(jobId).catchError((e) {
                            debugPrint('Error setting job to completed: $e');
                          });
                        }
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MechanicHomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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

class _CompleteCard extends StatelessWidget {
  final Widget child;
  const _CompleteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Receipt row for numeric prices (used in the completion screen)
class _ReceiptItemRow extends StatelessWidget {
  final String label;
  final double price;
  const _ReceiptItemRow(this.label, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inriaSans(fontSize: 13, color: Colors.black54),
            ),
          ),
          Text(
            '₱${price.toStringAsFixed(2)}',
            style: GoogleFonts.inriaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
