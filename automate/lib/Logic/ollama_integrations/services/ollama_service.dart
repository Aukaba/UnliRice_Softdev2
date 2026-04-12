import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/chat_message.dart';

class AiService {
  // Replace this with your ngrok link or use --dart-define
  final String ollamaUrl = "https://supposedly-abdicative-ben.ngrok-free.dev/api/chat";

  Future<String> getDiagnosis(List<ChatMessage> history) async {
    try {
      final response = await http.post(
        Uri.parse(ollamaUrl),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "model": "llama3.2-vision",
          "messages": history.map((m) => m.toOllamaJson()).toList(),
          "stream": false
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message']['content'];
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}