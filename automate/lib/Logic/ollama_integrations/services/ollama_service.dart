import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OllamaService {
  final String ollamaUrl;
  final String modelName;
  
  // Store conversation history
  final List<Map<String, dynamic>> _conversationHistory = [];
  
  OllamaService({
    required this.ollamaUrl,
    required this.modelName,
  });
  
  // Get current conversation history (for debugging)
  List<Map<String, dynamic>> get conversationHistory => _conversationHistory;
  
  // Clear conversation history
  void clearConversation() {
    _conversationHistory.clear();
  }
  
  // Add welcome message to history
  void addWelcomeMessage(String message) {
    _conversationHistory.add({
      'role': 'assistant',
      'content': message,
    });
  }
  
  // Send message with full conversation history
  Future<String> sendMessage({
    required String text,
    String? imageBase64,
  }) async {
    // Build messages array with full conversation history + current message
    final List<Map<String, dynamic>> apiMessages = [];
    
    // Add all previous conversation history
    for (var msg in _conversationHistory) {
      apiMessages.add({
        'role': msg['role'],
        'content': msg['content'],
      });
    }
    
    // Add the current user message
    final userMessage = {
      'role': 'user',
      'content': text,
    };
    
    if (imageBase64 != null) {
      userMessage['images'] = imageBase64;
    }
    
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
            "temperature": 0.7,
            "num_predict": 1000,
          }
        }),
      ).timeout(const Duration(seconds: 90));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessageRaw = data['message']['content'];
        
        // Convert to String if it's a List
        final String botMessage;
        if (botMessageRaw is List) {
          botMessage = botMessageRaw.join(' ');
        } else if (botMessageRaw is String) {
          botMessage = botMessageRaw;
        } else {
          botMessage = botMessageRaw.toString();
        }
        
        // Add to conversation history
        _conversationHistory.add({
          'role': 'user',
          'content': text,
        });
        
        _conversationHistory.add({
          'role': 'assistant',
          'content': botMessage,
        });
        
        return botMessage;
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}