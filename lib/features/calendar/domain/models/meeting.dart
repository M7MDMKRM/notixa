import 'package:equatable/equatable.dart';

class Meeting extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String repetition; // 'none', 'daily', 'weekly', 'monthly'
  final bool hasAlarm;

  const Meeting({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.repetition = 'none',
    this.hasAlarm = true,
  });

  Meeting copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? repetition,
    bool? hasAlarm,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repetition: repetition ?? this.repetition,
      hasAlarm: hasAlarm ?? this.hasAlarm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'repetition': repetition,
      'has_alarm': hasAlarm,
    };
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'] as String) ?? DateTime.now()
          : (json['start_timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['start_timestamp'] as int)
              : DateTime.now()),
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'] as String) ?? DateTime.now().add(const Duration(hours: 1))
          : (json['end_timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['end_timestamp'] as int)
              : DateTime.now().add(const Duration(hours: 1))),
      repetition: json['repetition'] as String? ?? 'none',
      hasAlarm: json['has_alarm'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, title, description, startTime, endTime, repetition, hasAlarm];
}
