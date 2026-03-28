import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              'July',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _DayLabel('Mo'),
              _DayLabel('Tu'),
              _DayLabel('We'),
              _DayLabel('Th'),
              _DayLabel('Fr'),
              _DayLabel('Sa'),
              _DayLabel('Su'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _DateItem('8', isBold: true),
              _DateItem('9', isBold: true),
              _DateItem('10', isBold: true),
              _DateItem('11', isBold: true),
              _DateItem('12', isActive: true),
              _DateItem('13', isLight: true),
              _DateItem('14', isLight: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _DateItem('15'),
              _DateItem('16'),
              _DateItem('17'),
              _DateItem('18'),
              _DateItem('19'),
              _DateItem('20', isLight: true),
              _DateItem('21', isLight: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  final String date;
  final bool isBold;
  final bool isActive;
  final bool isLight;

  const _DateItem(
    this.date, {
    this.isBold = false,
    this.isActive = false,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF19456B) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        date,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: isBold
              ? FontWeight.w700
              : isActive
                  ? FontWeight.w600
                  : FontWeight.w500,
          color: isActive
              ? Colors.white
              : isLight
                  ? Colors.grey.shade400
                  : Colors.black87,
        ),
      ),
    );
  }
}
