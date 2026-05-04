import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final bool hasSelectedImage;
  final VoidCallback onCameraTap;
  final VoidCallback onSendTap;
  
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.hasSelectedImage,
    required this.onCameraTap,
    required this.onSendTap,
  });
  
  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    // Listen to text changes
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }
  
  @override
  void dispose() {
    // Remove listener to avoid memory leaks
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }
  
  @override
  void didUpdateWidget(ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If controller changed, update listeners
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.trim().isNotEmpty;
    }
  }
  
  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isSendEnabled = widget.hasSelectedImage || _hasText;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.isLoading ? null : widget.onCameraTap,
            icon: Icon(
              Icons.camera_alt,
              color: widget.isLoading ? Colors.grey : const Color(0xFF19456B),
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
                controller: widget.controller,
                enabled: !widget.isLoading,
                decoration: InputDecoration(
                  hintText: widget.hasSelectedImage 
                      ? "Add a description (optional)..." 
                      : "Ask MechMate...",
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
            onTap: (widget.isLoading || !isSendEnabled) ? null : widget.onSendTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isLoading 
                    ? Colors.grey 
                    : (isSendEnabled ? const Color(0xFF19456B) : Colors.grey.shade400),
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
}