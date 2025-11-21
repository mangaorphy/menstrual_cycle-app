class LLMConfig {
  // Toggle between different implementations
  static const bool USE_CLOUD_API = false; // Set to true when you have API keys
  static const bool USE_FINE_TUNED_MODEL =
      false; // Set to true when you have fine-tuned model
  static const bool COLLECT_TRAINING_DATA =
      true; // Collect interactions for training

  // Provider selection: 'openai', 'gemini', 'anthropic', 'local', 'demo'
  static const String PROVIDER = 'demo';

  // OpenAI Configuration
  static const String OPENAI_API_KEY = 'your-openai-api-key-here';
  static const String OPENAI_FINE_TUNED_MODEL = 'ft:gpt-3.5-turbo-xxxx';
  static const String OPENAI_BASE_MODEL = 'gpt-3.5-turbo';

  // Google Gemini Configuration
  static const String GEMINI_API_KEY = 'your-gemini-api-key-here';
  static const String GEMINI_MODEL = 'gemini-pro';
  static const String GEMINI_FINE_TUNED_MODEL =
      'tunedModels/menstrual-health-assistant';

  // Anthropic Claude Configuration
  static const String ANTHROPIC_API_KEY = 'your-anthropic-api-key-here';
  static const String ANTHROPIC_MODEL = 'claude-3-haiku-20240307';

  // Local Model Configuration
  static const String LOCAL_MODEL_PATH =
      'assets/models/menstrual_health_model.tflite';
  static const String LOCAL_TOKENIZER_PATH = 'assets/models/tokenizer.json';

  // Performance and Cost Settings
  static const int MAX_TOKENS = 150;
  static const double TEMPERATURE = 0.7;
  static const int MAX_CONVERSATION_HISTORY = 10;
  static const int CACHE_DURATION_HOURS = 24;

  // Training Data Collection
  static const int MAX_STORED_INTERACTIONS = 1000;
  static const bool ENABLE_USER_FEEDBACK = true;
  static const bool EXPORT_TRAINING_DATA = true;

  // Privacy Settings
  static const bool ENCRYPT_LOCAL_DATA = true;
  static const bool ANONYMIZE_TRAINING_DATA = true;
  static const bool SEND_ANALYTICS = false;

  // Fallback Behavior
  static const bool USE_LOCAL_FALLBACK = true;
  static const int API_TIMEOUT_SECONDS = 10;
  static const int MAX_RETRIES = 3;
}

// Training data structure for different providers
class TrainingDataFormat {
  // OpenAI fine-tuning format
  static Map<String, dynamic> openAIFormat(
    String userMessage,
    String assistantResponse,
  ) {
    return {
      "messages": [
        {
          "role": "system",
          "content":
              "You are MenstruAI, a specialized assistant for menstrual health.",
        },
        {"role": "user", "content": userMessage},
        {"role": "assistant", "content": assistantResponse},
      ],
    };
  }

  // Gemini fine-tuning format
  static Map<String, dynamic> geminiFormat(
    String userMessage,
    String assistantResponse,
  ) {
    return {"input_text": userMessage, "output_text": assistantResponse};
  }

  // Generic conversation format
  static Map<String, dynamic> genericFormat(
    String userMessage,
    String assistantResponse,
  ) {
    return {
      "instruction": "Respond as MenstruAI, a menstrual health assistant.",
      "input": userMessage,
      "output": assistantResponse,
    };
  }
}

// Model performance metrics
class ModelMetrics {
  final String modelName;
  final double averageLatency;
  final double userSatisfactionScore;
  final int totalRequests;
  final int successfulRequests;
  final double costPerRequest;

  ModelMetrics({
    required this.modelName,
    required this.averageLatency,
    required this.userSatisfactionScore,
    required this.totalRequests,
    required this.successfulRequests,
    required this.costPerRequest,
  });

  double get successRate => successfulRequests / totalRequests;
}
