class WaterEntry {
  final DateTime timestamp;
  final int amountMl;

  WaterEntry({
    required this.timestamp,
    required this.amountMl,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'amountMl': amountMl,
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        amountMl: json['amountMl'] as int,
      );
}
