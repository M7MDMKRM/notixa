import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/domain/result.dart';
import '../../../calendar/domain/models/meeting.dart';
import '../../../wallet/domain/models/transaction.dart';
import '../models/extracted_note.dart';

class ExtractNoteUsecase {
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  ExtractNoteUsecase(this._dio);

  Future<Result<ExtractedNote>> call({required String rawText, String? audioPath}) async {
    // 1. Try remote AI backend
    try {
      final response = await _dio.post('/notes/extract', data: {
        'text': rawText,
        if (audioPath != null) 'audio_path': audioPath,
      });

      if (response.statusCode == 200 && response.data != null) {
        return Success(ExtractedNote.fromJson(response.data as Map<String, dynamic>));
      }
    } catch (_) {}

    // 2. Intelligent Offline Fallback NLP Parser
    final transactions = <Transaction>[];
    final meetings = <Meeting>[];

    final lower = rawText.toLowerCase();

    // Check for Expense / Income keywords
    final spentMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:جنية|جنيه|دولار|dollar|egp|usd|\$|ريال|sar)').firstMatch(lower);
    if (spentMatch != null) {
      final amount = double.tryParse(spentMatch.group(1)!) ?? 0.0;
      final isReceived = lower.contains('استلمت') || lower.contains('قبضت') || lower.contains('received') || lower.contains('salary');

      transactions.add(Transaction(
        id: _uuid.v4(),
        amount: amount,
        type: isReceived ? TransactionType.received : TransactionType.spent,
        category: lower.contains('قهوة') || lower.contains('coffee') || lower.contains('أكل') || lower.contains('food')
            ? 'Food & Drinks'
            : (lower.contains('سوبرماركت') || lower.contains('groceries') ? 'Shopping' : 'General'),
        note: rawText,
        date: DateTime.now(),
      ));
    }

    // Check for Meeting / Appointment keywords
    if (lower.contains('اجتماع') || lower.contains('meeting') || lower.contains('موعد') || lower.contains('appointment') || lower.contains('call')) {
      final now = DateTime.now();
      meetings.add(Meeting(
        id: _uuid.v4(),
        title: rawText.length > 40 ? rawText.substring(0, 40) : rawText,
        description: rawText,
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
        repetition: 'none',
        hasAlarm: true,
      ));
    }

    return Success(ExtractedNote(
      rawText: rawText,
      audioPath: audioPath,
      extractedTransactions: transactions,
      extractedMeetings: meetings,
      createdAt: DateTime.now(),
    ));
  }
}
