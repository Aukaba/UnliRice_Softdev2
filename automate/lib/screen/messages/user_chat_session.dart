import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Logic/chat/chat_logic.dart';
import 'package:intl/intl.dart';

class UserChatSessionScreen extends StatefulWidget {
  final String mechanicName;
  final String partnerId;

  const UserChatSessionScreen({
    super.key,
    required this.mechanicName,
    this.partnerId = '',
  });

  @override
  State<UserChatSessionScreen> createState() => _UserChatSessionScreenState();
}

class _UserChatSessionScreenState extends State<UserChatSessionScreen> {
  final TextEditingController _msgController = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _messagesStream;

  bool get _isMechMate => widget.mechanicName == "MechMate";

  @override
  void initState() {
    super.initState();
    _messagesStream = ChatLogic().getMessagesWith(widget.partnerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _isMechMate ? _buildMechMateHeader() : _buildMechanicHeader(),

          // Main Chat Body - Now dynamic
          Expanded(
            child: _isMechMate
                ? _buildDummyMessages()
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading messages"));
                      }
                      
                      final messages = snapshot.data ?? [];
                      final myId = Supabase.instance.client.auth.currentUser?.id;
                      
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg['sender_id'] == myId;
                          final rawTime = msg['created_at'];
                          
                          String timeStr = "";
                          if (rawTime != null) {
                            final parsed = DateTime.parse(rawTime).toLocal();
                            timeStr = DateFormat('jm').format(parsed);
                          }
                          
                          return _buildMessageBubble(
                            message: msg['content'] ?? '',
                            time: timeStr,
                            isMe: isMe,
                          );
                        },
                      );
                    },
                  ),
          ),

          // Input Bar - Now with camera option for MechMate
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildDummyMessages() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        _buildMessageBubble(
          message: "Hi! How can I assist you today?",
          time: "Now",
          isMe: false,
        ),
      ],
    );
  }

  Widget _buildDummyMessages() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        _buildMessageBubble(
          message: "Hi! How can I assist you today?",
          time: "Now",
          isMe: false,
        ),
      ],
    );
  }

  Widget _buildMechMateHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        left: 12,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFB3D9F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back, color: Colors.black87, size: 26),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: [
                Text(
                  "MechMate ",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  "✦",
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/images/robotttt.png', fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFBF00),
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
                "ADV 160 ROADSYNC",
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
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          // Camera button for MechMate
          if (_isMechMate)
            IconButton(
              onPressed: _isLoading ? null : _handleImageCapture,
              icon: Icon(Icons.camera_alt, color: _isLoading ? Colors.grey : const Color(0xFF19456B)),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _msgController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: _isMechMate ? "Ask MechMate anything..." : "Type a message....",
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final text = _msgController.text.trim();
              if (text.isEmpty || _isMechMate || widget.partnerId.isEmpty) return;
              
              _msgController.clear();
              try {
                await ChatLogic().sendMessage(widget.partnerId, text);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send: $e')),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF19456B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
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
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe && _isMechMate) ...[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/robotttt.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF19456B) : const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
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
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: isMe ? Colors.white60 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Message model class
class ChatMessage {
  final String message;
  final String time;
  final bool isMe;
  final bool isError;

  ChatMessage({
    required this.message,
    required this.time,
    required this.isMe,
    this.isError = false,
  });
}