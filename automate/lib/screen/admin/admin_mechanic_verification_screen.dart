import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMechanicVerificationContent extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const AdminMechanicVerificationContent({super.key, this.onSwitchTab});

  @override
  State<AdminMechanicVerificationContent> createState() =>
      _AdminMechanicVerificationContentState();
}

class _AdminMechanicVerificationContentState
    extends State<AdminMechanicVerificationContent> {
  
  List<Map<String, dynamic>> _pendingMechanics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingMechanics();
  }

  // Fetch pending verifications from Supabase
  Future<void> _fetchPendingMechanics() async {
    try {
      setState(() => _isLoading = true);

      // Get all pending verifications with mechanic details
      final data = await Supabase.instance.client
          .from('mechanic_verification')
          .select('''
            id,
            status,
            valid_id_image,
            created_at,
            mechanic_id,
            mechanic:mechanic_id (
              uid,
              first_name,
              last_name,
              email,
              phone_number
            )
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _pendingMechanics = (data as List<dynamic>? ?? []).map((item) {
            final mechanic = item['mechanic'] as Map<String, dynamic>? ?? {};
            return {
              'verification_id': item['id'],
              'mechanic_id': item['mechanic_id'],
              'name': '${mechanic['first_name'] ?? ''} ${mechanic['last_name'] ?? ''}'.trim(),
              'email': mechanic['email'] ?? 'No email',
              'contact': mechanic['phone_number'] ?? 'No contact',
              'valid_id_image': item['valid_id_image'] ?? '',
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching pending mechanics: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Approve mechanic
  Future<void> _approveMechanic(String mechanicId, int verificationId) async {
    try {
      // Update verification status to approved
      await Supabase.instance.client
          .from('mechanic_verification')
          .update({'status': 'approved'})
          .eq('id', verificationId);

      // Update mechanic verified status to true
      await Supabase.instance.client
          .from('mechanic')
          .update({'verified': true})
          .eq('uid', mechanicId);

      _removeCard(verificationId, 'approved');
    } catch (e) {
      debugPrint("Error approving mechanic: $e");
      _showErrorSnackBar('Failed to approve mechanic');
    }
  }

  // Reject mechanic
  Future<void> _rejectMechanic(String mechanicId, int verificationId) async {
    try {
      // Update verification status to rejected
      await Supabase.instance.client
          .from('mechanic_verification')
          .update({'status': 'rejected'})
          .eq('id', verificationId);

      // Keep mechanic verified as false (no change needed)
      
      _removeCard(verificationId, 'rejected');
    } catch (e) {
      debugPrint("Error rejecting mechanic: $e");
      _showErrorSnackBar('Failed to reject mechanic');
    }
  }

  void _removeCard(int verificationId, String action) {
    setState(() {
      _pendingMechanics.removeWhere((m) => m['verification_id'] == verificationId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'approved'
                ? 'Mechanic approved successfully.'
                : 'Mechanic rejected.',
          ),
          backgroundColor: action == 'approved'
              ? const Color(0xFF009227)
              : const Color(0xFFBF2D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
void _showImageDialog(String imageUrl) {
  if (imageUrl.isEmpty) {
    _showErrorSnackBar('No image available');
    return;
  }

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF164D83)),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.white,
                    child: const Center(
                      child: Text('Failed to load image', style: TextStyle(color: Colors.red)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Sidebar layers (keep as is)
            Positioned(
              left: -28,
              top: 87,
              child: Container(
                width: 258,
                height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x4C164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),
            Positioned(
              left: -18,
              top: 87,
              child: Container(
                width: 176,
                height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0x7F164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),
            Positioned(
              left: -18,
              top: 87,
              child: Container(
                width: 103,
                height: MediaQuery.of(context).size.height,
                decoration: ShapeDecoration(
                  color: const Color(0xFF164D83),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                // Header (keep as is)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: ShapeDecoration(
                          image: const DecorationImage(
                            image: NetworkImage("https://placehold.co/98x98"),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mechanic Verification',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${_pendingMechanics.length} Pending',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF19456B), size: 28),
                        onPressed: _fetchPendingMechanics,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Cards list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF164D83)))
                      : _pendingMechanics.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(36, 0, 36, 24),
                              itemCount: _pendingMechanics.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final mechanic = _pendingMechanics[index];
                                return _MechanicCard(
                                  mechanic: mechanic,
                                  onViewCertification: () => _showImageDialog(
                                    mechanic['valid_id_image'] ?? '',
                                  ),
                                  onApprove: () => _approveMechanic(
                                    mechanic['mechanic_id'] as String,
                                    mechanic['verification_id'] as int,
                                  ),
                                  onReject: () => _rejectMechanic(
                                    mechanic['mechanic_id'] as String,
                                    mechanic['verification_id'] as int,
                                  ),
                                );
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No pending mechanics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All mechanics have been reviewed.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ── Mechanic card ────────────────────────────────────────────────────────────

class _MechanicCard extends StatelessWidget {
  final Map<String, dynamic> mechanic;
  final VoidCallback onViewCertification;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _MechanicCard({
    required this.mechanic,
    required this.onViewCertification,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name:',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            mechanic['name'] ?? '—',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Email:',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            mechanic['email'] ?? '—',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact:',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            mechanic['contact'] ?? '—',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'CERTIFICATION:',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: onViewCertification,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 8),
                decoration: ShapeDecoration(
                  color: const Color(0xFF203C63),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black.withOpacity(0.50), width: 1),
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
                child: const Text(
                  'See Certification Here',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Waiting for approval',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFBF2D2D), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(49)),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Color(0xFFBF2D2D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009227),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF22C55E)),
                      borderRadius: BorderRadius.circular(49),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}