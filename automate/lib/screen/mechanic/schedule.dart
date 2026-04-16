import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart'; // adjust import paths as needed
import 'jobs.dart';
import 'profile.dart';
import '../messages/user_message_list.dart';
import '../../Logic/jobs/jobs_logic.dart';



// ─── Data model ───────────────────────────────────────────────────────────────

class _ScheduledJob {
  final String title;
  final String name;
  final String vehicle;
  final String description;
  final String location;
  final String time;
  final String price;
  final String tag; // 'TODAY', 'TOMORROW', 'MON 03·27-28', etc.
  final DateTime date;

  const _ScheduledJob({
    required this.title,
    required this.name,
    required this.vehicle,
    required this.description,
    required this.location,
    required this.time,
    required this.price,
    required this.tag,
    required this.date,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class MechanicScheduleScreen extends StatefulWidget {
  const MechanicScheduleScreen({super.key});

  @override
  State<MechanicScheduleScreen> createState() => _MechanicScheduleScreenState();
}

class _MechanicScheduleScreenState extends State<MechanicScheduleScreen> {
  DateTime _focusedMonth = DateTime.now();
  late DateTime _selectedDay;

  List<_ScheduledJob> _mapJobs(List<Map<String, dynamic>> rawJobs) {
    return rawJobs.map((j) {
      final date = DateTime.tryParse(j['scheduled_date'] ?? j['created_at']) ?? DateTime.now();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tagDate = DateTime(date.year, date.month, date.day);
      String tag;
      if (tagDate == today) {
        tag = 'TODAY';
      } else if (tagDate == today.add(const Duration(days: 1))) {
        tag = 'TOMORROW';
      } else {
        const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
        tag = '${days[date.weekday - 1]} ${date.month.toString().padLeft(2, '0')}·${date.day.toString().padLeft(2, '0')}';
      }
      
      return _ScheduledJob(
        title: j['title'] ?? 'Service Request',
        name: 'User',
        vehicle: j['vehicle'] ?? 'Vehicle',
        description: j['issue_description'] ?? 'No description',
        location: j['pickup_location'] ?? 'Unknown location',
        time: '${date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}',
        price: 'Pending Estimate', 
        tag: tag,
        date: date,
      );
    }).toList();
  }

  Set<String> _getDatesWithJobs(List<_ScheduledJob> jobs) =>
      jobs.map((j) => _dateKey(j.date)).toSet();

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  List<_ScheduledJob> _getJobsForSelectedDay(List<_ScheduledJob> jobs) =>
      jobs.where((j) => _dateKey(j.date) == _dateKey(_selectedDay)).toList();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _prevMonth() =>
      setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _nextMonth() =>
      setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  String _monthLabel() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  // Returns list of day cells: null = empty padding, int = day number
  List<int?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // Sunday = 0 offset
    final startOffset = firstDay.weekday % 7;
    final cells = <int?>[];
    for (var i = 0; i < startOffset; i++) {
       cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
       cells.add(d);
    }
    return cells;
  }

  String _selectedDayLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    if (sel == today) return 'Today\'s Schedule';
    if (sel == today.add(const Duration(days: 1))) return 'Tomorrow\'s Schedule';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[_selectedDay.weekday - 1];
    final monthName = months[_selectedDay.month - 1];
    return '$dayName, $monthName ${_selectedDay.day}';
  }

  @override
  Widget build(BuildContext context) {
    final calDays = _buildCalendarDays();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Decorative amber blobs ──
            Positioned(
              right: -70,
              top: 140,
              child: Container(
                width: 230,
                height: 230,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: 260,
              child: Container(
                width: 270,
                height: 270,
                decoration: const BoxDecoration(
                  color: Color(0x1FFFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -40,
              bottom: 80,
              child: Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // ── Content ──
            Column(
              children: [
                // ── Scrollable body ──
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: JobsLogic().getMechanicScheduledJobs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final allJobs = _mapJobs(snapshot.data ?? []);
                      final selectedDayJobs = _getJobsForSelectedDay(allJobs);
                      final datesWithJobSet = _getDatesWithJobs(allJobs);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Yellow header — now scrolls with content, no top gap
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB703),
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.calendar_month_rounded,
                                        color: Color(0xFFFFB703), size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Schedule',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.notifications_none,
                                        color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            // ── Calendar card ──
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Month nav
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: _prevMonth,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFB703),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.chevron_left_rounded,
                                              color: Colors.black, size: 22),
                                        ),
                                      ),
                                      Text(
                                        _monthLabel(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _nextMonth,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFB703),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.chevron_right_rounded,
                                              color: Colors.black, size: 22),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Day-of-week headers
                                  Row(
                                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                        .map((d) => Expanded(
                                              child: Center(
                                                child: Text(
                                                  d,
                                                  style: GoogleFonts.inriaSans(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black38,
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 8),

                                  // Day cells grid
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: calDays.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      childAspectRatio: 0.85,
                                      mainAxisSpacing: 4,
                                    ),
                                    itemBuilder: (context, index) {
                                      final day = calDays[index];
                                      if (day == null) return const SizedBox();
                                      final date = DateTime(
                                          _focusedMonth.year, _focusedMonth.month, day);
                                      final isSelected =
                                          _dateKey(date) == _dateKey(_selectedDay);
                                      final hasJob =
                                          datesWithJobSet.contains(_dateKey(date));
                                      final isToday = _dateKey(date) ==
                                          _dateKey(DateTime.now());

                                      return GestureDetector(
                                        onTap: () =>
                                            setState(() => _selectedDay = date),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AnimatedContainer(
                                              duration:
                                                  const Duration(milliseconds: 180),
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFFFFB703)
                                                    : isToday
                                                        ? const Color(0xFFFFF3CD)
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$day',
                                                  style: GoogleFonts.inriaSans(
                                                    fontSize: 14,
                                                    fontWeight: isSelected || isToday
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? Colors.black
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            AnimatedOpacity(
                                              opacity: hasJob ? 1.0 : 0.0,
                                              duration:
                                                  const Duration(milliseconds: 200),
                                              child: Container(
                                                width: 5,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.black54
                                                      : const Color(0xFFFFB703),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Selected day section ──
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _selectedDayLabel(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (selectedDayJobs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 28, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No jobs scheduled for this day',
                                      style: GoogleFonts.inriaSans(
                                        fontSize: 14,
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...selectedDayJobs.map((job) => Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                    child: _ScheduleJobCard(job: job),
                                  )),

                            const SizedBox(height: 24),

                            // ── All scheduled jobs ──
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'All Scheduled Jobs',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...allJobs.map((job) => Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: _ScheduleJobCard(job: job),
                                )),
                          ],
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 2,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MechanicHomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MechanicJobsScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserMessageListScreen()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MechanicProfileScreen()),
            );
          }
        },
      ),
    );
  }
}

// ─── Job card ─────────────────────────────────────────────────────────────────

class _ScheduleJobCard extends StatelessWidget {
  final _ScheduledJob job;
  const _ScheduleJobCard({required this.job});

  Color get _tagBg {
    if (job.tag == 'TODAY') return const Color(0xFFFFB703);
    if (job.tag == 'TOMORROW') return const Color(0xFFFFE5B4);
    return const Color(0xFFF0F0F0);
  }

  Color get _tagText {
    if (job.tag == 'TODAY') return Colors.black;
    if (job.tag == 'TOMORROW') return const Color(0xFF7A5000);
    return Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag column
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _tagBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  job.tag,
                  style: GoogleFonts.inriaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _tagText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Wrench icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.build_rounded,
                color: Color(0xFF121212), size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${job.name} • ${job.vehicle}',
                  style: GoogleFonts.inriaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inriaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.black38,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.black38),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        job.location,
                        style: GoogleFonts.inriaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black38,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: Colors.black38),
                        const SizedBox(width: 3),
                        Text(
                          job.time,
                          style: GoogleFonts.inriaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      job.price,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF121212),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom nav (shared pattern) ─────────────────────────────────────────────

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