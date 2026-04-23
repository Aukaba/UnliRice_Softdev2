class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.type = MessageType.text,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'type': type.toString(),
  };
}

enum MessageType { text, image, error }