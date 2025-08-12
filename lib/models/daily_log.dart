import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLog {
  String? id; // Firestore document ID
  DateTime date;
  String? flowIntensity; // 'Light', 'Normal', 'Heavy', 'Spotting'
  String?
  mood; // 'Happy', 'Sad', 'Anxious', 'Stressed', 'Calm', 'Energetic', 'Tired'
  List<String>
  symptoms; // 'Cramps', 'Headache', 'Bloating', 'Nausea', 'Back Pain', etc.
  String? notes;

  DailyLog({
    this.id,
    required this.date,
    this.flowIntensity,
    this.mood,
    this.symptoms = const [],
    this.notes,
  });

  // Convert DailyLog to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      ), // Store only date part
      'flowIntensity': flowIntensity,
      'mood': mood,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // Create DailyLog from Firestore document
  factory DailyLog.fromMap(Map<String, dynamic> map, String documentId) {
    return DailyLog(
      id: documentId,
      date: (map['date'] as Timestamp).toDate(),
      flowIntensity: map['flowIntensity'],
      mood: map['mood'],
      symptoms: List<String>.from(map['symptoms'] ?? []),
      notes: map['notes'],
    );
  }

  // Create DailyLog from Firestore DocumentSnapshot
  factory DailyLog.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyLog.fromMap(data, doc.id);
  }

  // Helper method to get display text for flow intensity
  String get flowDisplayText {
    switch (flowIntensity) {
      case 'Light':
        return 'Light Flow';
      case 'Normal':
        return 'Normal Flow';
      case 'Heavy':
        return 'Heavy Flow';
      case 'Spotting':
        return 'Spotting';
      default:
        return 'No Flow';
    }
  }

  // Helper method to get display text for mood
  String get moodDisplayText {
    return mood ?? 'Not Logged';
  }

  // Helper method to get symptoms as formatted string
  String get symptomsDisplayText {
    if (symptoms.isEmpty) return 'No Symptoms';
    return symptoms.join(', ');
  }

  // Check if this log has any data
  bool get hasData {
    return flowIntensity != null ||
        mood != null ||
        symptoms.isNotEmpty ||
        (notes != null && notes!.trim().isNotEmpty);
  }
}
