import 'package:cloud_firestore/cloud_firestore.dart';

class CycleData {
  String? id; // Firestore document ID
  DateTime periodStartDate;
  DateTime? periodEndDate;
  int cycleLength;
  int periodLength;
  List<String> symptoms;
  String mood;
  String flowIntensity;
  bool isFertile;
  String? notes;

  CycleData({
    this.id,
    required this.periodStartDate,
    this.periodEndDate,
    required this.cycleLength,
    this.periodLength = 5,
    this.symptoms = const [],
    this.mood = '',
    this.flowIntensity = 'Normal',
    this.isFertile = false,
    this.notes,
  });

  // Convert CycleData to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'periodStartDate': Timestamp.fromDate(periodStartDate),
      'periodEndDate': periodEndDate != null
          ? Timestamp.fromDate(periodEndDate!)
          : null,
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'symptoms': symptoms,
      'mood': mood,
      'flowIntensity': flowIntensity,
      'isFertile': isFertile,
      'notes': notes,
      'createdAt': Timestamp.now(),
    };
  }

  // Create CycleData from Firestore document
  factory CycleData.fromMap(Map<String, dynamic> map, String documentId) {
    return CycleData(
      id: documentId,
      periodStartDate: (map['periodStartDate'] as Timestamp).toDate(),
      periodEndDate: map['periodEndDate'] != null
          ? (map['periodEndDate'] as Timestamp).toDate()
          : null,
      cycleLength: map['cycleLength'] ?? 28,
      periodLength: map['periodLength'] ?? 5,
      symptoms: List<String>.from(map['symptoms'] ?? []),
      mood: map['mood'] ?? '',
      flowIntensity: map['flowIntensity'] ?? 'Normal',
      isFertile: map['isFertile'] ?? false,
      notes: map['notes'],
    );
  }

  // Create CycleData from Firestore DocumentSnapshot
  factory CycleData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CycleData.fromMap(data, doc.id);
  }
}
