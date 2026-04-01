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

  static const List<String> _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
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

  /// Returns the days to display in the grid.
  /// Each item: [day (int), isCurrentMonth (bool)]
  List<Map<String, dynamic>> _buildCalendarDays() {
    final firstDay = _focusedMonth;
    // weekday: 1=Mon, 7=Sun
    final startWeekday = firstDay.weekday; // 1-based, Mon=1
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final daysInPrevMonth = DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final List<Map<String, dynamic>> days = [];

    // Leading days from previous month
    for (int i = startWeekday - 1; i > 0; i--) {
      days.add({'day': daysInPrevMonth - i + 1, 'current': false, 'date': null});
    }

    // Current month days
    for (int d = 1; d <= daysInMonth; d++) {
      days.add({
        'day': d,
        'current': true,
        'date': DateTime(_focusedMonth.year, _focusedMonth.month, d),
      });
    }

    // Trailing days from next month to fill remaining cells (up to 6 rows max)
    int trailing = 1;
    while (days.length % 7 != 0) {
      days.add({'day': trailing++, 'current': false, 'date': null});
    }

    return days;
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime? date) {
    if (date == null) return false;
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final weeks = <List<Map<String, dynamic>>>[];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }
    // Only show first 2 rows to keep widget compact (matching the original design)
    final displayWeeks = weeks.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month navigation header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _prevMonth,
                  child: const Icon(Icons.chevron_left, size: 22, color: Colors.black54),
                ),
                Text(
                  '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: const Icon(Icons.chevron_right, size: 22, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _dayLabels
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          // Date rows
          for (final week in displayWeeks) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: week.map((item) {
                final DateTime? date = item['date'];
                final bool isCurrent = item['current'] as bool;
                final bool selected = _isSelected(date);
                final bool today = _isToday(date);

                return GestureDetector(
                  onTap: date == null
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? const Color(0xFF19456B)
                          : today
                              ? const Color(0xFFFFBF00).withOpacity(0.25)
                              : Colors.transparent,
                      border: today && !selected
                          ? Border.all(color: const Color(0xFFFFBF00), width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item['day']}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: selected || today ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : !isCurrent
                                ? Colors.grey.shade400
                                : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
