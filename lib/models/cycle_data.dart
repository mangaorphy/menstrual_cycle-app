import 'package:cloud_firestore/cloud_firestore.dart';

class CycleData {
  String? id; // Firestore document ID
  DateTime periodStartDate;
  DateTime periodEndDate;
  int cycleLength;
  List<String> symptoms;
  String mood;
  String flowIntensity;
  bool isFertile;

  CycleData({
    this.id,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.cycleLength,
    this.symptoms = const [],
    this.mood = '',
    this.flowIntensity = 'medium',
    this.isFertile = false,
  });

  // Convert CycleData to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'periodStartDate': Timestamp.fromDate(periodStartDate),
      'periodEndDate': Timestamp.fromDate(periodEndDate),
      'cycleLength': cycleLength,
      'symptoms': symptoms,
      'mood': mood,
      'flowIntensity': flowIntensity,
      'isFertile': isFertile,
      'createdAt': Timestamp.now(),
    };
  }

  // Create CycleData from Firestore document
  factory CycleData.fromMap(Map<String, dynamic> map, String documentId) {
    return CycleData(
      id: documentId,
      periodStartDate: (map['periodStartDate'] as Timestamp).toDate(),
      periodEndDate: (map['periodEndDate'] as Timestamp).toDate(),
      cycleLength: map['cycleLength'] ?? 28,
      symptoms: List<String>.from(map['symptoms'] ?? []),
      mood: map['mood'] ?? '',
      flowIntensity: map['flowIntensity'] ?? 'medium',
      isFertile: map['isFertile'] ?? false,
    );
  }

  // Create CycleData from Firestore DocumentSnapshot
  factory CycleData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CycleData.fromMap(data, doc.id);
  }
}
