class CycleData {
  DateTime periodStartDate;
  DateTime periodEndDate;
  int cycleLength;
  List<String> symptoms;
  String mood;
  String flowIntensity;
  bool isFertile;

  CycleData({
    required this.periodStartDate,
    required this.periodEndDate,
    required this.cycleLength,
    this.symptoms = const [],
    this.mood = '',
    this.flowIntensity = 'medium',
    this.isFertile = false,
  });
}