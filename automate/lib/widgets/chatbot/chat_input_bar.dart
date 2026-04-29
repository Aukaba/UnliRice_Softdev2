import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatInputBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    final isSendEnabled = hasSelectedImage || hasText;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isLoading ? null : onCameraTap,
            icon: Icon(
              Icons.camera_alt,
              color: isLoading ? Colors.grey : const Color(0xFF19456B),
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
                controller: controller,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: hasSelectedImage 
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
            onTap: isLoading ? null : (isSendEnabled ? onSendTap : null),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLoading 
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