import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';
import 'jobs.dart';
import 'schedule.dart';
import '../messages/user_message_list.dart';
import 'profile.dart';
import 'active_job.dart';
import '../../Logic/jobs/jobs_logic.dart';

class MechanicCheckRequestScreen extends StatefulWidget {
  final bool isAccepted;
  final Map<String, dynamic>? jobData;

  const MechanicCheckRequestScreen({
    super.key,
    this.isAccepted = false,
    this.jobData,
  });

  @override
  State<MechanicCheckRequestScreen> createState() =>
      _MechanicCheckRequestScreenState();
}

class _MechanicCheckRequestScreenState
    extends State<MechanicCheckRequestScreen>
    with SingleTickerProviderStateMixin {
  static const double _collapsedHeight = 72.0;
  static const double _expandedHeight = 520.0;

  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  bool _isExpanded = false;
  double _dragStartDy = 0;
  double _dragStartHeight = 0;
  double _currentHeight = _collapsedHeight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _heightAnimation = Tween<double>(
      begin: _collapsedHeight,
      end: _expandedHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _heightAnimation.addListener(() {
      setState(() {
        _currentHeight = _heightAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _dragStartDy = details.globalPosition.dy;
    _dragStartHeight = _currentHeight;
    _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = _dragStartDy - details.globalPosition.dy;
    setState(() {
      _currentHeight = (_dragStartHeight + delta).clamp(
        _collapsedHeight,
        _expandedHeight,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= 0) {
      _snapTo(true);
    } else {
      _snapTo(false);
    }
  }

  void _snapTo(bool expand) {
    _isExpanded = expand;
    _heightAnimation = Tween<double>(
      begin: _currentHeight,
      end: expand ? _expandedHeight : _collapsedHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MechanicHomeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: SizedBox(
                  height: _currentHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 24,
                          offset: Offset(0, -6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      child: Column(
                        children: [
                          _DragHandleRow(isExpanded: _isExpanded),
                          Expanded(
                            child: Opacity(
                              opacity: ((_currentHeight - _collapsedHeight) /
                                      (_expandedHeight - _collapsedHeight))
                                  .clamp(0.0, 1.0),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const _LocationDistanceRow(),
                                    const SizedBox(height: 20),
                                    const _ClientInformationCard(),
                                    const SizedBox(height: 16),
                                    const _IssueCard(),
                                    const SizedBox(height: 24),
                                    _AcceptJobButton(
                                      isAccepted: widget.isAccepted,
                                      jobData: widget.jobData,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 0,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MechanicJobsScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MechanicScheduleScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserMessageListScreen(),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MechanicProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}

class _DragHandleRow extends StatelessWidget {
  final bool isExpanded;
  const _DragHandleRow({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: isExpanded ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.keyboard_arrow_up_rounded,
                    size: 18, color: Colors.black38),
                const SizedBox(width: 4),
                Text(
                  'Swipe up to see request',
                  style: GoogleFonts.inriaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDistanceRow extends StatelessWidget {
  const _LocationDistanceRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Color(0xFFDD2E44)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tisa, Cebu City',
                  style: GoogleFonts.inriaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              'Distance unavailable',
              style: GoogleFonts.inriaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClientInformationCard extends StatelessWidget {
  const _ClientInformationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Client Information',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Name', value: 'Aaron Barnaija'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Vehicle', value: 'Toyota Vios'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Plate', value: 'GLE 704'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Phone', value: '+63 912 345 6789'),
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
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inriaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inriaSans(
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

class _IssueCard extends StatelessWidget {
  const _IssueCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Issue',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Engine won\u2019t start curh, am stuck in the middle of the road',
            style: GoogleFonts.inriaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptJobButton extends StatelessWidget {
  final bool isAccepted;
  final Map<String, dynamic>? jobData;

  const _AcceptJobButton({
    this.isAccepted = false,
    this.jobData,
  });

  void _onPressed(BuildContext context) {
    if (isAccepted) {
      // Validate day
      final rawDate = jobData?['scheduled_date'] ?? jobData?['created_at'];
      DateTime jobDate = DateTime.now();
      if (rawDate != null) {
        jobDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      }
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final jobDay = DateTime(jobDate.year, jobDate.month, jobDate.day);
      
      if (jobDay != today) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            content: Text('This job is not scheduled for today. You cannot start it yet.',
                style: GoogleFonts.inriaSans()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('OK', style: GoogleFonts.montserrat()),
              ),
            ],
          ),
        );
        return;
      }
      
      // Navigate to active job screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MechanicActiveJobScreen()),
      );
    } else {
      // Logic for accepting a job here
      if (jobData != null && jobData!['id'] != null) {
        JobsLogic().acceptJob(jobData!['id'].toString()).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job accepted!')));
          Navigator.pop(context);
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invalid job data.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _onPressed(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CC32F),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
      ),
      child: Text(
        isAccepted ? 'Start Job' : 'Accept Job',
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MechanicBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const _MechanicBottomNavigationBar({required this.currentIndex, required this.onItemTapped});

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
            _NavItem(icon: Icons.home_outlined, label: 'Home', active: currentIndex == 0, onTap: () => onItemTapped(0)),
            _NavItem(icon: Icons.inventory_2_outlined, label: 'Jobs', active: currentIndex == 1, onTap: () => onItemTapped(1)),
            _NavItem(icon: Icons.calendar_month_outlined, label: 'Schedule', active: currentIndex == 2, onTap: () => onItemTapped(2)),
            _NavItem(icon: Icons.chat_bubble_outline, label: 'Chat', active: currentIndex == 3, onTap: () => onItemTapped(3)),
            _NavItem(icon: Icons.person_outline, label: 'Profile', active: currentIndex == 4, onTap: () => onItemTapped(4)),
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

  const _NavItem({required this.icon, required this.label, this.active = false, required this.onTap});

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
              color: active ? const Color(0xFFFFF8E1) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inriaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}