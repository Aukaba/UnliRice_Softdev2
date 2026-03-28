import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserChatSessionScreen extends StatefulWidget {
  final String mechanicName;

  const UserChatSessionScreen({
    super.key,
    required this.mechanicName,
  });

  @override
  State<UserChatSessionScreen> createState() => _UserChatSessionScreenState();
}

class _UserChatSessionScreenState extends State<UserChatSessionScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section (Gold/Gray)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFBF00), // Gold Header
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mechanicName,
                      style: GoogleFonts.inriaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "ADV 160 ROADSYNC", // Mock vehicle subtitle for mechanic per mock
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Body Chat Output
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  _buildMessageBubble(
                    message: "Hi! I'm on my way to you",
                    time: "10:30 AM",
                    isMe: false, // mechanic
                  ),
                  _buildMessageBubble(
                    message: "Great! What's the estimated time?",
                    time: "10:32 AM",
                    isMe: true, // user
                  ),
                  _buildMessageBubble(
                    message: "I'll be there in 5 minutes",
                    time: "10:35 AM",
                    isMe: false, // mechanic
                  ),
                ],
              ),
            ),
          ),

          // Input Field Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1), // Light layout for chat input
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: "Type a message....",
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF19456B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_outlined, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String time,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF19456B) : const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isMe ? Colors.white70 : Colors.black54,
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
