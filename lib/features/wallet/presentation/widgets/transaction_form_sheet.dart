import 'package:flutter/material.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/design_system/notixa_button.dart';
import '../../../../core/design_system/notixa_text_field.dart';
import '../../domain/models/transaction.dart';

class TransactionFormSheet extends StatefulWidget {
  final Function(Transaction) onSave;

  const TransactionFormSheet({super.key, required this.onSave});

  static Future<void> show(BuildContext context, {required Function(Transaction) onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionFormSheet(onSave: onSave),
    );
  }

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _selectedType = TransactionType.spent;
  String _selectedCategory = 'Food & Drinks';
  String _selectedCurrency = 'USD';

  final List<String> _categories = [
    'Food & Drinks',
    'Shopping',
    'Salary',
    'Transportation',
    'Bills & Utilities',
    'Entertainment',
    'Investment',
    'Health',
    'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final transaction = Transaction(
      id: '',
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      currency: _selectedCurrency,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      date: DateTime.now(),
    );

    widget.onSave(transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Spent / Received Selector
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = TransactionType.spent),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == TransactionType.spent
                            ? NotixaPalette.spentBackground
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == TransactionType.spent
                              ? NotixaPalette.spent
                              : (isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Expense (Spent)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedType == TransactionType.spent
                                ? NotixaPalette.spent
                                : (isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = TransactionType.received),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == TransactionType.received
                            ? NotixaPalette.receivedBackground
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == TransactionType.received
                              ? NotixaPalette.received
                              : (isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Income (Received)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedType == TransactionType.received
                                ? NotixaPalette.received
                                : (isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Field
            NotixaTextField(
              controller: _amountController,
              hintText: '0.00',
              labelText: 'Amount',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.attach_money, color: NotixaPalette.primary),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note Field
            NotixaTextField(
              controller: _noteController,
              hintText: 'What is this for?',
              labelText: 'Note (Optional)',
            ),
            const SizedBox(height: 24),

            NotixaButton(
              label: 'Save Transaction',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
