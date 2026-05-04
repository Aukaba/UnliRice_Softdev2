import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Logic/ollama_integrations/services/ollama_service.dart';
import '../../widgets/chatbot/chat_bubble.dart';
import '../../widgets/chatbot/image_preview.dart';
import '../../widgets/chatbot/chat_input_bar.dart';

import '../../Logic/ollama_integrations/model/chat_message.dart';

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

    _messages.add(
      ChatMessage(
        message: welcomeMessage,
        time: _getCurrentTime(),
        isMe: false,
      ),
    );

    _ollamaService.addWelcomeMessage(welcomeMessage);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
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
      setState(() => _selectedImage = File(photo.path));
    }
  }

  void _removeSelectedImage() {
    setState(() => _selectedImage = null);
  }

  Future<void> _sendMessageWithImage() async {
    if (_selectedImage == null) return;

    final text = _msgController.text.trim();
    final hasText = text.isNotEmpty;
    final userMessageText = hasText ? text : "[Image sent for analysis]";

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
      _selectedImage = null;
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

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: botResponse,
            time: _getCurrentTime(),
            isMe: false,
          ),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTextMessage() async {
    if (_msgController.text.trim().isEmpty) return;

    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(message: text, time: _getCurrentTime(), isMe: true),
      );
      _isLoading = true;
    });

    _msgController.clear();

    // Send to AI
    final botResponse = await _ollamaService.sendMessage(text: text);

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: botResponse,
            time: _getCurrentTime(),
            isMe: false,
          ),
        );
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

      _messages.add(
        ChatMessage(
          message: welcomeMessage,
          time: _getCurrentTime(),
          isMe: false,
        ),
      );

      _ollamaService.addWelcomeMessage(welcomeMessage);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Conversation cleared!")));
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
          ChatInputBar(
            controller: _msgController,
            isLoading: _isLoading,
            hasSelectedImage: _selectedImage != null,
            onCameraTap: _showImageSourceDialog,
            onSendTap: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}
