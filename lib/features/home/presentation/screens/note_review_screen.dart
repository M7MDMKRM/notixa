import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notixa/app/theme/notixa_palette.dart';
import 'package:notixa/core/design_system/notixa_app_bar.dart';
import 'package:notixa/core/design_system/notixa_button.dart';
import 'package:notixa/features/calendar/domain/models/meeting.dart';
import 'package:notixa/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:notixa/features/home/domain/models/extracted_note.dart';
import 'package:notixa/features/wallet/domain/models/transaction.dart';
import 'package:notixa/features/wallet/presentation/bloc/wallet_bloc.dart';

class NoteReviewScreen extends StatefulWidget {
  final ExtractedNote note;

  const NoteReviewScreen({super.key, required this.note});

  @override
  State<NoteReviewScreen> createState() => _NoteReviewScreenState();
}

class _NoteReviewScreenState extends State<NoteReviewScreen> {
  bool _isSaving = false;

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);

    // Save Extracted Transactions to Wallet
    for (final t in widget.note.extractedTransactions) {
      if (mounted) {
        context.read<WalletBloc>().add(AddTransactionEvent(t));
      }
    }

    // Save Extracted Meetings to Calendar
    final calendarRepo = context.read<CalendarRepository>();
    for (final m in widget.note.extractedMeetings) {
      await calendarRepo.createMeeting(m);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ جميع البيانات في المحفظة والتقويم بنجاح'),
          backgroundColor: NotixaPalette.received,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate Summary Totals
    double totalReceived = 0;
    double totalSpent = 0;
    String currency = 'EGP';

    for (final t in widget.note.extractedTransactions) {
      currency = t.currency;
      if (t.isIncome) {
        totalReceived += t.amount;
      } else {
        totalSpent += t.amount;
      }
    }

    double netRemaining = totalReceived > 0 ? (totalReceived - totalSpent) : 0;

    return Scaffold(
      appBar: const NotixaAppBar(title: 'مراجعة استخراج الذكاء الاصطناعي'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transcribed Text Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mic, color: NotixaPalette.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'النص المسموع من الميكروفون',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.note.rawText.isEmpty ? 'لا يوجد نص مسجل' : widget.note.rawText,
                    style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Financial Summary Card (If multiple transactions detected)
            if (widget.note.extractedTransactions.length > 1) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFF1F5F9), const Color(0xFFFFFFFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NotixaPalette.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص الحسبة المالية المستخرجة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (totalReceived > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('المبلغ الأساسي/المستلم', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('$totalReceived $currency', style: const TextStyle(color: NotixaPalette.received, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('إجمالي المصروفات', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('$totalSpent $currency', style: const TextStyle(color: NotixaPalette.spent, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        if (totalReceived > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('المتبقي الصافي', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('$netRemaining $currency', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Extracted Transactions Section
            if (widget.note.extractedTransactions.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'العمليات والمصروفات المستخرجة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.note.extractedTransactions.length} بنود',
                    style: TextStyle(fontSize: 13, color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...widget.note.extractedTransactions.map((Transaction t) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.isIncome ? NotixaPalette.receivedBackground : NotixaPalette.spentBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: t.isIncome ? NotixaPalette.received : NotixaPalette.spent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            t.note ?? (t.isIncome ? 'إيراد / رصيد' : 'مصروف'),
                            style: TextStyle(fontSize: 12, color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${t.isIncome ? '+' : '-'}${t.amount} ${t.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: t.isIncome ? NotixaPalette.received : NotixaPalette.spent,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),
            ],

            // Extracted Meetings Section
            if (widget.note.extractedMeetings.isNotEmpty) ...[
              const Text(
                'المواعيد والاجتماعات المكتشفة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.note.extractedMeetings.map((Meeting m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: NotixaPalette.tertiary, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'الساعة ${DateFormat('hh:mm a').format(m.startTime)}',
                            style: const TextStyle(fontSize: 12, color: NotixaPalette.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
            ],

            NotixaButton(
              label: 'حفظ جميع البنود في التطبيق',
              isLoading: _isSaving,
              onPressed: _saveAll,
            ),
          ],
        ),
      ),
    );
  }
}
