# Fine-Tuned LLM Integration Guide

## 1. Cloud-based Fine-tuning (OpenAI)

### Step 1: Prepare Training Data

Create a JSONL file with conversation examples:

```jsonl
{"messages": [{"role": "system", "content": "You are MenstruAI, a specialized assistant for menstrual health."}, {"role": "user", "content": "Why is my period late?"}, {"role": "assistant", "content": "Period delays can be caused by stress, hormonal changes, or lifestyle factors. If it's more than a week late, consider taking a pregnancy test and consulting your healthcare provider."}]}
{"messages": [{"role": "system", "content": "You are MenstruAI, a specialized assistant for menstrual health."}, {"role": "user", "content": "What are normal PMS symptoms?"}, {"role": "assistant", "content": "Common PMS symptoms include mood changes, bloating, breast tenderness, and fatigue. These typically occur 1-2 weeks before your period due to hormonal fluctuations."}]}
{"messages": [{"role": "system", "content": "You are MenstruAI, a specialized assistant for menstrual health."}, {"role": "user", "content": "How do I track ovulation?"}, {"role": "assistant", "content": "Track ovulation by monitoring basal body temperature, cervical mucus changes, and using our app's prediction features. Ovulation typically occurs 12-16 days before your next period."}]}
```

### Step 2: Fine-tune with OpenAI

```bash
# Install OpenAI CLI
pip install openai

# Upload training file
openai api files.create -f menstrual_health_training.jsonl -p fine-tune

# Create fine-tuning job
openai api fine_tuning.jobs.create -t file-abc123 -m gpt-3.5-turbo
```

### Step 3: Implementation in Flutter

```dart
class FineTunedChatbotService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _apiKey = 'your-api-key';
  static const String _fineTunedModel = 'ft:gpt-3.5-turbo-xxx'; // Your fine-tuned model ID

  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _fineTunedModel,
        'messages': [
          {'role': 'system', 'content': 'You are MenstruAI, specialized in menstrual health.'},
          ...history,
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to get response');
    }
  }
}
```

## 2. Google AI (Gemini) Fine-tuning

### Training Data Preparation
```python
import google.generativeai as genai

genai.configure(api_key="YOUR_API_KEY")

# Create training examples
training_data = [
    {
        "input_text": "Why is my period irregular?",
        "output_text": "Irregular periods can be caused by stress, weight changes, PCOS, or thyroid issues. Track your cycles for 3-6 months and consult a healthcare provider if patterns don't emerge."
    },
    # Add more examples...
]

# Create fine-tuned model
model = genai.create_tuned_model(
    source_model="models/gemini-1.0-pro",
    training_data=training_data,
    id="menstrual-health-assistant"
)
```

### Flutter Implementation
```dart
class GeminiChatbotService {
  static const String _apiKey = 'your-gemini-api-key';
  static const String _modelName = 'tunedModels/menstrual-health-assistant';

  Future<String> sendMessage(String message) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/$_modelName:generateContent?key=$_apiKey';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': message}]
        }]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get response from Gemini');
    }
  }
}
```

## 3. Local/Edge Deployment Options

### A. TensorFlow Lite with Flutter

```yaml
# Add to pubspec.yaml
dependencies:
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.3.1
```

```dart
class LocalLLMService {
  late Interpreter interpreter;
  
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('menstrual_health_model.tflite');
  }
  
  Future<String> generateResponse(String input) async {
    // Tokenize input
    List<List<int>> inputTokens = tokenize(input);
    
    // Run inference
    var output = List.filled(1 * 100, 0).reshape([1, 100]);
    interpreter.run(inputTokens, output);
    
    // Decode output
    return decode(output[0]);
  }
}
```

### B. ONNX Runtime

```yaml
dependencies:
  onnxruntime: ^1.16.0
```

```dart
class ONNXChatbotService {
  late OrtSession session;
  
  Future<void> initModel() async {
    final sessionOptions = OrtSessionOptions();
    session = OrtSession.fromAsset('menstrual_health_model.onnx', sessionOptions);
  }
  
  Future<String> predict(String input) async {
    // Preprocess input
    final inputTensor = preprocessInput(input);
    
    // Run inference
    final outputs = await session.runAsync(OrtValueTensor.createTensorWithDataList(inputTensor));
    
    // Postprocess and return
    return postprocessOutput(outputs[0]);
  }
}
```

## 4. Hybrid Approach Implementation

```dart
class HybridChatbotService {
  final LocalLLMService _localService = LocalLLMService();
  final CloudChatbotService _cloudService = CloudChatbotService();
  
  Future<String> sendMessage(String message) async {
    // Check if device has sufficient resources and network
    if (await _shouldUseLocal(message)) {
      try {
        return await _localService.generateResponse(message);
      } catch (e) {
        // Fallback to cloud
        return await _cloudService.sendMessage(message);
      }
    } else {
      return await _cloudService.sendMessage(message);
    }
  }
  
  Future<bool> _shouldUseLocal(String message) async {
    // Consider factors:
    // - Network connectivity
    // - Device performance
    // - Privacy requirements
    // - Message complexity
    
    final hasNetwork = await _checkNetworkConnectivity();
    final isSimpleQuery = _isSimpleQuery(message);
    final deviceCanHandle = await _checkDeviceCapabilities();
    
    return !hasNetwork || (isSimpleQuery && deviceCanHandle);
  }
}
```

## 5. Data Collection for Training

### User Interaction Logging
```dart
class ChatLogger {
  static void logInteraction(String userMessage, String botResponse, double rating) {
    final interaction = {
      'timestamp': DateTime.now().toIso8601String(),
      'user_message': userMessage,
      'bot_response': botResponse,
      'user_rating': rating,
      'session_id': _generateSessionId(),
    };
    
    // Store locally and sync to cloud when possible
    _storeInteraction(interaction);
  }
  
  static Future<void> exportTrainingData() async {
    final interactions = await _getStoredInteractions();
    final trainingData = interactions.map((interaction) => {
      'messages': [
        {'role': 'system', 'content': 'You are MenstruAI...'},
        {'role': 'user', 'content': interaction['user_message']},
        {'role': 'assistant', 'content': interaction['bot_response']},
      ]
    }).toList();
    
    // Export as JSONL for fine-tuning
    await _exportAsJSONL(trainingData);
  }
}
```

## 6. Performance Monitoring

```dart
class LLMPerformanceMonitor {
  static void trackResponse(String message, String response, Duration latency) {
    final metrics = {
      'response_time_ms': latency.inMilliseconds,
      'message_length': message.length,
      'response_length': response.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Send to analytics
    _sendMetrics(metrics);
  }
  
  static void trackUserSatisfaction(String responseId, int rating) {
    final feedback = {
      'response_id': responseId,
      'rating': rating,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _sendFeedback(feedback);
  }
}
```

## 7. Privacy and Security Considerations

### Data Encryption
```dart
class SecureChatService {
  Future<String> encryptMessage(String message) async {
    // Encrypt sensitive health data before sending to cloud
    final key = await _getEncryptionKey();
    return await _encrypt(message, key);
  }
  
  Future<String> decryptResponse(String encryptedResponse) async {
    final key = await _getEncryptionKey();
    return await _decrypt(encryptedResponse, key);
  }
  
  // For local storage of training data
  Future<void> storeSecurely(Map<String, dynamic> data) async {
    final encrypted = await encryptMessage(jsonEncode(data));
    await _secureStorage.write(key: 'chat_data', value: encrypted);
  }
}
```

## 8. Cost Optimization Strategies

### Smart Caching
```dart
class SmartCacheService {
  final Map<String, String> _responseCache = {};
  
  Future<String> getCachedOrGenerate(String message) async {
    // Check for similar questions
    final cachedResponse = _findSimilarResponse(message);
    if (cachedResponse != null) {
      return cachedResponse;
    }
    
    // Generate new response
    final response = await _generateResponse(message);
    _cacheResponse(message, response);
    return response;
  }
  
  String? _findSimilarResponse(String message) {
    // Use semantic similarity to find cached responses
    // This reduces API calls for similar questions
  }
}
```

## 9. Testing and Validation

### A/B Testing Framework
```dart
class LLMTestingFramework {
  Future<String> getResponse(String message) async {
    final testGroup = await _getUserTestGroup();
    
    switch (testGroup) {
      case 'fine_tuned':
        return await _fineTunedService.sendMessage(message);
      case 'base_model':
        return await _baseModelService.sendMessage(message);
      case 'local_model':
        return await _localService.generateResponse(message);
      default:
        return await _defaultService.sendMessage(message);
    }
  }
}
```

## 10. Deployment Checklist

- [ ] Fine-tuned model trained and validated
- [ ] API endpoints configured and tested
- [ ] Local model optimized for mobile
- [ ] Privacy and security measures implemented
- [ ] Performance monitoring in place
- [ ] Fallback mechanisms working
- [ ] Cost monitoring and alerts set up
- [ ] User feedback collection implemented
- [ ] A/B testing framework ready
- [ ] Documentation and maintenance plan created

## Recommended Starting Point

1. **Begin with Cloud API** (OpenAI or Gemini) for quick implementation
2. **Collect user interactions** for training data
3. **Fine-tune model** after collecting 1000+ quality interactions
4. **Implement local model** for privacy-sensitive queries
5. **Optimize based on user feedback** and performance metrics
