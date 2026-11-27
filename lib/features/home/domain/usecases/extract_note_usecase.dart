import 'package:uuid/uuid.dart';
import 'package:notixa/core/domain/result.dart';
import 'package:notixa/features/calendar/domain/models/meeting.dart';
import 'package:notixa/features/wallet/domain/models/transaction.dart';
import '../models/extracted_note.dart';

/// Intelligent Multi-Item AI & NLP Extraction Engine
/// Specially optimized for Arabic/Egyptian dialect and English financial and scheduling sentences.
class ExtractNoteUsecase {
  final Uuid _uuid = const Uuid();

  ExtractNoteUsecase([dynamic _]);

  Future<Result<ExtractedNote>> call({required String rawText, String? audioPath}) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return Success(ExtractedNote(
        rawText: rawText,
        audioPath: audioPath,
        extractedTransactions: const [],
        extractedMeetings: const [],
        createdAt: DateTime.now(),
      ));
    }

    final transactions = <Transaction>[];
    final meetings = <Meeting>[];

    // Normalize text: replace commas, arabic commas, and common delimiters
    String normalized = text
        .replaceAll('،', ' , ')
        .replaceAll(';', ' , ')
        .replaceAll('\n', ' , ')
        .replaceAll(RegExp(r'\s+و\s+'), ' , ') // " و " as separator
        .replaceAll(RegExp(r'\s+ثم\s+'), ' , ')
        .replaceAll(RegExp(r'\s+وبعدين\s+'), ' , ')
        .replaceAll(RegExp(r'\s+بعدها\s+'), ' , ');

    final clauses = normalized
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    for (final clause in clauses) {
      final lower = clause.toLowerCase();

      // 1. Extract Financial Transactions
      final transaction = _parseTransactionClause(lower, clause);
      if (transaction != null) {
        transactions.add(transaction);
        continue;
      }

      // 2. Extract Calendar Meetings / Appointments
      final meeting = _parseMeetingClause(lower, clause);
      if (meeting != null) {
        meetings.add(meeting);
      }
    }

    // If whole sentence had only 1 amount but clauses split awkwardly, fallback check on full text
    if (transactions.isEmpty) {
      final fallbackTx = _parseTransactionClause(text.toLowerCase(), text);
      if (fallbackTx != null) {
        transactions.add(fallbackTx);
      }
    }

    return Success(ExtractedNote(
      rawText: text,
      audioPath: audioPath,
      extractedTransactions: transactions,
      extractedMeetings: meetings,
      createdAt: DateTime.now(),
    ));
  }

  Transaction? _parseTransactionClause(String lower, String original) {
    // Look for numbers representing currency amounts
    final amountRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:جنية|جنيه|ج|ج\.م|دولار|dollar|egp|usd|\$|ريال|sar|درهم|aed)?');
    final match = amountRegex.firstMatch(lower);

    if (match == null) return null;

    final amountStr = match.group(1);
    final amount = double.tryParse(amountStr ?? '') ?? 0.0;
    if (amount <= 0) return null;

    // Detect Currency
    String currency = 'EGP';
    if (lower.contains('دولار') || lower.contains('dollar') || lower.contains('usd') || lower.contains('\$')) {
      currency = 'USD';
    } else if (lower.contains('ريال') || lower.contains('sar')) {
      currency = 'SAR';
    } else if (lower.contains('درهم') || lower.contains('aed')) {
      currency = 'AED';
    } else if (lower.contains('يورو') || lower.contains('eur') || lower.contains('€')) {
      currency = 'EUR';
    }

    // Detect Type: Income (Received) vs Expense (Spent)
    bool isIncome = false;
    final incomeKeywords = [
      'معايا', 'نزلت بـ', 'نزلت معايا', 'محفظتي فيها', 'استلمت', 'قبضت', 'جالي', 
      'حولي', 'حولتلي', 'دخل', 'مكافأة', 'رصيد أولي', 'received', 'income', 'salary', 'got'
    ];
    for (final kw in incomeKeywords) {
      if (lower.contains(kw)) {
        isIncome = true;
        break;
      }
    }

    // Detect Category
    String category = 'عام (General)';
    if (lower.contains('فطار') || lower.contains('فطرت') || lower.contains('غدا') || 
        lower.contains('غداء') || lower.contains('عشا') || lower.contains('عشاء') || 
        lower.contains('أكل') || lower.contains('ساندوتش') || lower.contains('قهوة') || 
        lower.contains('شاي') || lower.contains('عصير') || lower.contains('مطعم') || 
        lower.contains('food') || lower.contains('coffee')) {
      category = 'طعام ومشروبات (Food & Drinks)';
    } else if (lower.contains('كارت') || lower.contains('فكة') || lower.contains('شحنت') || 
               lower.contains('رصيد') || lower.contains('فاتورة') || lower.contains('كهربا') || 
               lower.contains('مياه') || lower.contains('غاز') || lower.contains('نت') || 
               lower.contains('bills') || lower.contains('recharge')) {
      category = 'شحن وفواتير (Bills & Recharge)';
    } else if (lower.contains('ركبت') || lower.contains('مواصلات') || lower.contains('تاكسي') || 
               lower.contains('أوبر') || lower.contains('بنزين') || lower.contains('مترو') || 
               lower.contains('ميكروباص') || lower.contains('transport') || lower.contains('uber')) {
      category = 'مواصلات وتنقل (Transportation)';
    } else if (lower.contains('سوبرماركت') || lower.contains('اشتريت') || lower.contains('جبت') || 
               lower.contains('هدوم') || lower.contains('لبس') || lower.contains('تسوق') || 
               lower.contains('shopping') || lower.contains('market')) {
      category = 'تسوق ومشتريات (Shopping)';
    } else if (isIncome) {
      category = 'إيراد ورصيد (Income & Balance)';
    }

    return Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: isIncome ? TransactionType.received : TransactionType.spent,
      category: category,
      currency: currency,
      note: original.trim(),
      date: DateTime.now(),
    );
  }

  Meeting? _parseMeetingClause(String lower, String original) {
    final meetingKeywords = ['اجتماع', 'meeting', 'موعد', 'ميعاد', 'ميتنج', 'call', 'مقابلة', 'جلسة'];
    bool hasMeeting = meetingKeywords.any((kw) => lower.contains(kw));
    if (!hasMeeting) return null;

    final now = DateTime.now();
    int targetHour = now.hour + 2;
    int targetMinute = 0;

    // Detect time (e.g., "الساعة 4", "الساعة 10", "4 العصر", "5 المغرب")
    final timeMatch = RegExp(r'الساعة\s*(\d{1,2})(?::(\d{2}))?').firstMatch(lower);
    if (timeMatch != null) {
      int parsedHour = int.tryParse(timeMatch.group(1)!) ?? targetHour;
      if (lower.contains('العصر') || lower.contains('الظهر') || lower.contains('المغرب') || lower.contains('بالليل') || lower.contains('مساء')) {
        if (parsedHour < 12) parsedHour += 12;
      }
      targetHour = parsedHour % 24;
      targetMinute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
    }

    final startTime = DateTime(now.year, now.month, now.day, targetHour, targetMinute);

    return Meeting(
      id: _uuid.v4(),
      title: original.length > 35 ? original.substring(0, 35) : original,
      description: original,
      startTime: startTime,
      endTime: startTime.add(const Duration(hours: 1)),
      repetition: 'none',
      hasAlarm: true,
    );
  }
}
