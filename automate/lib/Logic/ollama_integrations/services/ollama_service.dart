import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  final String ollamaUrl;
  final String modelName;

  // This holds the "Memory" of the chat
  final List<Map<String, dynamic>> _conversationHistory = [];

  OllamaService({required this.ollamaUrl, required this.modelName});

  List<Map<String, dynamic>> get conversationHistory => _conversationHistory;

  void clearConversation() => _conversationHistory.clear();

  void addWelcomeMessage(String message) {
    _conversationHistory.add({'role': 'assistant', 'content': message});
  }

  Future<String> sendMessage({
    required String text,
    String? imageBase64,
  }) async {
    // 1. Prepare the messages list for the API
    // We include the full history so the AI remembers the context
    final List<Map<String, dynamic>> apiMessages = _conversationHistory.map((msg) => {
      'role': msg['role'],
      'content': msg['content'],
    }).toList();

    // 2. Create the new user message
    final Map<String, dynamic> userMessage = {
      'role': 'user',
      'content': text,
    };

    // 3. Attach image (as a list of strings)
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      userMessage['images'] = [imageBase64]; 
    }

    // Add current message to the API payload
    apiMessages.add(userMessage);

    try {
      final response = await http.post(
        Uri.parse(ollamaUrl),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "model": modelName,
          "messages": apiMessages,
          "stream": false,
          "options": {
            "temperature": 0.5, // Lower temperature is better for mechanical diagnosis
            "num_ctx": 2048,    // Limits memory usage for 8GB VRAM
          }
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String botMessage = data['message']['content'].toString();

        // 4. Update local history so it's remembered next time
        // Note: We don't save the massive image string to history 
        // to keep the app fast; we only save the text.
        _conversationHistory.add({'role': 'user', 'content': text});
        _conversationHistory.add({'role': 'assistant', 'content': botMessage});

        return botMessage;
      } else {
        return "Server Error (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}