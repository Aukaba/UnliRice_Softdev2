import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  // Sunday-first order matching the design
  static const List<String> _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = now;
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  /// Build all cells for the calendar grid (Sunday-first).
  /// Each entry: { 'date': DateTime?, 'current': bool }
  List<Map<String, dynamic>> _buildCalendarDays() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstWeekday = _focusedMonth.weekday; // 1=Mon … 7=Sun
    // Convert to Sunday-first index: Sun=0, Mon=1 … Sat=6
    final leadingBlanks = firstWeekday % 7; // Mon→1, Tue→2 … Sun→0

    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final daysInPrevMonth = DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final List<Map<String, dynamic>> cells = [];

    // Leading days from previous month
    for (int i = leadingBlanks - 1; i >= 0; i--) {
      cells.add({
        'date': DateTime(prevMonth.year, prevMonth.month, daysInPrevMonth - i),
        'current': false,
      });
    }

    // Current month days
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add({
        'date': DateTime(_focusedMonth.year, _focusedMonth.month, d),
        'current': true,
      });
    }

    // Trailing days to fill the last row
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    int trailing = 1;
    while (cells.length % 7 != 0) {
      cells.add({
        'date': DateTime(nextMonth.year, nextMonth.month, trailing++),
        'current': false,
      });
    }

    return cells;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCalendarDays();
    // Split into rows of 7
    final rows = <List<Map<String, dynamic>>>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Month navigation header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev button — gold rounded square
              GestureDetector(
                onTap: _prevMonth,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFBF00),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                ),
              ),
              // Month & Year title
              Text(
                '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF19456B),
                ),
              ),
              // Next button — gold rounded square
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFBF00),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Day labels ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // ── Date rows ──
          for (final row in rows) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((cell) {
                final DateTime date = cell['date'] as DateTime;
                final bool isCurrent = cell['current'] as bool;
                final bool selected = _isSelected(date);
                final bool today = _isToday(date);

                return Expanded(
                  child: GestureDetector(
                    onTap: isCurrent
                        ? () => setState(() => _selectedDate = date)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? const Color(0xFF19456B)
                            : today
                                ? const Color(0xFFFFBF00).withOpacity(0.2)
                                : Colors.transparent,
                        border: today && !selected
                            ? Border.all(color: const Color(0xFFFFBF00), width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: selected || today
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : !isCurrent
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
