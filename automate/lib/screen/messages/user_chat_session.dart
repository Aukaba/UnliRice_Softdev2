import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UserChatSessionScreen extends StatefulWidget {
  final String mechanicName;

  const UserChatSessionScreen({super.key, required this.mechanicName});

  @override
  State<UserChatSessionScreen> createState() => _UserChatSessionScreenState();
}

class _UserChatSessionScreenState extends State<UserChatSessionScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  
  // Store messages dynamically instead of hardcoded
  List<ChatMessage> _messages = [];
  
  // Ollama configuration
  final String ollamaUrl = "https://supposedly-abdicative-ben.ngrok-free.dev/api/chat"; // YOUR IP HERE
  final String modelName = "llama3.2-vision";

  bool get _isMechMate => widget.mechanicName == "MechMate";

  @override
  void initState() {
    super.initState();
    // Initialize with welcome message if it's MechMate
    if (_isMechMate) {
      _messages.add(ChatMessage(
        message: "Hello! I'm MechMate, your AI assistant. How can I help with your vehicle today?",
        time: _getCurrentTime(),
        isMe: false,
      ));
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
  }

  /// Send message to Ollama AI
  Future<void> _sendToOllama({String? text, String? imageBase64}) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ollamaUrl),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "model": modelName,
          "messages": [
            {
              "role": "user",
              "content": text ?? "Look at this vehicle part. What visible failures or issues are present? List 3 possibilities.",
              if (imageBase64 != null) "images": [imageBase64]
            }
          ],
          "stream": false
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessage = data['message']['content'];
        
        setState(() {
          _messages.add(ChatMessage(
            message: botMessage,
            time: _getCurrentTime(),
            isMe: false,
          ));
        });
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String error) {
    setState(() {
      _messages.add(ChatMessage(
        message: "❌ $error",
        time: _getCurrentTime(),
        isMe: false,
        isError: true,
      ));
    });
  }

  void _handleSendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    
    final text = _msgController.text;
    
    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        message: text,
        time: _getCurrentTime(),
        isMe: true,
      ));
    });
    
    _msgController.clear();
    
    // If it's MechMate, send to Ollama
    if (_isMechMate) {
      _sendToOllama(text: text);
    }
    // For human mechanics, you'd implement real-time messaging here
  }

  void _handleImageCapture() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 50,
    );

    if (photo != null) {
      setState(() {
        _messages.add(ChatMessage(
          message: "[Image sent for diagnosis]",
          time: _getCurrentTime(),
          isMe: true,
        ));
      });
      
      final bytes = await File(photo.path).readAsBytes();
      final base64String = base64Encode(bytes);
      
      if (_isMechMate) {
        _sendToOllama(imageBase64: base64String);
      }
    }
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(
                  message: msg.message,
                  time: msg.time,
                  isMe: msg.isMe,
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19456B)),
            ),

          // Input Bar - Now with camera option for MechMate
          _buildInputBar(),
        ],
      ),
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
            onTap: _isLoading ? null : _handleSendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey : const Color(0xFF19456B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
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