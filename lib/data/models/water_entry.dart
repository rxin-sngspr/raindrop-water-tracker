import 'package:uuid/uuid.dart';

class WaterEntry {
  final String id;
  final DateTime timestamp;
  final int amountMl;

  WaterEntry({
    String? id,
    required this.timestamp,
    required this.amountMl,
  }) : id = id ?? const Uuid().v4();

  WaterEntry copyWith({
    String? id,
    DateTime? timestamp,
    int? amountMl,
  }) {
    return WaterEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      amountMl: amountMl ?? this.amountMl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'amountMl': amountMl,
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        id: json['id'] as String?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        amountMl: json['amountMl'] as int,
      );
}
