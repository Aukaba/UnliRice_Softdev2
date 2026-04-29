import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Logic/ollama_integrations/model/chat_message.dart';
import '../../Logic/ollama_integrations/services/ollama_service.dart';
import '../../widgets/chatbot/chat_bubble.dart';
import '../../widgets/chatbot/chat_input_bar.dart';
import '../../widgets/chatbot/image_preview.dart';

class MechMateChatScreen extends StatefulWidget {
  const MechMateChatScreen({super.key});

  @override
  State<MechMateChatScreen> createState() => _MechMateChatScreenState();
}

class _MechMateChatScreenState extends State<MechMateChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<ChatMessage> _messages = [];

  late final OllamaService _ollamaService;

  bool _isLoading = false;

  List<ChatMessage> _messages = [];

  final String ollamaUrl =
      "https://supposedly-abdicative-ben.ngrok-free.dev/api/chat";
  final String modelName = "llama3.2-vision";

  @override
  void initState() {
    super.initState();

    // Initialize Ollama service
    _ollamaService = OllamaService(
      ollamaUrl: "https://supposedly-abdicative-ben.ngrok-free.dev/api/chat",
      modelName: "llama3.2-vision",
    );

    // Add welcome message
    const welcomeMessage =
        "Hello! I'm MechMate, your AI assistant. I can analyze vehicle photos. Take a picture or describe your issue!";

    _messages.add(
      ChatMessage(
        message:
            "Hello! I'm MechMate, your AI assistant. How can I help with your vehicle today?",
        time: _getCurrentTime(),
        isMe: false,
      ),
    );

    _ollamaService.addWelcomeMessage(welcomeMessage);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $ampm";
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _sendMessageWithImage() async {
    if (_selectedImage == null) return;

    final text = _msgController.text.trim();
    final hasText = text.isNotEmpty;
    final userMessageText = hasText ? text : "[Image sent for analysis]";

    // Add user message with image to UI
    setState(() {
      _messages.add(
        ChatMessage(
          message: userMessageText,
          time: _getCurrentTime(),
          isMe: true,
          imageFile: _selectedImage,
        ),
      );
      _isLoading = true;
    });

    _msgController.clear();

    // Prepare image
    final bytes = await _selectedImage!.readAsBytes();
    final base64String = base64Encode(bytes);

    // Prepare prompt
    final prompt = hasText
        ? text
        : "Look at this vehicle image. What visible issues or potential problems can you identify? List 3 possibilities.";

    // Clear selected image
    setState(() {
      _selectedImage = null;
    });

    // Send to AI
    final botResponse = await _ollamaService.sendMessage(
      text: prompt,
      imageBase64: base64String,
    );

    // Add bot response to UI
    setState(() {
      _messages.add(
        ChatMessage(message: botResponse, time: _getCurrentTime(), isMe: false),
      );
      _isLoading = false;
    });
  }

  Future<void> _sendTextMessage() async {
    if (_msgController.text.trim().isEmpty) return;

    final text = _msgController.text.trim();

    // Add user message to UI
    setState(() {
      _messages.add(
        ChatMessage(message: text, time: _getCurrentTime(), isMe: true),
      );
      _isLoading = true;
    });

    _msgController.clear();
    _sendToOllama(text: text);
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
        _messages.add(
          ChatMessage(
            message: "[Image sent for diagnosis]",
            time: _getCurrentTime(),
            isMe: true,
          ),
        );
      });

      final bytes = await File(photo.path).readAsBytes();
      final base64String = base64Encode(bytes);

      _sendToOllama(imageBase64: base64String);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3D9F2),
        elevation: 0,
        title: const Text("MechMate"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _clearConversation,
            tooltip: "New conversation",
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Chat Body
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  message: msg.message,
                  time: msg.time,
                  isMe: msg.isMe,
                  imageFile: msg.imageFile,
                );
              },
            ),
          ),

          // Image Preview
          if (_selectedImage != null)
            ImagePreview(
              imageFile: _selectedImage!,
              onRemove: _removeSelectedImage,
            ),

          // Loading indicator
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19456B)),
            ),

          // Input Bar
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

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoading ? null : _handleImageCapture,
            icon: Icon(
              Icons.camera_alt,
              color: _isLoading ? Colors.grey : const Color(0xFF19456B),
            ),
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
                  hintText: "Ask MechMate anything...",
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
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
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
                  bottomLeft: isMe
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
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
