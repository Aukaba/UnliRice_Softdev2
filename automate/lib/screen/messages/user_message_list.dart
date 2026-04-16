import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_chat_session.dart';
import '../../Logic/chat/chat_logic.dart';
import 'package:intl/intl.dart';

class UserMessageListScreen extends StatefulWidget {
  const UserMessageListScreen({super.key});

  @override
  State<UserMessageListScreen> createState() => _UserMessageListScreenState();
}

class _UserMessageListScreenState extends State<UserMessageListScreen> {
  late Stream<List<Map<String, dynamic>>> _partnersStream;

  @override
  void initState() {
    super.initState();
    _partnersStream = ChatLogic().getActivePartners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB), // Light gray background
      body: Stack(
        children: [
          // Background Gold Circles matching Figma precisely
          Positioned(
            top: 40,
            right: -80,
            width: 350,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6C15B).withOpacity(0.9), // Deep gold color
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -150,
            width: 450,
            height: 450,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6C15B).withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Messages Title)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "Messages",
                        style: GoogleFonts.inriaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // MechMate Top Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserChatSessionScreen(mechanicName: "MechMate"),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFBF00), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Robot Avatar with badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade50,
                                  border: Border.all(color: Colors.blue.shade200, width: 2),
                                ),
                                child: const Icon(Icons.smart_toy, color: Colors.blue, size: 35),
                              ),
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6C15B), // Gold badge
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: Text(
                                    "3",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "MechMate ✨",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Always Online",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "How can i Assist you today?",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mechanic List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _partnersStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                            return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                          }
                          if (snapshot.hasError && snapshot.data == null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.wifi_off, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Could not load conversations.",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _partnersStream = ChatLogic().getActivePartners();
                                        });
                                      },
                                      child: Text(
                                        'Retry',
                                        style: GoogleFonts.montserrat(color: const Color(0xFF2B5A82)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final partners = snapshot.data ?? [];
                          
                          if (partners.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  "No messages yet.",
                                  style: GoogleFonts.montserrat(color: Colors.black54),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: partners.length,
                            itemBuilder: (context, index) {
                              final p = partners[index];
                              final rawTime = p['time'];
                              String timeStr = "";
                              if (rawTime != null) {
                                final parsed = DateTime.parse(rawTime).toLocal();
                                timeStr = DateFormat('MMM d, h:mm a').format(parsed);
                              }

                              return _buildMechanicCard(
                                name: p['name'],
                                lastMessage: p['last_message'],
                                time: timeStr,
                                hasNewMessage: p['is_unread'] == true,
                                isLast: index == partners.length - 1,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserChatSessionScreen(
                                        mechanicName: p['name'],
                                        partnerId: p['partner_id'],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ),
                  ),
                ),
                // Giving some extra space at bottom matching UI
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicCard({
    required String name,
    String? vehicle,
    required String lastMessage,
    required String time,
    required bool hasNewMessage,
    int? badgeCount,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: isLast ? null : Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Blue-Grey Circle Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A8EAE), // Flat blue-grey color matching mockup
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(3, 3), // Bottom-right drop shadow
                      ),
                    ],
                  ),
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6C15B),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      if (vehicle != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          vehicle,
                          style: GoogleFonts.montserrat(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Small purely yellow indicator dot on right side if has new message without count
                      if (hasNewMessage && badgeCount == null)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6C15B),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: hasNewMessage ? FontWeight.w700 : FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
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
