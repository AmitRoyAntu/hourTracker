class HourEntry {
  final DateTime date;
  final int hour;
  final String activity;

  HourEntry({
    required this.date,
    required this.hour,
    required this.activity,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'hour': hour,
      'activity': activity,
    };
  }

  factory HourEntry.fromJson(Map<String, dynamic> json) {
    return HourEntry(
      date: DateTime.parse(json['date']),
      hour: json['hour'],
      activity: json['activity'],
    );
  }

  String get key => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_$hour';
}
