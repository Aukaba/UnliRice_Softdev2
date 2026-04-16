import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _vehicleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitJobRequest() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty || _vehicleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await JobsLogic().createJob(
        title: _titleController.text,
        vehicle: _vehicleController.text,
        pickupLocation: _locationController.text,
        serviceType: isEmergency ? 'emergency' : 'scheduled',
        scheduledDate: isEmergency ? null : (_selectedDate ?? DateTime.now()),
        issueDescription: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );
      
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
          _descriptionController.clear();
          setState(() {
            _selectedDate = null;
          });

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Job Scheduled',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: const Color(0xFF19456B)),
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
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: const Color(0xFF19456B)),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
          // Background - Deep gold map overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              color: const Color(0xFFF0EBE1), // Light base map tone
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(
                        0xFFD4AF37,
                      ).withOpacity(0.15), // Deep gold overlay
                    ),
                  ),
                  // Map lines placeholder
                  Positioned(
                    top: 150,
                    left: 50,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: Colors.white,
                      transform: Matrix4.rotationZ(-0.2),
                    ),
                  ),
                  // Search Bar
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Map Pin
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF19456B).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 28,
                        color: Color(0xFF19456B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Foreground - Main White Card
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.38,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        color: const Color(0xFFEFEFEF), // Light gray background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: "Cebu Institute of Technology - University",
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
                            onTap: () => setState(() => isEmergency = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                            onTap: () => setState(() => isEmergency = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
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
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: _isLoading ? Colors.grey : const Color(0xFF19456B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: _isLoading 
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
        ],
      ),
    );
  }
}
