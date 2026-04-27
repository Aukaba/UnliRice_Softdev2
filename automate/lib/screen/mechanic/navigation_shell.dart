import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'homescreen.dart';
import 'jobs.dart';
import 'schedule.dart';
import 'profile.dart';
import '../messages/user_message_list.dart';

class MechanicNavigationShell extends StatefulWidget {
  const MechanicNavigationShell({super.key});

  @override
  State<MechanicNavigationShell> createState() =>
      _MechanicNavigationShellState();
}

class _MechanicNavigationShellState extends State<MechanicNavigationShell> {
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();

  void _onItemTapped(int index) {
    if (index == 0 && _currentIndex == 0) {
      // Pop back to root of the home tab if already on it
      _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Index 0: Home (with local navigator so sub-routes work)
          Navigator(
            key: _homeNavigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const MechanicHomeScreen(),
            ),
          ),
          // Index 1: Jobs
          const MechanicJobsScreen(),
          // Index 2: Schedule
          const MechanicScheduleScreen(),
          // Index 3: Chat/Messages
          const UserMessageListScreen(),
          // Index 4: Profile
          const MechanicProfileScreen(),
        ],
      ),
      bottomNavigationBar: _MechanicShellNavBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class _MechanicShellNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const _MechanicShellNavBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: currentIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _NavItem(
              icon: Icons.inventory_2_outlined,
              label: 'Jobs',
              active: currentIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            _NavItem(
              icon: Icons.calendar_month_outlined,
              label: 'Schedule',
              active: currentIndex == 2,
              onTap: () => onItemTapped(2),
            ),
            _NavItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              active: currentIndex == 3,
              onTap: () => onItemTapped(3),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              active: currentIndex == 4,
              onTap: () => onItemTapped(4),
            ),
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

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

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
          const SizedBox(height: 4),
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
