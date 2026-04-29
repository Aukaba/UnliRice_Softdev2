import 'dart:io';

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