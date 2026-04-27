import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MechMateChatScreen extends StatefulWidget {
  const MechMateChatScreen({super.key});

  @override
  State<MechMateChatScreen> createState() => _MechMateChatScreenState();
}

class _MechMateChatScreenState extends State<MechMateChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _selectedImage; // Track selected image before sending
  String? _imageDescription; // Optional description for the image
  
  List<ChatMessage> _messages = [];
  
  final String ollamaUrl = "https://supposedly-abdicative-ben.ngrok-free.dev/api/chat";
  final String modelName = "llama3.2-vision";

  @override
  void initState() {
    super.initState();
    // Initialize with welcome message
    _messages.add(ChatMessage(
      message: "Hello! I'm MechMate, your AI assistant. I can analyze vehicle photos. Take a picture or describe your issue!",
      time: _getCurrentTime(),
      isMe: false,
    ));
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $ampm";
  }

  /// Show image source selection dialog
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

  /// Pick image from camera or gallery
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

  /// Remove selected image preview
  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _imageDescription = null;
    });
  }

  /// Send message with optional image to Ollama AI
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

  /// Send message with image (both together)
  Future<void> _sendMessageWithImage() async {
    if (_selectedImage == null) return;
    
    final text = _msgController.text.trim();
    final hasText = text.isNotEmpty;
    
    // Add user message with image preview
    setState(() {
      _messages.add(ChatMessage(
        message: hasText ? text : "[Image sent for analysis]",
        time: _getCurrentTime(),
        isMe: true,
        imageFile: _selectedImage, // Store image in message
      ));
      _isLoading = true;
    });
    
    _msgController.clear();
    
    // Prepare the image as base64
    final bytes = await _selectedImage!.readAsBytes();
    final base64String = base64Encode(bytes);
    
    // Prepare the prompt (include text description if provided)
    final prompt = hasText 
        ? text 
        : "Look at this vehicle image. What visible issues or potential problems can you identify? List 3 possibilities.";
    
    // Clear selected image after sending
    setState(() {
      _selectedImage = null;
      _imageDescription = null;
    });
    
    // Send to AI
    await _sendToOllama(text: prompt, imageBase64: base64String);
    
    setState(() => _isLoading = false);
  }

  /// Send text-only message
  void _handleSendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    
    final text = _msgController.text.trim();
    
    setState(() {
      _messages.add(ChatMessage(
        message: text,
        time: _getCurrentTime(),
        isMe: true,
      ));
      _isLoading = true;
    });
    
    _msgController.clear();
    _sendToOllama(text: text).then((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildMechMateHeader(),

          // Main Chat Body
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
                  imageFile: msg.imageFile,
                );
              },
            ),
          ),

          // Image Preview (if an image is selected but not yet sent)
          if (_selectedImage != null)
            _buildImagePreview(),

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

  /// Image preview widget before sending
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
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
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
          // Attachment button (Camera/Gallery)
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
          // Send button - changes behavior based on whether an image is selected
          GestureDetector(
            onTap: _isLoading 
                ? null 
                : (_selectedImage != null 
                    ? _sendMessageWithImage 
                    : _handleSendMessage),
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

  Widget _buildMessageBubble({
    required String message,
    required String time,
    required bool isMe,
    File? imageFile,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show image if present (like ChatGPT)
                  if (imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          imageFile,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  // Show text message (if present)
                  if (message.isNotEmpty)
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

// Message model class (updated to include image)
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