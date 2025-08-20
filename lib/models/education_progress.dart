import 'package:cloud_firestore/cloud_firestore.dart';

class EducationProgress {
  String? id; // Firestore document ID
  String userId;
  DateTime lastUpdated;

  // Quiz results
  Map<String, QuizResult> quizResults;

  // Content progress
  bool hasViewedTamponGuide;
  List<int> tamponGuideSteps; // Track completed steps
  List<String> viewedVideos;
  List<String> viewedResources;

  // General education stats
  int totalQuizzesTaken;
  int totalQuestionsAnswered;
  int totalCorrectAnswers;

  EducationProgress({
    this.id,
    required this.userId,
    DateTime? lastUpdated,
    this.quizResults = const {},
    this.hasViewedTamponGuide = false,
    this.tamponGuideSteps = const [],
    this.viewedVideos = const [],
    this.viewedResources = const [],
    this.totalQuizzesTaken = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'quizResults': quizResults.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'hasViewedTamponGuide': hasViewedTamponGuide,
      'tamponGuideSteps': tamponGuideSteps,
      'viewedVideos': viewedVideos,
      'viewedResources': viewedResources,
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
    };
  }

  // Create from Firestore document
  factory EducationProgress.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return EducationProgress(
      id: documentId,
      userId: map['userId'] ?? '',
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      quizResults:
          (map['quizResults'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, QuizResult.fromMap(value)),
          ) ??
          {},
      hasViewedTamponGuide: map['hasViewedTamponGuide'] ?? false,
      tamponGuideSteps: List<int>.from(map['tamponGuideSteps'] ?? []),
      viewedVideos: List<String>.from(map['viewedVideos'] ?? []),
      viewedResources: List<String>.from(map['viewedResources'] ?? []),
      totalQuizzesTaken: map['totalQuizzesTaken'] ?? 0,
      totalQuestionsAnswered: map['totalQuestionsAnswered'] ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] ?? 0,
    );
  }

  // Create from Firestore DocumentSnapshot
  factory EducationProgress.fromDocument(DocumentSnapshot doc) {
    return EducationProgress.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  // Calculate overall quiz performance percentage
  double get overallQuizPerformance {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }

  // Get the best score for a specific quiz
  double getBestQuizScore(String quizType) {
    final result = quizResults[quizType];
    return result?.bestScore ?? 0.0;
  }

  // Get the latest score for a specific quiz
  double getLatestQuizScore(String quizType) {
    final result = quizResults[quizType];
    return result?.latestScore ?? 0.0;
  }

  // Get times taken for a specific quiz
  int getQuizTimesTaken(String quizType) {
    final result = quizResults[quizType];
    return result?.timesTaken ?? 0;
  }
}

class QuizResult {
  String quizType;
  int timesTaken;
  double bestScore;
  double latestScore;
  DateTime lastTaken;
  List<QuizAttempt> attempts;

  QuizResult({
    required this.quizType,
    this.timesTaken = 0,
    this.bestScore = 0.0,
    this.latestScore = 0.0,
    DateTime? lastTaken,
    this.attempts = const [],
  }) : lastTaken = lastTaken ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'quizType': quizType,
      'timesTaken': timesTaken,
      'bestScore': bestScore,
      'latestScore': latestScore,
      'lastTaken': Timestamp.fromDate(lastTaken),
      'attempts': attempts.map((attempt) => attempt.toMap()).toList(),
    };
  }

  // Create from Firestore data
  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      quizType: map['quizType'] ?? '',
      timesTaken: map['timesTaken'] ?? 0,
      bestScore: (map['bestScore'] ?? 0.0).toDouble(),
      latestScore: (map['latestScore'] ?? 0.0).toDouble(),
      lastTaken: (map['lastTaken'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attempts:
          (map['attempts'] as List<dynamic>?)
              ?.map((attempt) => QuizAttempt.fromMap(attempt))
              .toList() ??
          [],
    );
  }

  // Add a new quiz attempt
  void addAttempt(double score, int totalQuestions, int correctAnswers) {
    final attempt = QuizAttempt(
      score: score,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      dateTaken: DateTime.now(),
    );

    attempts = [...attempts, attempt];
    timesTaken++;
    latestScore = score;
    if (score > bestScore) {
      bestScore = score;
    }
    lastTaken = DateTime.now();
  }
}

class QuizAttempt {
  double score;
  int totalQuestions;
  int correctAnswers;
  DateTime dateTaken;

  QuizAttempt({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.dateTaken,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'dateTaken': Timestamp.fromDate(dateTaken),
    };
  }

  // Create from Firestore data
  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      score: (map['score'] ?? 0.0).toDouble(),
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      dateTaken: (map['dateTaken'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
