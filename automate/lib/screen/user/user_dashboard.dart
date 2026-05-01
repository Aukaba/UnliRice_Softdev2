import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../widgets/calendar_widget.dart';
import 'user_looking_mechanic.dart';
import '../../Logic/jobs/jobs_logic.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  bool isEmergency = true; // State for Service Type toggle

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  Timer? _debounce;

  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(
    10.2974,
    123.8687,
  ); // Default to CIT-U, Cebu

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _vehicleController.dispose();
    _plateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AutomateApp/1.0 (contact@example.com)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['display_name'] != null) {
          if (mounted) {
            setState(() {
              _locationController.text = data['display_name']
                  .toString()
                  .split(',')
                  .take(2)
                  .join(', ');
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    }
  }

  void _submitJobRequest() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _vehicleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEmergency) {
        await JobsLogic().dispatchEmergency(
          title: _titleController.text,
          vehicle: _vehicleController.text,
          plateNumber: _plateController.text.isEmpty
              ? null
              : _plateController.text,
          pickupLocation: _locationController.text,
          issueDescription: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
        );
      } else {
        await JobsLogic().createJob(
          title: _titleController.text,
          vehicle: _vehicleController.text,
          plateNumber: _plateController.text.isEmpty
              ? null
              : _plateController.text,
          pickupLocation: _locationController.text,
          serviceType: 'scheduled',
          scheduledDate: _selectedDate != null
              ? DateTime.utc(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  _selectedTime?.hour ?? 0,
                  _selectedTime?.minute ?? 0,
                ).subtract(const Duration(hours: 8)) // Ensure it is interpreted as UTC+8 (PST)
              : DateTime.now(),
          issueDescription: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
        );
      }

      if (mounted) {
        if (isEmergency) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserLookingMechanicScreen(),
            ),
          );
        } else {
          // Reset fields
          _titleController.clear();
          _locationController.clear();
          _vehicleController.clear();
          _plateController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedDate = null;
            _selectedTime = null;
          });

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Job Scheduled',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF19456B),
                ),
              ),
              content: Text(
                'Your scheduled service request has been successfully posted! Mechanics will review it, and you can track updates in your Activity tab.',
                style: GoogleFonts.inriaSans(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'OK',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF19456B),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background - Interactive Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 15.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      _selectedLocation = position.center;
                    });
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 800), () {
                      _reverseGeocode(_selectedLocation);
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.automate',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Color(0xFF19456B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Foreground - Main White Card
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.1,
            maxChildSize: 0.9,
            expand: true,
            snap: true,
            snapSizes: const [0.1, 0.5, 0.9],
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
                        left: 24.0,
                        right: 24.0,
                        bottom: 32.0,
                        top: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            "Request Help",
                            style: GoogleFonts.inriaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Issue Title",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: "e.g., Engine won't start",
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Vehicle Information",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _vehicleController,
                              decoration: InputDecoration(
                                hintText: "e.g., Toyota Vios",
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "License Plate",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _plateController,
                              decoration: InputDecoration(
                                hintText: "e.g., ABC-1234",
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Pickup Location",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEFEFEF,
                              ), // Light gray background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                hintText:
                                    "Cebu Institute of Technology - University",
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                                suffixIcon: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Service Type",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => isEmergency = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isEmergency
                                          ? const Color(0xFF19456B)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isEmergency
                                            ? const Color(0xFF19456B)
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Emergency",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: isEmergency
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isEmergency
                                            ? Colors.white
                                            : const Color(0xFF19456B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => isEmergency = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isEmergency
                                          ? const Color(0xFF19456B)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !isEmergency
                                            ? const Color(0xFF19456B)
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Scheduled",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: !isEmergency
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: !isEmergency
                                            ? Colors.white
                                            : const Color(0xFF19456B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (!isEmergency) ...[
                            Text(
                              "Select the date",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CalendarWidget(
                              onDateSelected: (date) {
                                _selectedDate = date;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Select the time",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() => _selectedTime = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFEFEF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedTime != null 
                                          ? _selectedTime!.format(context)
                                          : "Choose a time",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: _selectedTime != null ? Colors.black87 : Colors.black54,
                                      ),
                                    ),
                                    const Icon(Icons.access_time, color: Colors.black54),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          Text(
                            "Issue Description (Optional)",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "Describe your issue...",
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF19456B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 6,
                                child: GestureDetector(
                                  onTap: _isLoading ? null : _submitJobRequest,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isLoading
                                          ? Colors.grey
                                          : const Color(0xFF19456B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            isEmergency
                                                ? "Request Help"
                                                : "Request Service",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ), // Padding below content before navigation bar
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
