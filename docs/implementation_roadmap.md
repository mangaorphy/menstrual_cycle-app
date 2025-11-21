# 🚀 Step-by-Step LLM Fine-tuning Implementation Guide

## Phase 1: Setup and Data Collection (Week 1-2)

### 1. Configure Your App for Data Collection

```dart
// In lib/config/llm_config.dart
static const bool COLLECT_TRAINING_DATA = true;
static const String PROVIDER = 'demo'; // Start with demo mode
```

### 2. Update Dependencies

```bash
cd /Users/cococe/Desktop/menstrual_cycle-app
flutter pub get
```

### 3. Start Collecting User Interactions

- Deploy your app with the current chatbot
- Users interact with the demo responses
- All conversations are automatically logged
- Encourage users to rate responses (thumbs up/down)

## Phase 2: Training Data Preparation (Week 3)

### 1. Export Training Data from App

```dart
// Add this to your admin panel or debug screen
final trainingData = await TrainingDataService.exportToJSONL(
  onlyHighRated: true,
  minRating: 4,
);
print('Training data exported to: ${trainingData.path}');
```

### 2. Review Data Quality

```dart
final stats = await TrainingDataService.getTrainingStats();
print('Training Statistics:');
print('Total interactions: ${stats['total_interactions']}');
print('High-rated interactions: ${stats['high_rated_interactions']}');
print('Ready for training: ${stats['ready_for_training']}');
```

**Minimum Requirements:**
- ✅ 100+ high-quality interactions (rating 4-5)
- ✅ Diverse topics (period, ovulation, PMS, cycles, etc.)
- ✅ Natural conversation flow
- ✅ Accurate, helpful responses

## Phase 3: Model Fine-tuning (Week 4)

### Option A: OpenAI Fine-tuning (Recommended for beginners)

#### 1. Install Python Dependencies

```bash
pip install openai
```

#### 2. Prepare Training Data

```bash
cd /Users/cococe/Desktop/menstrual_cycle-app
python3 scripts/fine_tune_menstrual_llm.py \
  --api-key YOUR_OPENAI_API_KEY \
  --training-file menstrual_health_training.jsonl \
  --action prepare
```

#### 3. Upload and Start Fine-tuning

```bash
# Upload training file
python3 scripts/fine_tune_menstrual_llm.py \
  --api-key YOUR_OPENAI_API_KEY \
  --training-file menstrual_health_training_cleaned.jsonl \
  --action upload

# Start fine-tuning (save the file ID from previous step)
python3 scripts/fine_tune_menstrual_llm.py \
  --api-key YOUR_OPENAI_API_KEY \
  --action train
```

#### 4. Monitor Progress

```bash
# Check status (save job ID from training step)
python3 scripts/fine_tune_menstrual_llm.py \
  --api-key YOUR_OPENAI_API_KEY \
  --action status \
  --job-id ftjob-XXXXXXXXX
```

### Option B: Google Gemini Fine-tuning

#### 1. Setup Gemini API

```python
pip install google-generativeai
```

#### 2. Create Training Dataset

```python
import google.generativeai as genai

genai.configure(api_key="YOUR_GEMINI_API_KEY")

# Convert your JSONL to Gemini format
training_examples = []
with open('menstrual_health_training.jsonl', 'r') as f:
    for line in f:
        data = json.loads(line)
        example = {
            "input_text": data["messages"][-2]["content"],  # user message
            "output_text": data["messages"][-1]["content"]  # assistant response
        }
        training_examples.append(example)

# Create tuned model
model = genai.create_tuned_model(
    source_model="models/gemini-1.0-pro",
    training_data=training_examples,
    id="menstrual-health-assistant",
    epoch_count=5,
    batch_size=2,
    learning_rate=0.001,
)
```

## Phase 4: Integration and Testing (Week 5)

### 1. Update Flutter Configuration

```dart
// In lib/config/llm_config.dart
static const bool USE_FINE_TUNED_MODEL = true;
static const String PROVIDER = 'openai'; // or 'gemini'
static const String OPENAI_FINE_TUNED_MODEL = 'ft:gpt-3.5-turbo-XXXXXXXXX';
```

### 2. Update API Keys

```dart
// In lib/services/chatbot_service.dart
static const String _openaiApiKey = 'your-actual-api-key';
static const String _fineTunedModelId = 'ft:gpt-3.5-turbo-XXXXXXXXX';
```

### 3. Test the Fine-tuned Model

```bash
python3 scripts/fine_tune_menstrual_llm.py \
  --api-key YOUR_OPENAI_API_KEY \
  --action test \
  --model-id ft:gpt-3.5-turbo-XXXXXXXXX
```

### 4. A/B Testing in App

```dart
// Test both models to compare performance
class ABTestingChatbot {
  Future<String> getResponse(String message) async {
    if (Random().nextBool()) {
      return await _fineTunedService.sendMessage(message);
    } else {
      return await _baseModelService.sendMessage(message);
    }
  }
}
```

## Phase 5: Deployment and Optimization (Week 6+)

### 1. Deploy to Production

```dart
// Update your app configuration
static const bool USE_CLOUD_API = true;
static const bool USE_FINE_TUNED_MODEL = true;
```

### 2. Monitor Performance

```dart
// Track key metrics
- Response accuracy (user ratings)
- Response time
- API costs
- User engagement
```

### 3. Continuous Improvement

```dart
// Set up continuous data collection
static const bool COLLECT_TRAINING_DATA = true; // Keep collecting
static const bool ENABLE_USER_FEEDBACK = true; // Get feedback

// Monthly fine-tuning updates with new data
```

## Cost Estimation

### OpenAI Fine-tuning Costs (approximate):

- **Training**: $0.008 per 1K tokens (~$8 for 1M tokens)
- **Usage**: $0.012 per 1K tokens (input) + $0.016 per 1K tokens (output)
- **Monthly estimate**: $50-200 for moderate usage (1000-10000 requests)

### Google Gemini Costs:

- **Training**: Free for up to 100 examples, then $0.002 per example
- **Usage**: Free tier: 60 queries per minute, then paid
- **Monthly estimate**: $0-100 for moderate usage

## Alternative: Local Model Deployment

For privacy-focused or offline-capable apps:

### 1. Use Smaller Models

```python
# Convert to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_saved_model(model_path)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()
```

### 2. Edge Deployment

```dart
// Add to pubspec.yaml
dependencies:
  tflite_flutter: ^0.10.4

// Use in app
class LocalLLMService {
  late Interpreter interpreter;
  
  Future<String> generateResponse(String input) async {
    // Load and run TFLite model
    final output = await interpreter.run(preprocessInput(input));
    return postprocessOutput(output);
  }
}
```

## Success Metrics to Track

1. **Response Quality**
   - User satisfaction ratings (>4.0/5.0)
   - Response relevance scores
   - Medical accuracy (expert review)

2. **Performance**
   - Response time (<2 seconds)
   - API success rate (>99%)
   - Cost per interaction (<$0.01)

3. **User Engagement**
   - Daily active users using chatbot
   - Messages per session
   - Retention rate

## Next Steps for Your App

1. **Week 1**: Enable data collection, deploy current demo chatbot
2. **Week 2**: Gather user feedback, improve demo responses
3. **Week 3**: Export training data, review quality
4. **Week 4**: Fine-tune your first model
5. **Week 5**: Integrate and test fine-tuned model
6. **Week 6**: Deploy to production with monitoring

## Tips for Success

1. **Start Simple**: Begin with the demo chatbot to collect data
2. **Quality over Quantity**: 100 high-quality interactions > 1000 poor ones
3. **User Feedback**: Make it easy for users to rate responses
4. **Iterate Quickly**: Update your model monthly with new data
5. **Monitor Costs**: Set up billing alerts and usage limits
6. **Privacy First**: Always anonymize sensitive health data

Your menstrual health app will have a specialized, empathetic AI assistant that understands the unique needs of your users! 🌸
