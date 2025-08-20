import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLog {
  String? id; // Firestore document ID
  DateTime date;
  String? flowIntensity; // 'Light', 'Normal', 'Heavy', 'Spotting'
  List<String>? moods; // List of moods
  List<String>?
  symptoms; // 'Cramps', 'Headache', 'Bloating', 'Nausea', 'Back Pain', etc.
  String? notes;

  DailyLog({
    this.id,
    required this.date,
    this.flowIntensity,
    this.moods,
    this.symptoms,
    this.notes,
  });

  // Helper getter to check if there's any data logged
  bool get hasData =>
      flowIntensity != null ||
      (moods != null && moods!.isNotEmpty) ||
      (symptoms != null && symptoms!.isNotEmpty) ||
      (notes != null && notes!.isNotEmpty);

  // Helper for display text
  String get flowDisplayText => flowIntensity ?? 'Not logged';
  String get moodDisplayText {
    if (moods == null || moods!.isEmpty) {
      return 'Not logged';
    }
    return moods!.join(', ');
  }

  // Convert DailyLog to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      ), // Store only date part
      'flowIntensity': flowIntensity,
      'moods': moods,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create DailyLog from Firestore document
  factory DailyLog.fromMap(Map<String, dynamic> map, String documentId) {
    return DailyLog(
      id: documentId,
      date: (map['date'] as Timestamp).toDate(),
      flowIntensity: map['flowIntensity'],
      moods: map['moods'] != null ? List<String>.from(map['moods']) : null,
      symptoms: map['symptoms'] != null
          ? List<String>.from(map['symptoms'])
          : null,
      notes: map['notes'],
    );
  }

  // Create DailyLog from Firestore DocumentSnapshot
  factory DailyLog.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyLog.fromMap(data, doc.id);
  }
}
