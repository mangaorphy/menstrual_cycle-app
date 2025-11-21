import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../config/llm_config.dart';

class TrainingDataService {
  static const String _interactionsKey = 'chat_interactions';
  static const String _feedbackKey = 'user_feedback';
  
  // Store a new interaction for training
  static Future<void> storeInteraction({
    required String userMessage,
    required String botResponse,
    required String modelUsed,
    required int latencyMs,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!LLMConfig.COLLECT_TRAINING_DATA) return;
    
    final interaction = {
      'id': _generateInteractionId(),
      'timestamp': DateTime.now().toIso8601String(),
      'user_message': LLMConfig.ANONYMIZE_TRAINING_DATA ? _anonymizeMessage(userMessage) : userMessage,
      'bot_response': botResponse,
      'model_used': modelUsed,
      'latency_ms': latencyMs,
      'session_id': sessionId ?? _generateSessionId(),
      'metadata': metadata ?? {},
      'user_rating': null, // Will be filled when user provides feedback
      'is_validated': false,
    };
    
    await _storeInteractionLocally(interaction);
  }
  
  // Store user feedback for a specific interaction
  static Future<void> storeFeedback({
    required String interactionId,
    required int rating, // 1-5 scale
    String? feedbackText,
    List<String>? tags, // e.g., ['helpful', 'accurate', 'relevant']
  }) async {
    final feedback = {
      'interaction_id': interactionId,
      'rating': rating,
      'feedback_text': feedbackText,
      'tags': tags ?? [],
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Update the original interaction with rating
    await _updateInteractionRating(interactionId, rating);
    
    // Store feedback separately
    final prefs = await SharedPreferences.getInstance();
    final existingFeedback = prefs.getStringList(_feedbackKey) ?? [];
    existingFeedback.add(jsonEncode(feedback));
    
    await prefs.setStringList(_feedbackKey, existingFeedback);
  }
  
  // Export training data in different formats
  static Future<List<Map<String, dynamic>>> exportTrainingData({
    String format = 'openai', // 'openai', 'gemini', 'generic'
    bool onlyRatedInteractions = false,
    int minRating = 3,
  }) async {
    final interactions = await _getStoredInteractions();
    
    List<Map<String, dynamic>> trainingData = [];
    
    for (var interaction in interactions) {
      // Filter based on criteria
      if (onlyRatedInteractions && interaction['user_rating'] == null) continue;
      if (interaction['user_rating'] != null && interaction['user_rating'] < minRating) continue;
      
      // Format according to provider requirements
      Map<String, dynamic> formattedData;
      switch (format.toLowerCase()) {
        case 'openai':
          formattedData = TrainingDataFormat.openAIFormat(
            interaction['user_message'],
            interaction['bot_response'],
          );
          break;
        case 'gemini':
          formattedData = TrainingDataFormat.geminiFormat(
            interaction['user_message'],
            interaction['bot_response'],
          );
          break;
        default:
          formattedData = TrainingDataFormat.genericFormat(
            interaction['user_message'],
            interaction['bot_response'],
          );
      }
      
      trainingData.add(formattedData);
    }
    
    return trainingData;
  }
  
  // Export to JSONL file (required for OpenAI fine-tuning)
  static Future<File> exportToJSONL({
    bool onlyHighRated = true,
    int minRating = 4,
  }) async {
    final trainingData = await exportTrainingData(
      format: 'openai',
      onlyRatedInteractions: onlyHighRated,
      minRating: minRating,
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/menstrual_health_training.jsonl');
    
    final jsonlContent = trainingData
        .map((data) => jsonEncode(data))
        .join('\n');
    
    await file.writeAsString(jsonlContent);
    return file;
  }
  
  // Get training statistics
  static Future<Map<String, dynamic>> getTrainingStats() async {
    final interactions = await _getStoredInteractions();
    final feedback = await _getStoredFeedback();
    
    // Calculate statistics
    final totalInteractions = interactions.length;
    final ratedInteractions = interactions.where((i) => i['user_rating'] != null).length;
    final highRatedInteractions = interactions.where((i) => i['user_rating'] != null && i['user_rating'] >= 4).length;
    
    final averageRating = ratedInteractions > 0 
        ? interactions
            .where((i) => i['user_rating'] != null)
            .map((i) => i['user_rating'] as int)
            .reduce((a, b) => a + b) / ratedInteractions
        : 0.0;
    
    final averageLatency = interactions.isNotEmpty
        ? interactions
            .map((i) => i['latency_ms'] as int)
            .reduce((a, b) => a + b) / interactions.length
        : 0.0;
    
    // Most common user topics
    final topicCounts = <String, int>{};
    for (var interaction in interactions) {
      final topics = _extractTopics(interaction['user_message']);
      for (var topic in topics) {
        topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      }
    }
    
    return {
      'total_interactions': totalInteractions,
      'rated_interactions': ratedInteractions,
      'high_rated_interactions': highRatedInteractions,
      'average_rating': averageRating,
      'average_latency_ms': averageLatency,
      'rating_percentage': totalInteractions > 0 ? (ratedInteractions / totalInteractions) * 100 : 0,
      'top_topics': topicCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(10)
          .map((e) => {'topic': e.key, 'count': e.value})
          .toList(),
      'ready_for_training': highRatedInteractions >= 100, // Minimum recommended for fine-tuning
    };
  }
  
  // Clean up old data to manage storage
  static Future<void> cleanupOldData({int keepLastDays = 90}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: keepLastDays));
    
    final interactions = await _getStoredInteractions();
    final filteredInteractions = interactions.where((interaction) {
      final timestamp = DateTime.parse(interaction['timestamp']);
      return timestamp.isAfter(cutoffDate);
    }).toList();
    
    final prefs = await SharedPreferences.getInstance();
    final encodedInteractions = filteredInteractions.map((i) => jsonEncode(i)).toList();
    await prefs.setStringList(_interactionsKey, encodedInteractions);
  }
  
  // Private helper methods
  static Future<void> _storeInteractionLocally(Map<String, dynamic> interaction) async {
    final prefs = await SharedPreferences.getInstance();
    final existingInteractions = prefs.getStringList(_interactionsKey) ?? [];
    
    existingInteractions.add(jsonEncode(interaction));
    
    // Keep only the last N interactions to manage storage
    if (existingInteractions.length > LLMConfig.MAX_STORED_INTERACTIONS) {
      existingInteractions.removeAt(0);
    }
    
    await prefs.setStringList(_interactionsKey, existingInteractions);
  }
  
  static Future<List<Map<String, dynamic>>> _getStoredInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedInteractions = prefs.getStringList(_interactionsKey) ?? [];
    
    return encodedInteractions
        .map((encoded) => jsonDecode(encoded) as Map<String, dynamic>)
        .toList();
  }
  
  static Future<List<Map<String, dynamic>>> _getStoredFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedFeedback = prefs.getStringList(_feedbackKey) ?? [];
    
    return encodedFeedback
        .map((encoded) => jsonDecode(encoded) as Map<String, dynamic>)
        .toList();
  }
  
  static Future<void> _updateInteractionRating(String interactionId, int rating) async {
    final interactions = await _getStoredInteractions();
    
    for (int i = 0; i < interactions.length; i++) {
      if (interactions[i]['id'] == interactionId) {
        interactions[i]['user_rating'] = rating;
        break;
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    final encodedInteractions = interactions.map((i) => jsonEncode(i)).toList();
    await prefs.setStringList(_interactionsKey, encodedInteractions);
  }
  
  static String _generateInteractionId() {
    return 'int_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
  
  static String _generateSessionId() {
    return 'sess_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  static String _anonymizeMessage(String message) {
    if (!LLMConfig.ANONYMIZE_TRAINING_DATA) return message;
    
    // Simple anonymization - replace personal info with placeholders
    String anonymized = message;
    
    // Remove/replace potential personal identifiers
    anonymized = anonymized.replaceAll(RegExp(r'\b\d{1,2}/\d{1,2}/\d{4}\b'), '[DATE]');
    anonymized = anonymized.replaceAll(RegExp(r'\b\d{4}-\d{2}-\d{2}\b'), '[DATE]');
    anonymized = anonymized.replaceAll(RegExp(r'\b\d{1,2}\s*years?\s*old\b'), '[AGE] years old');
    anonymized = anonymized.replaceAll(RegExp(r"\bI'm\s+\d{1,2}\b"), "I'm [AGE]");
    
    return anonymized;
  }
  
  static List<String> _extractTopics(String message) {
    final topics = <String>[];
    final lowerMessage = message.toLowerCase();
    
    // Common menstrual health topics
    final topicKeywords = {
      'period': ['period', 'menstruation', 'menstrual'],
      'pain': ['pain', 'cramp', 'ache', 'hurt'],
      'cycle': ['cycle', 'regular', 'irregular'],
      'ovulation': ['ovulation', 'ovulate', 'fertile'],
      'mood': ['mood', 'emotion', 'feeling', 'pms'],
      'symptoms': ['symptom', 'sign', 'experience'],
      'tracking': ['track', 'log', 'record', 'app'],
      'pregnancy': ['pregnant', 'pregnancy', 'conception'],
      'health': ['health', 'doctor', 'medical'],
    };
    
    for (var entry in topicKeywords.entries) {
      for (var keyword in entry.value) {
        if (lowerMessage.contains(keyword)) {
          topics.add(entry.key);
          break;
        }
      }
    }
    
    return topics;
  }
}
