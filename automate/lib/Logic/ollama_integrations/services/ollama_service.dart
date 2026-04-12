import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/config_services.dart';

class OllamaService {
  static const int timeoutSeconds = 90;
  
  Future<String> sendMessage({
    String? text,
    String? imageBase64,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ConfigService.getOllamaUrl()),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "model": "llama3.2-vision",
          "messages": [
            {
              "role": "user",
              "content": text ?? "Look at this vehicle part. What visible failures or issues are present? List 3 possibilities.",
              if (imageBase64 != null) "images": [imageBase64]
            }
          ],
          "stream": false
        }),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message']['content'];
      } else {
        throw HttpException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Check your network.');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.message}');
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}