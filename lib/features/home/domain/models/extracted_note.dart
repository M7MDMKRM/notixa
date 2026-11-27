import 'package:equatable/equatable.dart';
import '../../calendar/domain/models/meeting.dart';
import '../../wallet/domain/models/transaction.dart';

class ExtractedNote extends Equatable {
  final String rawText;
  final String? audioPath;
  final List<Transaction> extractedTransactions;
  final List<Meeting> extractedMeetings;
  final DateTime createdAt;

  const ExtractedNote({
    required this.rawText,
    this.audioPath,
    this.extractedTransactions = const [],
    this.extractedMeetings = const [],
    required this.createdAt,
  });

  factory ExtractedNote.fromJson(Map<String, dynamic> json) {
    return ExtractedNote(
      rawText: json['raw_text'] as String? ?? json['transcript'] as String? ?? '',
      audioPath: json['audio_path'] as String?,
      extractedTransactions: (json['transactions'] as List? ?? [])
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      extractedMeetings: (json['meetings'] as List? ?? [])
          .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw_text': rawText,
      'audio_path': audioPath,
      'transactions': extractedTransactions.map((e) => e.toJson()).toList(),
      'meetings': extractedMeetings.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [rawText, audioPath, extractedTransactions, extractedMeetings, createdAt];
}
