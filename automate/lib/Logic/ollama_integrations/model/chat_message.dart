class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? images;

  ChatMessage({required this.text, required this.isUser, this.images});

  // Helper to convert our UI message to the format Ollama expects
  Map<String, dynamic> toOllamaJson() {
    return {
      "role": isUser ? "user" : "assistant",
      "content": text,
      if (images != null) "images": images,
    };
  }
}