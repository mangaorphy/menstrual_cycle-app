import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotService {
  // Configuration for different LLM providers
  static const bool USE_FINE_TUNED_MODEL =
      false; // Set to true when you have a fine-tuned model
  static const String LLM_PROVIDER = 'openai'; // 'openai', 'gemini', 'local'

  // OpenAI Configuration
  static const String _openaiApiUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String _openaiApiKey =
      'your-openai-api-key'; // Replace with your API key
  static const String _fineTunedModelId =
      'ft:gpt-3.5-turbo-xxx'; // Your fine-tuned model ID

  // Gemini Configuration
  static const String _geminiApiKey =
      'your-gemini-api-key'; // Replace with your API key
  static const String _geminiModel = 'gemini-pro'; // or your fine-tuned model

  // Performance tracking
  static int _requestCount = 0;
  static final List<Map<String, dynamic>> _interactionLog = [];

  static const String _systemPrompt = '''
You are MenstruAI, a helpful and knowledgeable assistant specialized in menstrual health, reproductive wellness, and women's health. You are integrated into a menstrual cycle tracking app.

Your expertise includes:
- Menstrual cycle phases and hormones
- Period symptoms and management
- Fertility awareness and ovulation
- Contraception methods
- General reproductive health
- App features and cycle tracking

Guidelines:
- Always be supportive, non-judgmental, and empathetic
- Provide accurate, evidence-based information
- Encourage users to consult healthcare providers for medical concerns
- Keep responses concise but informative (2-3 sentences max)
- Use warm, friendly language
- If asked about serious medical issues, always recommend seeing a doctor

You should NOT:
- Diagnose medical conditions
- Recommend specific medications
- Replace professional medical advice
- Discuss topics unrelated to women's health or the app

Respond in a caring, knowledgeable way that empowers users with information while emphasizing the importance of professional healthcare when needed.
''';

  Future<String> sendMessage(
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    final startTime = DateTime.now();

    try {
      String response;

      if (USE_FINE_TUNED_MODEL && LLM_PROVIDER == 'openai') {
        response = await _callFineTunedOpenAI(message, conversationHistory);
      } else if (LLM_PROVIDER == 'gemini') {
        response = await _callGemini(message, conversationHistory);
      } else if (LLM_PROVIDER == 'local') {
        response = await _callLocalModel(message, conversationHistory);
      } else {
        // Fallback to rule-based responses for demo
        response = _getLocalResponse(message);
      }

      // Log interaction for future training
      await _logInteraction(message, response, startTime);

      return response;
    } catch (e) {
      print('Error in chatbot service: $e');
      // Fallback to local responses if API fails
      return _getLocalResponse(message);
    }
  }

  // Fine-tuned OpenAI API call
  Future<String> _callFineTunedOpenAI(
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...conversationHistory,
      {'role': 'user', 'content': message},
    ];

    final response = await http.post(
      Uri.parse(_openaiApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiApiKey',
      },
      body: jsonEncode({
        'model': _fineTunedModelId,
        'messages': messages,
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception(
        'Failed to get response from OpenAI: ${response.statusCode}',
      );
    }
  }

  // Gemini API call
  Future<String> _callGemini(
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$_geminiApiKey';

    // Combine conversation history into a single prompt
    String fullPrompt = '$_systemPrompt\n\n';
    for (var msg in conversationHistory) {
      fullPrompt += '${msg['role']}: ${msg['content']}\n';
    }
    fullPrompt += 'user: $message\nassistant:';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': fullPrompt},
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': 150, 'temperature': 0.7},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    } else {
      throw Exception(
        'Failed to get response from Gemini: ${response.statusCode}',
      );
    }
  }

  // Placeholder for local model integration
  Future<String> _callLocalModel(
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    // TODO: Implement local TensorFlow Lite or ONNX model inference
    // For now, fallback to rule-based responses
    return _getLocalResponse(message);
  }

  // Log interactions for training data collection
  Future<void> _logInteraction(
    String userMessage,
    String botResponse,
    DateTime startTime,
  ) async {
    final endTime = DateTime.now();
    final latency = endTime.difference(startTime);

    final interaction = {
      'timestamp': DateTime.now().toIso8601String(),
      'user_message': userMessage,
      'bot_response': botResponse,
      'latency_ms': latency.inMilliseconds,
      'model_used': LLM_PROVIDER,
      'request_id': _requestCount++,
    };

    _interactionLog.add(interaction);

    // Store locally for potential training data
    final prefs = await SharedPreferences.getInstance();
    final existingLogs = prefs.getStringList('chat_interactions') ?? [];
    existingLogs.add(jsonEncode(interaction));

    // Keep only last 1000 interactions to manage storage
    if (existingLogs.length > 1000) {
      existingLogs.removeAt(0);
    }

    await prefs.setStringList('chat_interactions', existingLogs);
  }

  // Export training data for fine-tuning
  static Future<List<Map<String, dynamic>>> exportTrainingData() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('chat_interactions') ?? [];

    return logs.map((log) {
      final interaction = jsonDecode(log);
      return {
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': interaction['user_message']},
          {'role': 'assistant', 'content': interaction['bot_response']},
        ],
      };
    }).toList();
  }

  // Rate a response (for training data quality)
  static Future<void> rateResponse(String requestId, int rating) async {
    // Find and update the interaction with rating
    for (var interaction in _interactionLog) {
      if (interaction['request_id'].toString() == requestId) {
        interaction['user_rating'] = rating;
        break;
      }
    }

    // TODO: Send rating to analytics/training pipeline
  }

  // Simple local responses for demo (replace with actual API)
  String _getLocalResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Menstrual cycle questions
    if (lowerMessage.contains('period') &&
        (lowerMessage.contains('late') || lowerMessage.contains('delayed'))) {
      return "Period delays can happen due to stress, diet changes, exercise, or hormonal fluctuations. If it's more than a week late or this is unusual for you, consider taking a pregnancy test or consulting your healthcare provider.";
    }

    if (lowerMessage.contains('period') && lowerMessage.contains('pain')) {
      return "Period pain (dysmenorrhea) is common and can be managed with heat therapy, gentle exercise, and over-the-counter pain relievers. If pain is severe or interfering with daily activities, please consult your doctor.";
    }

    if (lowerMessage.contains('ovulation')) {
      return "Ovulation typically occurs around day 14 of a 28-day cycle. Signs include changes in cervical mucus, slight temperature increase, and sometimes mild pelvic pain. Our app can help you track these patterns!";
    }

    if (lowerMessage.contains('cycle') &&
        (lowerMessage.contains('irregular') ||
            lowerMessage.contains('length'))) {
      return "Normal cycles range from 21-35 days. Irregularities can be caused by stress, weight changes, or hormonal shifts. Track your cycles with our app to identify patterns and share this data with your healthcare provider.";
    }

    if (lowerMessage.contains('pms') || lowerMessage.contains('mood')) {
      return "PMS symptoms like mood changes are caused by hormonal fluctuations. Regular exercise, balanced nutrition, and stress management can help. Log your symptoms in the app to track patterns and discuss with your doctor if severe.";
    }

    // App-related questions
    if (lowerMessage.contains('app') ||
        lowerMessage.contains('track') ||
        lowerMessage.contains('log')) {
      return "You can log your period, symptoms, mood, and flow intensity using our tracking features. Go to the calendar or use the quick log buttons on the home screen to get started!";
    }

    if (lowerMessage.contains('prediction') ||
        lowerMessage.contains('forecast')) {
      return "Our app uses your cycle history to predict your next period and fertile window. The more data you log, the more accurate these predictions become. Keep tracking consistently for best results!";
    }

    // General health questions
    if (lowerMessage.contains('pregnant') ||
        lowerMessage.contains('pregnancy')) {
      return "If you suspect pregnancy, take a home pregnancy test and consult with a healthcare provider. Our app can help you track symptoms and cycle patterns to share with your doctor.";
    }

    // Greetings and general
    if (lowerMessage.contains('hello') ||
        lowerMessage.contains('hi') ||
        lowerMessage.contains('hey')) {
      return "Hello! I'm MenstruAI, your personal menstrual health assistant. I'm here to help with questions about your cycle, symptoms, and app features. What would you like to know?";
    }

    if (lowerMessage.contains('help')) {
      return "I can help you with questions about menstrual cycles, period symptoms, fertility, and using this app. Just ask me anything about your reproductive health or cycle tracking!";
    }

    // Default response
    return "That's a great question! For specific medical concerns, I always recommend consulting with a healthcare provider. Is there anything else about menstrual health or using the app that I can help you with?";
  }

  // Uncomment and configure for actual OpenAI API integration
  /*
  Future<String> _callOpenAI(String message, List<Map<String, String>> conversationHistory) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...conversationHistory,
      {'role': 'user', 'content': message},
    ];

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to get response from OpenAI');
    }
  }
  */
}
