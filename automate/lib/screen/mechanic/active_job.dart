import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homescreen.dart';
import 'jobs.dart';
import 'schedule.dart';
import '../messages/user_message_list.dart';
import 'profile.dart';

class MechanicActiveJobScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const MechanicActiveJobScreen({super.key, this.jobData});

  @override
  State<MechanicActiveJobScreen> createState() => _MechanicActiveJobScreenState();
}

class _MechanicActiveJobScreenState extends State<MechanicActiveJobScreen> {
  // Helpers to safely pull strings from jobData
  String _field(String key, String fallback) =>
      (widget.jobData?[key]?.toString().isNotEmpty == true)
          ? widget.jobData![key].toString()
          : fallback;

  @override
  Widget build(BuildContext context) {
    final clientName   = widget.jobData?['user_name']  as String? ?? 'Client';
    final vehicle      = _field('vehicle', 'Unknown Vehicle');
    final plate        = _field('plate_number', 'N/A');
    final phone        = _field('phone', 'N/A');
    final location     = _field('pickup_location', 'Unknown Location');
    final issue        = _field('issue_description', 'No description provided.');
    final title        = _field('title', 'Emergency Request');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: Stack(
        children: [
          // ── Map Background Placeholder ──
          Positioned.fill(
            child: Container(color: const Color(0xFFD9E2EC)),
          ),

          // ── Red Top Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFE51D1D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.black, size: 16),
                        const SizedBox(width: 4),
                        Text('Back',
                            style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.car_crash, color: Colors.black, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Sheet Content ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, -6))
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 20, top: 10),
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
                            child: Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 18, color: Color(0xFFE51D1D)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(location,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inriaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 10),
                          Row(children: [
                            const Icon(Icons.directions_car_outlined,
                                size: 18, color: Colors.black87),
                            const SizedBox(width: 6),
                            Text('Distance unavailable',
                                style: GoogleFonts.inriaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Client Information
                      Text('Client Information',
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black)),
                      const SizedBox(height: 14),
                      _InfoRow(label: 'Name', value: clientName),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Vehicle', value: vehicle),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Plate', value: plate),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Phone', value: phone),
                      const SizedBox(height: 28),

                      // Emergency Issue
                      Text('Emergency Issue',
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black)),
                      const SizedBox(height: 10),
                      Text(issue,
                          style: GoogleFonts.inriaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.4)),
                      const SizedBox(height: 28),

                      // Diagnosis button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB703),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size.fromHeight(52),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.medical_information_outlined,
                            color: Colors.white, size: 20),
                        label: Text('Diagnosis',
                            style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _DiagnosisDialog(jobData: widget.jobData),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Chat + Call buttons
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CC32F),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white,
                                size: 18),
                            label: Text('Chat $clientName',
                                style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening chat with $clientName')));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7A00),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.phone_outlined,
                                color: Colors.white, size: 18),
                            label: Text('Call $clientName',
                                style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling $clientName...')));
                            },
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 0,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicHomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicJobsScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const MechanicScheduleScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const UserMessageListScreen()));
          } else if (index == 4) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const MechanicProfileScreen()));
          }
        },
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
        Text(label,
            style: GoogleFonts.inriaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black45)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
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

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final fallbackItems = [
      {'id': 'f1', 'category': 'Fluids', 'item_name': 'Engine Oil (Fully Synthetic)', 'price': 550},
      {'id': 'f2', 'category': 'Fluids', 'item_name': 'Gear Oil (Scooter)', 'price': 150},
      {'id': 'f3', 'category': 'Fluids', 'item_name': 'Coolant Flush (1L)', 'price': 350},
      {'id': 'f4', 'category': 'Fluids', 'item_name': 'Brake Fluid Top-up/Bleed', 'price': 250},
      {'id': 'fl1', 'category': 'Filters', 'item_name': 'Air Filter (Standard)', 'price': 450},
      {'id': 'fl2', 'category': 'Filters', 'item_name': 'Oil Filter (Cartridge/Spin-on)', 'price': 400},
      {'id': 'fl3', 'category': 'Filters', 'item_name': 'Cabin/AC Filter', 'price': 600},
      {'id': 'fl4', 'category': 'Filters', 'item_name': 'Fuel Filter (External type)', 'price': 800},
      {'id': 'ig1', 'category': 'Ignition/Elec.', 'item_name': 'Spark Plug (Standard)', 'price': 180},
      {'id': 'ig2', 'category': 'Ignition/Elec.', 'item_name': 'Battery (Maintenance Free)', 'price': 2800},
      {'id': 'ig3', 'category': 'Ignition/Elec.', 'item_name': 'Fuse Replacement (Set)', 'price': 50},
      {'id': 'ig4', 'category': 'Ignition/Elec.', 'item_name': 'Headlight/Signal Bulb', 'price': 250},
      {'id': 'br1', 'category': 'Braking', 'item_name': 'Brake Pads (Front Set)', 'price': 650},
      {'id': 'br2', 'category': 'Braking', 'item_name': 'Brake Shoes (Rear)', 'price': 550},
      {'id': 'dr1', 'category': 'Drivetrain', 'item_name': 'Chain Clean & Lube', 'price': 0},
      {'id': 'dr2', 'category': 'Drivetrain', 'item_name': 'CVT Belt Replacement', 'price': 1200},
      {'id': 'wt1', 'category': 'Wear & Tear', 'item_name': 'Wiper Blades (Pair)', 'price': 750},
      {'id': 'wt2', 'category': 'Wear & Tear', 'item_name': 'Tire Repair (Plug/Vulcanize)', 'price': 50},
    ];

    try {
      final res = await _supabase.from('diagnosis_items').select().order('category');
      if (mounted) {
        setState(() {
          _items = (res as List).isNotEmpty ? List<Map<String, dynamic>>.from(res) : fallbackItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = fallbackItems;
          _isLoading = false;
        });
        debugPrint('DB error fetching diagnosis items, using fallback: $e');
      }
    }
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one item.')));
      return;
    }

    final jobMap = widget.jobData?['jobs'] as Map<String, dynamic>?;
    final jobId = widget.jobData?['id']?.toString() ?? 
                  widget.jobData?['job_id']?.toString() ?? 
                  jobMap?['id']?.toString();
                  
    final mechanicId = widget.jobData?['mechanic_id']?.toString() ?? 
                       jobMap?['mechanic_id']?.toString() ?? 
                       _supabase.auth.currentUser?.id;

    if (jobId == null || mechanicId == null) {
      final missingFields = [
        if (jobId == null) 'job_id',
        if (mechanicId == null) 'mechanic_id'
      ].join(' and ');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot save diagnosis: Missing $missingFields.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Insert main diagnosis record
      final diagnosisRes = await _supabase.from('job_diagnosis').insert({
        'job_id': jobId,
        'mechanic_id': mechanicId,
        'total_bill': _totalBill,
        'diagnosis_fee': 200.0,
      }).select().single();

      final diagnosisId = diagnosisRes['id'];

      // 2. Insert selected items
      final selectedItemsData = _items.where((item) => _selectedItemIds.contains(item['id'].toString())).map((item) {
        return {
          'job_diagnosis_id': diagnosisId,
          'item_id': item['id'].toString(),
          'item_name': item['item_name'].toString(),
          'price': double.tryParse(item['price'].toString()) ?? 0.0,
        };
      }).toList();

      await _supabase.from('job_diagnosis_items').insert(selectedItemsData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagnosis saved successfully.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save diagnosis: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
      title: Text('Diagnosis & Bill', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty 
                ? Text('No diagnosis items found. Please ask the admin to run the SQL script to insert items.', style: GoogleFonts.inriaSans())
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
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(entry.key, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black54)),
                                ),
                                ...entry.value.map((item) {
                                  final id = item['id'].toString();
                                  final price = double.tryParse(item['price'].toString()) ?? 0.0;
                                  return CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    title: Text(item['item_name']?.toString() ?? 'Unknown', style: GoogleFonts.inriaSans(fontSize: 14)),
                                    subtitle: Text('₱${price.toStringAsFixed(2)}', style: GoogleFonts.inriaSans(color: const Color(0xFF4CC32F), fontWeight: FontWeight.bold)),
                                    value: _selectedItemIds.contains(id),
                                    onChanged: _isSaving ? null : (val) => _toggleItem(item, val),
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
                                Text('Diagnosis Fee', style: GoogleFonts.inriaSans()),
                                Text('₱200.00', style: GoogleFonts.inriaSans(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Bill', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('₱${_totalBill.toStringAsFixed(2)}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFFE51D1D))),
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
          child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.black54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CC32F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSaving ? null : _saveDiagnosis,
          child: _isSaving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Confirm', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}


// ── Bottom nav ──────────────────────────────────────────────────────────────

class _MechanicBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const _MechanicBottomNavigationBar(
      {required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => onItemTapped(0)),
            _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Jobs',
                active: currentIndex == 1,
                onTap: () => onItemTapped(1)),
            _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Schedule',
                active: currentIndex == 2,
                onTap: () => onItemTapped(2)),
            _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                active: currentIndex == 3,
                onTap: () => onItemTapped(3)),
            _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                active: currentIndex == 4,
                onTap: () => onItemTapped(4)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      this.active = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFFFB703) : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? const Color(0x33FFB703) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.inriaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}
