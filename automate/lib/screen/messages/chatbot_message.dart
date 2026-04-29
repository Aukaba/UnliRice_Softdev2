import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../Logic/ollama_integrations/services/ollama_service.dart';
import '../../widgets/chatbot/chat_bubble.dart';

// ── ChatMessage model ────────────────────────────────────────────────────────
class ChatMessage {
  final String message;
  final String time;
  final bool isMe;
  final bool isError;
  final File? imageFile;

  ChatMessage({
    required this.message,
    required this.time,
    required this.isMe,
    this.isError = false,
    this.imageFile,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────
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
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    _ollamaService = OllamaService(
      ollamaUrl: "https://supposedly-abdicative-ben.ngrok-free.dev/api/chat",
      modelName: "llama3.2-vision",
    );

    const welcomeMessage =
        "Hello! I'm MechMate, your AI assistant. I can analyze vehicle photos. Take a picture or describe your issue!";

    _messages.add(ChatMessage(
      message: welcomeMessage,
      time: _getCurrentTime(),
      isMe: false,
    ));

    _ollamaService.addWelcomeMessage(welcomeMessage);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $ampm";
  }

  // ── Image Picking ──────────────────────────────────────────────────────────

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
      setState(() => _selectedImage = File(photo.path));
    }
  }

  void _removeSelectedImage() {
    setState(() => _selectedImage = null);
  }

  // ── Sending Messages ───────────────────────────────────────────────────────

  Future<void> _sendMessageWithImage() async {
    if (_selectedImage == null) return;

    final text = _msgController.text.trim();
    final hasText = text.isNotEmpty;
    final userMessageText = hasText ? text : "[Image sent for analysis]";
    final imageToSend = _selectedImage!;

    setState(() {
      _messages.add(ChatMessage(
        message: userMessageText,
        time: _getCurrentTime(),
        isMe: true,
        imageFile: imageToSend,
      ));
      _isLoading = true;
      _selectedImage = null;
    });

    _msgController.clear();

    final bytes = await imageToSend.readAsBytes();
    final base64String = base64Encode(bytes);
    final prompt = hasText
        ? text
        : "Look at this vehicle image. What visible issues or potential problems can you identify? List 3 possibilities.";

    final botResponse = await _ollamaService.sendMessage(
      text: prompt,
      imageBase64: base64String,
    );

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(
          message: botResponse,
          time: _getCurrentTime(),
          isMe: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTextMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        message: text,
        time: _getCurrentTime(),
        isMe: true,
      ));
      _isLoading = true;
    });

    _msgController.clear();

    final botResponse = await _ollamaService.sendMessage(text: text);

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(
          message: botResponse,
          time: _getCurrentTime(),
          isMe: false,
        ));
        _isLoading = false;
      });
    }
  }

  void _handleSendMessage() {
    if (_selectedImage != null) {
      _sendMessageWithImage();
    } else {
      _sendTextMessage();
    }
  }

  void _clearConversation() {
    setState(() {
      _ollamaService.clearConversation();
      _messages.clear();
      _selectedImage = null;

      const welcomeMessage =
          "Hello! I'm MechMate, your AI assistant. How can I help with your vehicle today?";

      _messages.add(ChatMessage(
        message: welcomeMessage,
        time: _getCurrentTime(),
        isMe: false,
      ));

      _ollamaService.addWelcomeMessage(welcomeMessage);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conversation cleared!")),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3D9F2),
        elevation: 0,
        title: Row(
          children: const [
            Text("MechMate "),
            Text("✦", style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
          ],
        ),
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

          if (_selectedImage != null) _buildImagePreview(),

          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19456B)),
            ),

          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeSelectedImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
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
            onPressed: _isLoading ? null : _showImageSourceDialog,
            icon: Icon(
              Icons.attach_file,
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
                  hintText: _selectedImage != null
                      ? "Add a description (optional)..."
                      : "Ask MechMate or upload a photo...",
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
                color: _isLoading
                    ? Colors.grey
                    : (_selectedImage != null || _msgController.text.isNotEmpty
                        ? const Color(0xFF19456B)
                        : Colors.grey.shade400),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedImage != null ? Icons.send : Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
