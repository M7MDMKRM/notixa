import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          content: Text('Saved to Notixa successfully!'),
          backgroundColor: NotixaPalette.received,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const NotixaAppBar(title: 'Review AI Extracted Note'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Raw Transcribed Text Card
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
                        'Transcribed Voice Note',
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
                    widget.note.rawText.isEmpty ? 'No text recorded' : widget.note.rawText,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Extracted Transactions
            if (widget.note.extractedTransactions.isNotEmpty) ...[
              const Text(
                'Extracted Expenses & Income',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(t.type.name, style: TextStyle(fontSize: 12, color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight)),
                        ],
                      ),
                    ),
                    Text(
                      '${t.amount} ${t.currency}',
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

            // Extracted Meetings
            if (widget.note.extractedMeetings.isNotEmpty) ...[
              const Text(
                'Extracted Meetings & Events',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                    const Icon(Icons.event, color: NotixaPalette.tertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Today at ${m.startTime.hour}:${m.startTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 12, color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight),
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
              label: 'Save All to Notixa',
              isLoading: _isSaving,
              onPressed: _saveAll,
            ),
          ],
        ),
      ),
    );
  }
}
