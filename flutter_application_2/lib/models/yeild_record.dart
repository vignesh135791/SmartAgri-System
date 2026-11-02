class YieldRecord {
  final String title;
  final DateTime date;
  final double kilograms;
  final double acres;

  YieldRecord({
    required this.title,
    required this.date,
    required this.kilograms,
    required this.acres,
  });

  double get yieldPerAcre => kilograms / acres;

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toIso8601String(),
        'kilograms': kilograms,
        'acres': acres,
      };

  factory YieldRecord.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? json['recorded_date'];
    if (rawDate is! String) {
      throw const FormatException('Yield record is missing a valid date');
    }
    return YieldRecord(
      title: json['title'] as String,
      date: DateTime.parse(rawDate),
      kilograms: (json['kilograms'] as num).toDouble(),
      acres: (json['acres'] as num).toDouble(),
    );
  }
}
