import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:notixa/app/theme/notixa_palette.dart';
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
  late List<Transaction> _transactions;
  late List<Meeting> _meetings;
  late List<TextEditingController> _amountControllers;
  late List<TextEditingController> _descControllers;
  late List<TextEditingController> _tagControllers;
  late List<String> _types;
  late List<String> _statuses;

  bool _isSaving = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.note.extractedTransactions);
    _meetings = List.from(widget.note.extractedMeetings);

    _amountControllers = [];
    _descControllers = [];
    _tagControllers = [];
    _types = [];
    _statuses = [];

    for (final t in _transactions) {
      _amountControllers.add(TextEditingController(text: '${t.amount.toStringAsFixed(0)} EGP'));
      _descControllers.add(TextEditingController(text: t.note ?? ''));
      _tagControllers.add(TextEditingController(text: ''));
      _types.add(t.isIncome ? 'Received' : 'Paid');
      _statuses.add('Done');
    }
  }

  @override
  void dispose() {
    for (final c in _amountControllers) {
      c.dispose();
    }
    for (final c in _descControllers) {
      c.dispose();
    }
    for (final c in _tagControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTransaction() {
    setState(() {
      final newT = Transaction(
        id: _uuid.v4(),
        amount: 0.0,
        type: TransactionType.spent,
        category: 'عام ومصروفات',
        currency: 'EGP',
        note: '',
        date: DateTime.now(),
      );
      _transactions.add(newT);
      _amountControllers.add(TextEditingController(text: '0 EGP'));
      _descControllers.add(TextEditingController(text: ''));
      _tagControllers.add(TextEditingController(text: ''));
      _types.add('Paid');
      _statuses.add('Done');
    });
  }

  void _removeTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
      _amountControllers.removeAt(index);
      _descControllers.removeAt(index);
      _tagControllers.removeAt(index);
      _types.removeAt(index);
      _statuses.removeAt(index);
    });
  }

  void _addMeeting() {
    setState(() {
      final now = DateTime.now();
      _meetings.add(Meeting(
        id: _uuid.v4(),
        title: 'Meeting',
        description: 'Scheduled from voice note',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
        repetition: 'none',
        hasAlarm: true,
      ));
    });
  }

  void _removeMeeting(int index) {
    setState(() {
      _meetings.removeAt(index);
    });
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);

    // Sync edited controllers back to transactions
    for (int i = 0; i < _transactions.length; i++) {
      final rawAmountStr = _amountControllers[i].text.replaceAll(RegExp(r'[^0-9.]'), '');
      final parsedAmount = double.tryParse(rawAmountStr) ?? _transactions[i].amount;
      final isIncome = _types[i] == 'Received';

      final updatedTransaction = _transactions[i].copyWith(
        amount: parsedAmount,
        type: isIncome ? TransactionType.received : TransactionType.spent,
        note: _descControllers[i].text.trim(),
      );

      if (mounted) {
        context.read<WalletBloc>().add(AddTransactionEvent(updatedTransaction));
      }
    }

    // Save Meetings to Calendar
    final calendarRepo = context.read<CalendarRepository>();
    for (final m in _meetings) {
      await calendarRepo.createMeeting(m);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد وحفظ جميع البنود بنجاح'),
          backgroundColor: NotixaPalette.received,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? NotixaPalette.darkBackground : NotixaPalette.lightBackground;
    final cardBg = isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard;
    final fieldBg = isDark ? NotixaPalette.darkSurface : NotixaPalette.lightFieldFill;
    final borderColor = isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder;
    final textPrimary = isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight;
    final textMuted = isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review & Save',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. MEETINGS SECTION
            Row(
              children: [
                Text(
                  'Meetings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NotixaPalette.purpleBadge,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_meetings.length}',
                    style: const TextStyle(
                      color: NotixaPalette.purpleBadgeText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Meetings List (If any)
            if (_meetings.isNotEmpty) ...[
              ...List.generate(_meetings.length, (mIdx) {
                final m = _meetings[mIdx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: NotixaPalette.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              m.description ?? '',
                              style: TextStyle(fontSize: 12, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: NotixaPalette.spent, size: 20),
                        onPressed: () => _removeMeeting(mIdx),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Add Meeting Text Button
            Center(
              child: TextButton.icon(
                onPressed: _addMeeting,
                icon: const Icon(Icons.add, color: NotixaPalette.primary, size: 18),
                label: const Text(
                  'Add meeting',
                  style: TextStyle(
                    color: NotixaPalette.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. FINANCIAL NOTES SECTION
            Row(
              children: [
                Text(
                  'Financial Notes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NotixaPalette.purpleBadge,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_transactions.length}',
                    style: const TextStyle(
                      color: NotixaPalette.purpleBadgeText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transaction Cards List
            ...List.generate(_transactions.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header: Transaction # N + Red Trash Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction # ${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFEF4444),
                            size: 22,
                          ),
                          onPressed: () => _removeTransaction(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Field 1: Amount with purple border
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: NotixaPalette.primary, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 11,
                              color: NotixaPalette.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextField(
                            controller: _amountControllers[index],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: NotixaPalette.primary,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 2: Transaction Type (Paid / Received dropdown)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Type',
                            style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _types[index],
                              icon: Icon(Icons.arrow_drop_down, color: textMuted),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary),
                              items: const [
                                DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                                DropdownMenuItem(value: 'Received', child: Text('Received')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _types[index] = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 3: Status (Done / Pending dropdown)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _statuses[index],
                              icon: Icon(Icons.arrow_drop_down, color: textMuted),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary),
                              items: const [
                                DropdownMenuItem(value: 'Done', child: Text('Done')),
                                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _statuses[index] = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 4: Description (Multiline text input)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500),
                          ),
                          TextField(
                            controller: _descControllers[index],
                            maxLines: 2,
                            style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 6),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 5: Hashtags
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hashtags',
                            style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Text(
                                '#  ',
                                style: TextStyle(
                                  color: textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _tagControllers[index],
                                  style: TextStyle(fontSize: 14, color: textPrimary),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Search or add hashtag',
                                    hintStyle: TextStyle(color: textMuted, fontSize: 13),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // + Add transaction button
            Center(
              child: TextButton.icon(
                onPressed: _addTransaction,
                icon: const Icon(Icons.add, color: NotixaPalette.primary, size: 18),
                label: const Text(
                  'Add transaction',
                  style: TextStyle(
                    color: NotixaPalette.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm & Save All button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NotixaPalette.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Confirm & Save All',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
