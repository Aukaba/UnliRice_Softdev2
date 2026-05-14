import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Authentication/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static final _supabase = Supabase.instance.client;
  bool _isSigningOut = false;
  bool _isLoading = true;

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  List<Map<String, dynamic>> _userVehicles = [];

  Uint8List? _profileImageBytes;
  String? _profileImageUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUserVehicles();
  }

  Future<void> _loadUserInfo() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Query the 'user' table directly (driver/users tables don't exist)
      Map<String, dynamic>? data = await _supabase
          .from('user')
          .select('first_name, last_name, phone_number, profile_image_url')
          .eq('uid', user.id)
          .maybeSingle();
      setState(() {
        final firstName = data?['first_name'] ?? '';
        final lastName = data?['last_name'] ?? '';
        _userName = '$firstName $lastName'.trim();
        _userPhone = data?['phone_number'] ?? '';
        _userEmail = user.email ?? '';
        _profileImageUrl = data?['profile_image_url'];
      });
    } catch (e) {
      print('Error fetching user info: $e');
      if (mounted) {
        setState(() {
          _userName = 'Error';
          _userEmail = user.email ?? 'Error';
          _userPhone = 'Error';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserVehicles() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final vehiclesData = await _supabase
          .from('user_vehicles')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _userVehicles = List<Map<String, dynamic>>.from(vehiclesData);
        });
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _profileImageBytes = bytes;
      _isUploadingPhoto = true;
    });

    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      final fileExt = picked.name.split('.').last;
      final fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('profiles').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      final url = _supabase.storage.from('profiles').getPublicUrl(fileName);

      await _supabase
          .from('user')
          .update({'profile_image_url': url})
          .eq('uid', uid);

      if (mounted) {
        setState(() => _profileImageUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo updated!',
                style: GoogleFonts.inriaSans(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            backgroundColor: const Color(0xFF009227),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to upload profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo.',
                style: GoogleFonts.inriaSans(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _signOut() async {
    // Confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inriaSans(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.montserrat(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Log Out',
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isSigningOut = true);
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white/light grey background
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Top Yellow Background
            Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0xFFFBC02D), // Golden yellow background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Profile Header Card
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  // Vehicle Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(Icons.directions_car, 'Vehicles'),
                      GestureDetector(
                        onTap: () => _showVehicleDialog(context, vehicle: null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF19456B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Add',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_userVehicles.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "No vehicles added yet.",
                        style: GoogleFonts.montserrat(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    ..._userVehicles.map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildVehicleItem(context, v),
                    )),
                  const SizedBox(height: 12),
                  // Contact Info Section
                  _buildSectionTitle(Icons.phone_in_talk_outlined, 'Contact Info'),
                  const SizedBox(height: 12),
                    _buildContactInfoCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _isLoading ? 'Loading...' : (_userEmail.isEmpty ? 'N/A' : _userEmail),
                    ),
                    const SizedBox(height: 12),
                    _buildContactInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: _isLoading ? 'Loading...' : (_userPhone.isEmpty ? 'N/A' : _userPhone),
                    ),
                  const SizedBox(height: 28),

                  // ── Log Out Button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSigningOut ? null : _signOut,
                      icon: _isSigningOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 20),
                      label: Text(
                        'Log Out',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        disabledBackgroundColor:
                            const Color(0xFFD32F2F).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickAndUploadProfileImage,
                child: Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _isUploadingPhoto
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF19456B)),
                                ),
                              )
                            : _profileImageBytes != null
                                ? Image.memory(
                                    _profileImageBytes!,
                                    fit: BoxFit.cover,
                                    width: 70,
                                    height: 70,
                                  )
                                : _profileImageUrl != null
                                    ? Image.network(
                                        _profileImageUrl!,
                                        fit: BoxFit.cover,
                                        width: 70,
                                        height: 70,
                                      )
                                    : const Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF19456B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoading ? 'Loading...' : (_userName.isEmpty ? 'User Profile' : _userName),
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cebu Institute of Technology\nUniversity',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatsBox(Icons.library_books, '24', 'Total Requests'),
              _buildStatsBox(Icons.check, '21', 'Completed'),
              _buildStatsBox(Icons.calendar_month_outlined, '2025', 'Joined Year'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBox(IconData icon, String number, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFCC12D), // Rich amber/yellow
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              number,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleItem(BuildContext context, Map<String, dynamic> vehicle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  vehicle['model'] ?? 'Unknown Model',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF19456B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showVehicleDialog(context, vehicle: vehicle),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBC02D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteVehicle(vehicle['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Del',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plate No.',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle['plate_number'] ?? 'N/A',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF19456B),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mileage',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle['mileage']?.isEmpty ?? true ? 'N/A' : vehicle['mileage'],
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF19456B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Vehicle', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this vehicle?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _supabase.from('user_vehicles').delete().eq('id', id);
      await _loadUserVehicles();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showVehicleDialog(BuildContext context, {Map<String, dynamic>? vehicle}) {
    final isEdit = vehicle != null;
    final nameController = TextEditingController(text: vehicle?['model'] ?? '');
    final plateController = TextEditingController(text: vehicle?['plate_number'] ?? '');
    final mileageController = TextEditingController(text: vehicle?['mileage'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEdit ? 'Edit Vehicle' : 'Add Vehicle',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Vehicle Model',
                hintText: 'e.g. Honda Civic 2021',
                labelStyle: GoogleFonts.montserrat(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateController,
              decoration: InputDecoration(
                labelText: 'Plate Number',
                hintText: 'e.g. ABC 1234',
                labelStyle: GoogleFonts.montserrat(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mileageController,
              decoration: InputDecoration(
                labelText: 'Mileage',
                hintText: 'e.g. 24.5K km',
                labelStyle: GoogleFonts.montserrat(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || plateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Model and Plate are required')));
                return;
              }
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              try {
                final user = _supabase.auth.currentUser;
                if (user == null) return;

                final data = {
                  'user_id': user.id,
                  'model': nameController.text.trim(),
                  'plate_number': plateController.text.trim(),
                  'mileage': mileageController.text.trim(),
                };

                if (isEdit) {
                  await _supabase.from('user_vehicles').update(data).eq('id', vehicle['id']);
                } else {
                  await _supabase.from('user_vehicles').insert(data);
                }
                await _loadUserVehicles();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF19456B),
            ),
            child: Text(
              isEdit ? 'Save' : 'Add',
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF6A8FB0)), // Light blue color
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: const Color(0xFF6A8FB0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
