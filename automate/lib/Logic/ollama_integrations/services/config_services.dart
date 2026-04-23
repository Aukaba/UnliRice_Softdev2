class ConfigService {
  // For development - replace with your actual Ollama URL
  static const String ollamaUrl = 'http://192.168.1.XXX:11434/api/chat';
  
  // For production - use environment variables or secure storage
  static String getOllamaUrl() {
    // You can implement logic to switch between dev/prod URLs
    return ollamaUrl;
  }
}