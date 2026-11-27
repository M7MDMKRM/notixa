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

  /// Normalizes Arabic-Indic digits (٠-٩) to standard ASCII digits (0-9)
  String _normalizeDigits(String input) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const standard = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabicIndic[i], standard[i]);
    }
    return result;
  }

  Future<Result<ExtractedNote>> call({required String rawText, String? audioPath}) async {
    final originalTrimmed = rawText.trim();
    if (originalTrimmed.isEmpty) {
      return Success(ExtractedNote(
        rawText: rawText,
        audioPath: audioPath,
        extractedTransactions: const [],
        extractedMeetings: const [],
        createdAt: DateTime.now(),
      ));
    }

    // Normalize Eastern Arabic numerals
    final text = _normalizeDigits(originalTrimmed);

    final transactions = <Transaction>[];
    final meetings = <Meeting>[];

    // Regex to match numbers with optional currency symbols/words
    final numPattern = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:جنية|جنيه|ج|ج\.م|دولار|dollar|egp|usd|\$|ريال|sar|درهم|aed)?',
      caseSensitive: false,
    );

    final matches = numPattern.allMatches(text).toList();

    for (int i = 0; i < matches.length; i++) {
      final m = matches[i];
      final amount = double.tryParse(m.group(1) ?? '') ?? 0.0;
      if (amount <= 0) continue;

      // Correct clause boundary: from end of previous match to end of current match
      final clauseStart = (i == 0) ? 0 : matches[i - 1].end;
      final clauseEnd = m.end;
      final rawClause = text.substring(clauseStart, clauseEnd).trim();

      // Clean leading connectors
      String cleanClause = rawClause.replaceFirst(RegExp(r'^[و\s،,ثمبعدين]+'), '').trim();
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
      String category = 'عام ومصروفات';
      String noteDescription = 'مصروف متنوع';
      bool isIncome = false;

      // 1. Initial Amount / Income Detection
      final hasIncomeKeywords = lower.contains('معايا') || lower.contains('نزلت ب') || 
                                lower.contains('نزل معايا') || lower.contains('استلمت') || 
                                lower.contains('قبضت') || lower.contains('جالي') || 
                                lower.contains('دخل') || lower.contains('حولي') || 
                                lower.contains('حولتلي') || lower.contains('مكافأة') || 
                                lower.contains('راتب') || lower.contains('مرتب') || 
                                lower.contains('received') || lower.contains('income') || 
                                lower.contains('salary');

      // 2. Food & Drink Detection
      final isDrink = lower.contains('ميه') || lower.contains('مايه') || lower.contains('مياه') || 
                      lower.contains('عصير') || lower.contains('كانز') || lower.contains('بيبسي') || 
                      lower.contains('كولا') || lower.contains('شاي') || lower.contains('قهوة') || 
                      lower.contains('نسكافيه') || lower.contains('شربت') || lower.contains('ازازة');

      final isFood = lower.contains('اكلت') || lower.contains('أكلت') || lower.contains('اكل') || 
                     lower.contains('أكل') || lower.contains('فطار') || lower.contains('فطرت') || 
                     lower.contains('اتغديت') || lower.contains('غدا') || lower.contains('غداء') || 
                     lower.contains('اتعشيت') || lower.contains('عشا') || lower.contains('عشاء') || 
                     lower.contains('ساندوتش') || lower.contains('مطعم') || lower.contains('وجبة') || 
                     lower.contains('حلويات') || lower.contains('شوكولاته') || lower.contains('food') || 
                     lower.contains('coffee') || isDrink;

      // 3. Transportation Detection
      final isTransport = lower.contains('مواصلات') || lower.contains('ركبت') || lower.contains('تاكسي') || 
                          lower.contains('أوبر') || lower.contains('اوبر') || lower.contains('مترو') || 
                          lower.contains('بنزين') || lower.contains('ميكروباص') || lower.contains('اتوبيس') || 
                          lower.contains('عربية') || lower.contains('توصيلة') || lower.contains('قطر') || 
                          lower.contains('تذكرة') || lower.contains('transport') || lower.contains('uber');

      // 4. Bills & Recharge Detection
      final isBills = lower.contains('كارت') || lower.contains('فكه') || lower.contains('فكة') || 
                      lower.contains('فك') || lower.contains('شحنت') || lower.contains('شحن') || 
                      lower.contains('رصيد') || lower.contains('مكالمات') || lower.contains('فاتورة') || 
                      lower.contains('كهربا') || lower.contains('مياه') || lower.contains('غاز') || 
                      lower.contains('نت') || lower.contains('باقة') || lower.contains('recharge') || 
                      lower.contains('bills');

      // 5. Shopping Detection
      final isShopping = lower.contains('سوبرماركت') || lower.contains('ماركت') || lower.contains('اشتريت') || 
                         lower.contains('شريت') || lower.contains('جبت') || lower.contains('طلبات') || 
                         lower.contains('حاجات') || lower.contains('تسوق') || lower.contains('هدوم') || 
                         lower.contains('لبس') || lower.contains('صيدلية') || lower.contains('دوا') || 
                         lower.contains('دواء') || lower.contains('shopping') || lower.contains('market');

      if (hasIncomeKeywords && !isFood && !isTransport && !isBills && !isShopping) {
        isIncome = true;
        category = 'رصيد أولي / مستلم';
        noteDescription = 'رصيد أولي نزل به';
      } else if (isFood) {
        category = 'طعام ومشروبات (Food & Drinks)';
        isIncome = false;
        if (lower.contains('ميه') || lower.contains('مايه') || lower.contains('مياه')) {
          noteDescription = 'مياه';
        } else if (lower.contains('عصير')) {
          noteDescription = 'عصير ومشروبات';
        } else if (lower.contains('قهوة') || lower.contains('شاي') || lower.contains('نسكافيه')) {
          noteDescription = 'قهوة ومشروبات ساخنة';
        } else if (lower.contains('فطار') || lower.contains('فطرت')) {
          noteDescription = 'فطار';
        } else if (lower.contains('غدا') || lower.contains('غداء') || lower.contains('اتغديت')) {
          noteDescription = 'غداء';
        } else if (lower.contains('عشا') || lower.contains('عشاء') || lower.contains('اتعشيت')) {
          noteDescription = 'عشاء';
        } else {
          noteDescription = 'أكل وطعام';
        }
      } else if (isTransport) {
        category = 'مواصلات وتنقل (Transportation)';
        isIncome = false;
        noteDescription = 'مواصلات وتنقلات';
      } else if (isBills) {
        category = 'شحن وفواتير (Bills & Recharge)';
        isIncome = false;
        if (lower.contains('شحن') || lower.contains('شحنت') || lower.contains('كارت') || lower.contains('رصيد')) {
          noteDescription = 'شحن كارت فكة ورصيد مكالمات';
        } else {
          noteDescription = 'فواتير واشتراكات';
        }
      } else if (isShopping) {
        category = 'تسوق ومشتريات (Shopping)';
        isIncome = false;
        noteDescription = 'مشتريات وتسوق';
      } else {
        noteDescription = cleanClause.isNotEmpty ? cleanClause : 'مصروف';
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

    // Smart Conversational Deduplication
    // Merges cases where a user gives a generic clause then specifies it:
    // e.g. "صرفت 70 جنيه على الأكل فأكلت بـ 70 جنيه" -> Merged into 1 specific Food item.
    final refinedTransactions = <Transaction>[];

    for (int i = 0; i < transactions.length; i++) {
      final current = transactions[i];
      bool isDuplicate = false;

      for (int j = 0; j < refinedTransactions.length; j++) {
        final existing = refinedTransactions[j];

        if (existing.type == TransactionType.spent &&
            current.type == TransactionType.spent &&
            (existing.amount - current.amount).abs() < 0.001) {

          final existingIsGeneric = existing.category.startsWith('عام');
          final currentIsGeneric = current.category.startsWith('عام');

          if (existingIsGeneric && !currentIsGeneric) {
            // Existing was generic ("صرفت 70"), current is specific ("أكل 70")
            // Upgrade existing to the specific category!
            refinedTransactions[j] = current;
            isDuplicate = true;
            break;
          } else if (!existingIsGeneric && currentIsGeneric) {
            // Existing is specific, current is generic -> discard generic
            isDuplicate = true;
            break;
          }
        }
      }

      if (!isDuplicate) {
        refinedTransactions.add(current);
      }
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
      rawText: originalTrimmed,
      audioPath: audioPath,
      extractedTransactions: refinedTransactions,
      extractedMeetings: meetings,
      createdAt: DateTime.now(),
    ));
  }
}
