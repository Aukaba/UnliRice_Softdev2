import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'user_homescreen.dart';
import '../messages/user_message_list.dart';
import 'user_activity.dart';

class UserNavigationShell extends StatefulWidget {
  const UserNavigationShell({super.key});

  @override
  State<UserNavigationShell> createState() => _UserNavigationShellState();
}

class _UserNavigationShellState extends State<UserNavigationShell> {
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> _mapNavigatorKey = GlobalKey<NavigatorState>();

  void _onItemTapped(int index) {
    if (index == 0 && _currentIndex == 0) {
      // Pop to the top of the local Map navigator if tapping Map while already on it
      _mapNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Index 0: Map (with local navigation stack)
          Navigator(
            key: _mapNavigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const UserHomeScreen(),
              );
            },
          ),
          // Index 1: Activity
          const UserActivityScreen(),
          const UserMessageListScreen(),
          // Profile Placeholder
          Container(
            color: Colors.white,
            child: Center(
              child: Text(
                "Profile Page Placeholder",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: const Color(0xFF19456B), // Deep Blue specified in prompt
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600), // Updated to montserrat
          unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.location_on_outlined, size: 28),
              ),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.notifications_none, size: 28),
              ),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.chat_bubble_outline, size: 28),
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_outline, size: 28),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
