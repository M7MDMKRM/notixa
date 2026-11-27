import 'package:uuid/uuid.dart';
import 'package:notixa/core/domain/result.dart';
import 'package:notixa/features/calendar/domain/models/meeting.dart';
import 'package:notixa/features/wallet/domain/models/transaction.dart';
import '../models/extracted_note.dart';

/// Intelligent Multi-Item AI & NLP Extraction Engine
/// Specially optimized for Egyptian Arabic dialect and compound multi-expense sentences.
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

    // Regex to match numbers with optional currency symbols/words
    final numPattern = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:جنية|جنيه|ج|ج\.م|دولار|dollar|egp|usd|\$|ريال|sar|درهم|aed)?',
      caseSensitive: false,
    );

    final matches = numPattern.allMatches(text).toList();

    int lastEnd = 0;
    for (int i = 0; i < matches.length; i++) {
      final m = matches[i];
      final amount = double.tryParse(m.group(1) ?? '') ?? 0.0;
      if (amount <= 0) continue;

      // Extract clause from previous match end to current match end
      final rawClause = text.substring(lastEnd, m.end).trim();
      lastEnd = m.end;

      // Clean leading connectors (e.g. 'و', 'ثم', commas)
      String cleanClause = rawClause.replaceFirst(RegExp(r'^[و\s،,]+'), '').trim();
      final lower = cleanClause.toLowerCase();

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

      // Detect Category & Type (Income vs Expense)
      String category = 'عام';
      bool isIncome = false;

      // Check if it's an initial amount / income
      if (lower.contains('معايا') || lower.contains('نزلت ب') || lower.contains('استلمت') || 
          lower.contains('قبضت') || lower.contains('جالي') || lower.contains('دخل') || 
          lower.contains('حولي') || lower.contains('حولتلي') || lower.contains('مكافأة') ||
          lower.contains('received') || lower.contains('income') || lower.contains('salary')) {
        // Only mark income if it doesn't also explicitly say spent/ate/recharged in the same clause
        if (!lower.contains('فطرت') && !lower.contains('شحنت') && !lower.contains('مواصلات') && !lower.contains('صرفت')) {
          isIncome = true;
          category = 'رصيد أولي / مستلم';
        }
      }

      // Check Specific Expense Categories
      if (lower.contains('فطار') || lower.contains('فطرت') || lower.contains('أكل') || 
          lower.contains('غدا') || lower.contains('غداء') || lower.contains('عشا') || 
          lower.contains('عشاء') || lower.contains('ساندوتش') || lower.contains('قهوة') || 
          lower.contains('شاي') || lower.contains('مطعم') || lower.contains('عصير') ||
          lower.contains('food') || lower.contains('coffee')) {
        category = 'طعام ومشروبات (Food & Drinks)';
        isIncome = false;
      } else if (lower.contains('مواصلات') || lower.contains('ركبت') || lower.contains('تاكسي') || 
                 lower.contains('أوبر') || lower.contains('مترو') || lower.contains('بنزين') || 
                 lower.contains('ميكروباص') || lower.contains('اتوبيس') || lower.contains('transport') ||
                 lower.contains('uber')) {
        category = 'مواصلات وتنقل (Transportation)';
        isIncome = false;
      } else if (lower.contains('كارت') || lower.contains('فكه') || lower.contains('فكة') || 
                 lower.contains('شحنت') || lower.contains('رصيد') || lower.contains('فاتورة') || 
                 lower.contains('كهربا') || lower.contains('مياه') || lower.contains('غاز') || 
                 lower.contains('نت') || lower.contains('باقة') || lower.contains('recharge') ||
                 lower.contains('bills')) {
        category = 'شحن وفواتير (Bills & Recharge)';
        isIncome = false;
      } else if (lower.contains('سوبرماركت') || lower.contains('اشتريت') || lower.contains('جبت') || 
                 lower.contains('تسوق') || lower.contains('هدوم') || lower.contains('لبس') || 
                 lower.contains('shopping') || lower.contains('market')) {
        category = 'تسوق ومشتريات (Shopping)';
        isIncome = false;
      }

      // Generate a user-friendly note description
      String noteDescription = cleanClause;
      if (noteDescription.length > 50) {
        // Try to shorten to the relevant action
        if (category.contains('طعام')) {
          noteDescription = 'فطار وأكل ومشروبات';
        } else if (category.contains('مواصلات')) {
          noteDescription = 'مواصلات وتنقلات';
        } else if (category.contains('شحن')) {
          noteDescription = 'شحن كارت فكة ورصيد';
        } else if (isIncome) {
          noteDescription = 'رصيد ومبلغ أولي';
        }
      }

      transactions.add(Transaction(
        id: _uuid.v4(),
        amount: amount,
        type: isIncome ? TransactionType.received : TransactionType.spent,
        category: category,
        currency: currency,
        note: noteDescription,
        date: DateTime.now(),
      ));
    }

    // Check for Meetings in text
    final lowerFull = text.toLowerCase();
    if (lowerFull.contains('اجتماع') || lowerFull.contains('meeting') || 
        lowerFull.contains('موعد') || lowerFull.contains('ميعاد') || 
        lowerFull.contains('ميتنج') || lowerFull.contains('مقابلة')) {
      final now = DateTime.now();
      int targetHour = now.hour + 2;
      int targetMinute = 0;

      final timeMatch = RegExp(r'الساعة\s*(\d{1,2})(?::(\d{2}))?').firstMatch(lowerFull);
      if (timeMatch != null) {
        int parsedHour = int.tryParse(timeMatch.group(1)!) ?? targetHour;
        if (lowerFull.contains('العصر') || lowerFull.contains('الظهر') || 
            lowerFull.contains('المغرب') || lowerFull.contains('بالليل') || 
            lowerFull.contains('مساء')) {
          if (parsedHour < 12) parsedHour += 12;
        }
        targetHour = parsedHour % 24;
        targetMinute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      }

      final startTime = DateTime(now.year, now.month, now.day, targetHour, targetMinute);

      meetings.add(Meeting(
        id: _uuid.v4(),
        title: 'اجتماع مسجل',
        description: text,
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 1)),
        repetition: 'none',
        hasAlarm: true,
      ));
    }

    return Success(ExtractedNote(
      rawText: text,
      audioPath: audioPath,
      extractedTransactions: transactions,
      extractedMeetings: meetings,
      createdAt: DateTime.now(),
    ));
  }
}
