import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  final List<_DaySchedule> _schedule = [
    _DaySchedule(day: 'Monday', isEnabled: true, start: const TimeOfDay(hour: 8, minute: 0), end: const TimeOfDay(hour: 17, minute: 0)),
    _DaySchedule(day: 'Tuesday', isEnabled: true, start: const TimeOfDay(hour: 8, minute: 0), end: const TimeOfDay(hour: 17, minute: 0)),
    _DaySchedule(day: 'Wednesday', isEnabled: true, start: const TimeOfDay(hour: 8, minute: 0), end: const TimeOfDay(hour: 17, minute: 0)),
    _DaySchedule(day: 'Thursday', isEnabled: true, start: const TimeOfDay(hour: 8, minute: 0), end: const TimeOfDay(hour: 17, minute: 0)),
    _DaySchedule(day: 'Friday', isEnabled: true, start: const TimeOfDay(hour: 8, minute: 0), end: const TimeOfDay(hour: 17, minute: 0)),
    _DaySchedule(day: 'Saturday', isEnabled: true, start: const TimeOfDay(hour: 9, minute: 0), end: const TimeOfDay(hour: 14, minute: 0)),
    _DaySchedule(day: 'Sunday', isEnabled: false, start: const TimeOfDay(hour: 9, minute: 0), end: const TimeOfDay(hour: 14, minute: 0)),
  ];

  bool _saved = false;

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final current = isStart ? _schedule[index].start : _schedule[index].end;
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFB703),
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _schedule[index].start = picked;
        } else {
          _schedule[index].end = picked;
        }
        _saved = false;
      });
    }
  }

  void _save() {
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Schedule saved!',
          style: GoogleFonts.inriaSans(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121212),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabledDays = _schedule.where((d) => d.isEnabled).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Decorative amber blobs ──
            Positioned(
              right: -60,
              top: 180,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: 200,
              child: Container(
                width: 260,
                height: 260,
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
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB703),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFFFFB703),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Working Hours',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '$enabledDays days active this week',
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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Info card ──
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: Color(0xFFFFB703), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Toggle days on/off and tap the time to change your hours.',
                                  style: GoogleFonts.inriaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Weekly Schedule',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Day rows ──
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _schedule.asMap().entries.map((entry) {
                              final i = entry.key;
                              final day = entry.value;
                              final isLast = i == _schedule.length - 1;
                              return Column(
                                children: [
                                  _DayRow(
                                    schedule: day,
                                    formatTime: _formatTime,
                                    onToggle: (v) => setState(() {
                                      day.isEnabled = v;
                                      _saved = false;
                                    }),
                                    onStartTap: () => _pickTime(i, true),
                                    onEndTap: () => _pickTime(i, false),
                                    isFirst: i == 0,
                                    isLast: isLast,
                                  ),
                                  if (!isLast)
                                    Container(
                                      margin: const EdgeInsets.only(left: 16),
                                      height: 1,
                                      color: const Color(0xFFF0F0F0),
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Save button pinned at bottom ──
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: _save,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _saved
                        ? const Color(0xFF2F8A48)
                        : const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _saved
                            ? Icons.check_circle_outline_rounded
                            : Icons.save_outlined,
                        color: _saved ? Colors.white : const Color(0xFFFFB703),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _saved ? 'Schedule Saved' : 'Save Schedule',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySchedule {
  final String day;
  bool isEnabled;
  TimeOfDay start;
  TimeOfDay end;

  _DaySchedule({
    required this.day,
    required this.isEnabled,
    required this.start,
    required this.end,
  });
}

class _DayRow extends StatelessWidget {
  final _DaySchedule schedule;
  final String Function(TimeOfDay) formatTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final bool isFirst;
  final bool isLast;

  const _DayRow({
    required this.schedule,
    required this.formatTime,
    required this.onToggle,
    required this.onStartTap,
    required this.onEndTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(28) : Radius.zero,
          bottom: isLast ? const Radius.circular(28) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.day,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: schedule.isEnabled ? Colors.black87 : Colors.black26,
                  ),
                ),
              ),
              Switch(
                value: schedule.isEnabled,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFFFFB703),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.black12,
              ),
            ],
          ),
          if (schedule.isEnabled) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onStartTap,
                    child: _TimeChip(
                        label: 'Start', time: formatTime(schedule.start)),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.black26),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onEndTap,
                    child: _TimeChip(
                        label: 'End', time: formatTime(schedule.end)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;

  const _TimeChip({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inriaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: GoogleFonts.montserrat(
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