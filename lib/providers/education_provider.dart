import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/education_progress.dart';

class EducationProvider with ChangeNotifier {
  EducationProgress? _educationProgress;
  String? _userId;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EducationProgress? get educationProgress => _educationProgress;
  bool get isLoading => _isLoading;

  // Initialize provider
  EducationProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _loadUserId();
    await _loadEducationProgress();
  }

  // Get user ID (same logic as CycleProvider)
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get user ID from Firebase Auth first
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _userId = currentUser.uid;
      await prefs.setString('user_id', _userId!);
    } else {
      // Fall back to persistent user ID from SharedPreferences
      _userId = prefs.getString('user_id');
      if (_userId == null) {
        // Generate a new user ID if none exists
        _userId = DateTime.now().millisecondsSinceEpoch.toString();
        await prefs.setString('user_id', _userId!);
      }
    }
  }

  // Load education progress from Firestore
  Future<void> _loadEducationProgress() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('education_progress')
          .doc('progress')
          .get();

      if (doc.exists) {
        _educationProgress = EducationProgress.fromDocument(doc);
      } else {
        // Create new education progress if none exists
        _educationProgress = EducationProgress(userId: _userId!);
        await _saveEducationProgress();
      }
    } catch (e) {
      print('Error loading education progress: $e');
      // Create default progress if loading fails
      _educationProgress = EducationProgress(userId: _userId!);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save education progress to Firestore
  Future<void> _saveEducationProgress() async {
    if (_educationProgress == null || _userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('education_progress')
          .doc('progress')
          .set(_educationProgress!.toMap());
    } catch (e) {
      print('Error saving education progress: $e');
    }
  }

  // Record quiz completion
  Future<void> recordQuizCompletion({
    required String quizType,
    required int score,
    required int totalQuestions,
  }) async {
    if (_educationProgress == null) return;

    final correctAnswers = score;
    final percentage = (score / totalQuestions * 100);

    // Update or create quiz result
    if (_educationProgress!.quizResults.containsKey(quizType)) {
      _educationProgress!.quizResults[quizType]!.addAttempt(
        percentage,
        totalQuestions,
        correctAnswers,
      );
    } else {
      final quizResult = QuizResult(quizType: quizType);
      quizResult.addAttempt(percentage, totalQuestions, correctAnswers);
      _educationProgress!.quizResults[quizType] = quizResult;
    }

    // Update overall stats
    _educationProgress!.totalQuizzesTaken++;
    _educationProgress!.totalQuestionsAnswered += totalQuestions;
    _educationProgress!.totalCorrectAnswers += correctAnswers;
    _educationProgress!.lastUpdated = DateTime.now();

    await _saveEducationProgress();
    notifyListeners();
  }

  // Mark tampon guide as viewed
  Future<void> markTamponGuideViewed() async {
    if (_educationProgress == null) return;

    _educationProgress!.hasViewedTamponGuide = true;
    _educationProgress!.lastUpdated = DateTime.now();

    await _saveEducationProgress();
    notifyListeners();
  }

  // Record video viewing
  Future<void> recordVideoViewed(String videoId) async {
    if (_educationProgress == null) return;

    if (!_educationProgress!.viewedVideos.contains(videoId)) {
      _educationProgress!.viewedVideos = [
        ..._educationProgress!.viewedVideos,
        videoId,
      ];
      _educationProgress!.lastUpdated = DateTime.now();

      await _saveEducationProgress();
      notifyListeners();
    }
  }

  // Record resource viewing
  Future<void> recordResourceViewed(String resourceId) async {
    if (_educationProgress == null) return;

    if (!_educationProgress!.viewedResources.contains(resourceId)) {
      _educationProgress!.viewedResources = [
        ..._educationProgress!.viewedResources,
        resourceId,
      ];
      _educationProgress!.lastUpdated = DateTime.now();

      await _saveEducationProgress();
      notifyListeners();
    }
  }

  // Get quiz statistics for display
  Map<String, dynamic> getQuizStatistics() {
    if (_educationProgress == null) {
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'bestQuizType': 'None',
        'totalQuestions': 0,
      };
    }

    double averageScore = _educationProgress!.overallQuizPerformance;
    String bestQuizType = 'None';
    double bestScore = 0.0;

    // Find best performing quiz type
    _educationProgress!.quizResults.forEach((quizType, result) {
      if (result.bestScore > bestScore) {
        bestScore = result.bestScore;
        bestQuizType = quizType;
      }
    });

    return {
      'totalQuizzes': _educationProgress!.totalQuizzesTaken,
      'averageScore': averageScore,
      'bestQuizType': bestQuizType,
      'totalQuestions': _educationProgress!.totalQuestionsAnswered,
    };
  }

  // Check if user has viewed specific content
  bool hasViewedTamponGuide() {
    return _educationProgress?.hasViewedTamponGuide ?? false;
  }

  bool hasViewedVideo(String videoId) {
    return _educationProgress?.viewedVideos.contains(videoId) ?? false;
  }

  bool hasViewedResource(String resourceId) {
    return _educationProgress?.viewedResources.contains(resourceId) ?? false;
  }

  // Get quiz completion count for specific quiz type
  int getQuizCompletionCount(String quizType) {
    return _educationProgress?.getQuizTimesTaken(quizType) ?? 0;
  }

  // Get best score for specific quiz type
  double getBestScore(String quizType) {
    return _educationProgress?.getBestQuizScore(quizType) ?? 0.0;
  }

  // Get latest score for specific quiz type
  double getLatestScore(String quizType) {
    return _educationProgress?.getLatestQuizScore(quizType) ?? 0.0;
  }

  // Tampon guide step tracking
  bool isTamponGuideStepCompleted(int step) {
    return _educationProgress?.tamponGuideSteps.contains(step) ?? false;
  }

  Future<void> markTamponGuideStepCompleted(int step) async {
    if (_educationProgress == null) return;

    if (!_educationProgress!.tamponGuideSteps.contains(step)) {
      _educationProgress!.tamponGuideSteps = [
        ..._educationProgress!.tamponGuideSteps,
        step,
      ];
      _educationProgress!.lastUpdated = DateTime.now();

      await _saveEducationProgress();
      notifyListeners();
    }
  }

  // Video watching
  bool isVideoWatched(String videoId) {
    return _educationProgress?.viewedVideos.contains(videoId) ?? false;
  }

  Future<void> markVideoWatched(String videoId) async {
    await recordVideoViewed(videoId);
  }

  // Quiz score helpers
  int getQuizScore(String quizId) {
    return getLatestScore(quizId).round();
  }

  // Refresh education progress from Firestore
  Future<void> refreshEducationProgress() async {
    await _loadEducationProgress();
  }

  // Reset all education progress (for testing or user request)
  Future<void> resetEducationProgress() async {
    if (_userId == null) return;

    _educationProgress = EducationProgress(userId: _userId!);
    await _saveEducationProgress();
    notifyListeners();
  }

  // New methods for the improved insights screen
  double getOverallQuizProgress() {
    if (_educationProgress == null) return 0.0;
    final totalQuizzes = getTotalQuizCount();
    if (totalQuizzes == 0) return 0.0;
    return getCompletedQuizCount() / totalQuizzes;
  }

  int getTotalWatchTime() {
    return (_educationProgress?.viewedVideos.length ?? 0) *
        5; // Assume 5 min per video
  }

  int getCompletedQuizCount() {
    return _educationProgress?.quizResults.length ?? 0;
  }

  int getTotalQuizCount() {
    return 4; // Based on the quizzes in the app
  }

  int getWatchedVideoCount() {
    return _educationProgress?.viewedVideos.length ?? 0;
  }

  int getTotalVideoCount() {
    return 4; // Based on the videos in the app
  }

  int getExploredResourceCount() {
    return _educationProgress?.viewedResources.length ?? 0;
  }

  int getTotalResourceCount() {
    return 6; // Based on the resources in the app
  }

  List<String> getUnlockedAchievements() {
    List<String> achievements = [];

    // Quiz achievements
    if (getCompletedQuizCount() >= 1) {
      achievements.add('First Quiz');
    }
    if (getCompletedQuizCount() >= getTotalQuizCount()) {
      achievements.add('Quiz Master');
    }

    // Video achievements
    if (getWatchedVideoCount() >= 1) {
      achievements.add('Learning Started');
    }
    if (getWatchedVideoCount() >= getTotalVideoCount()) {
      achievements.add('Video Scholar');
    }

    // Resource achievements
    if (getExploredResourceCount() >= 3) {
      achievements.add('Resource Explorer');
    }

    // Overall achievements
    final totalProgress =
        (getCompletedQuizCount() +
        getWatchedVideoCount() +
        getExploredResourceCount());
    if (totalProgress >= 10) {
      achievements.add('Knowledge Seeker');
    }

    return achievements;
  }

  // Additional methods for video tracking
  int getCompletedVideoCount() {
    return _educationProgress?.viewedVideos.length ?? 0;
  }

  Future<void> markVideoAsWatched({
    required String videoId,
    required int duration,
  }) async {
    await markVideoWatched(videoId);
    // In a real app, you'd also save the duration
  }
}
