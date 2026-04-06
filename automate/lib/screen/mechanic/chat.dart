import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';
import 'jobs.dart';
import 'schedule.dart';
import 'profile.dart';

class MechanicChatScreen extends StatelessWidget {
  const MechanicChatScreen({super.key});

  final List<_ChatThread> _threads = const [
    _ChatThread(
      name: 'Aaron Barnaija',
      vehicle: 'Yamaha MT-15',
      lastMessage: 'Ni sud ka maw??',
      timeAgo: '2 min ago',
      unreadCount: 3,
    ),
    _ChatThread(
      name: 'Rex Seadiño Jr.',
      vehicle: 'Toyota Vios',
      lastMessage: 'Are you on your way? My car is...',
      timeAgo: '9 min ago',
      unreadCount: 1,
    ),
    _ChatThread(
      name: 'Mambaling monkey',
      vehicle: 'Toyota Vios',
      lastMessage: 'Thanks! I\'ll wait for you at the...',
      timeAgo: '34 min ago',
      unreadCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalUnread =
        _threads.fold<int>(0, (sum, t) => sum + t.unreadCount);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Decorative amber blobs ──
            Positioned(
              left: -60,
              top: 180,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 80,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB703),
                    borderRadius: BorderRadius.circular(32),
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
                        child: const Icon(Icons.chat_bubble_outline_rounded,
                            color: Color(0xFFFFB703), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Messages',
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '$totalUnread unread',
                              style: GoogleFonts.inriaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
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
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDD2E44),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Thread list ──
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    itemCount: _threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) =>
                        _ChatCard(thread: _threads[index]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 3,
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
          } else if (index == 4) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicProfileScreen()));
          }
        },
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _ChatThread {
  final String name;
  final String vehicle;
  final String lastMessage;
  final String timeAgo;
  final int unreadCount;

  const _ChatThread({
    required this.name,
    required this.vehicle,
    required this.lastMessage,
    required this.timeAgo,
    required this.unreadCount,
  });
}

// ─── Chat card ────────────────────────────────────────────────────────────────

class _ChatCard extends StatelessWidget {
  final _ChatThread thread;
  const _ChatCard({required this.thread});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to individual chat screen
      },
      child: Container(
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
          children: [
            // Avatar with unread badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      size: 30, color: Colors.black54),
                ),
                if (thread.unreadCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB703),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${thread.unreadCount}',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Name / vehicle / preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        thread.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        thread.timeAgo,
                        style: GoogleFonts.inriaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    thread.vehicle,
                    style: GoogleFonts.inriaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inriaSans(
                      fontSize: 13,
                      fontWeight: thread.unreadCount > 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: thread.unreadCount > 0
                          ? Colors.black87
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom nav ───────────────────────────────────────────────────────────────

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