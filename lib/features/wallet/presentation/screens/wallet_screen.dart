import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../domain/models/transaction.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/transaction_form_sheet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _searchQuery = '';
  String? _filterType; // null, 'spent', 'received'

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
      body: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            double totalIncome = 0;
            double totalExpense = 0;
            String currency = 'EGP';
            List<Transaction> transactions = [];

            if (state is WalletLoaded) {
              totalIncome = state.totalIncome;
              totalExpense = state.totalExpense;
              currency = state.selectedCurrency;
              transactions = state.transactions;
            }

            // Filter transactions by search query and type
            final filtered = transactions.where((t) {
              final matchesQuery = _searchQuery.isEmpty ||
                  (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                  t.category.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchesType = _filterType == null ||
                  (_filterType == 'spent' && !t.isIncome) ||
                  (_filterType == 'received' && t.isIncome);
              return matchesQuery && matchesType;
            }).toList();

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP HEADER (NEXA Logo + Notification Bell)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/nexa_logo.png',
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications_none_outlined, color: textPrimary, size: 26),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 12,
                                top: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF43F5E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. SEARCH & FILTER ROW
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: fieldBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: TextField(
                                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                                  hintText: 'Search transactions...',
                                  hintStyle: TextStyle(color: textMuted, fontSize: 14),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: fieldBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.tune, color: textPrimary, size: 20),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filter Pills Row (Paid | Received | Date Range | #)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: 'Paid',
                              isSelected: _filterType == 'spent',
                              onTap: () {
                                setState(() {
                                  _filterType = _filterType == 'spent' ? null : 'spent';
                                });
                              },
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Received',
                              isSelected: _filterType == 'received',
                              onTap: () {
                                setState(() {
                                  _filterType = _filterType == 'received' ? null : 'received';
                                });
                              },
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Date Range  ▾',
                              isSelected: false,
                              onTap: () {},
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: '#',
                              isSelected: false,
                              onTap: () {},
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. STATS CARDS (Spent & Received in Row)
                      Row(
                        children: [
                          // Spent Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
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
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: NotixaPalette.spentBackground,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.trending_down,
                                      color: NotixaPalette.spent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Spent',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${totalExpense.toStringAsFixed(2)} $currency',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NotixaPalette.spent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Received Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
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
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: NotixaPalette.receivedBackground,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: NotixaPalette.received,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Received',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${totalIncome.toStringAsFixed(2)} $currency',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NotixaPalette.received,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 4. TRANSACTIONS SECTION
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Transactions List
                      if (filtered.isNotEmpty) ...[
                        ...filtered.map((t) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: t.isIncome
                                          ? NotixaPalette.receivedBackground
                                          : NotixaPalette.spentBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: t.isIncome ? NotixaPalette.received : NotixaPalette.spent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Title + Status + Date
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.note?.isNotEmpty == true ? t.note! : t.category,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: NotixaPalette.receivedBackground,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Done',
                                                style: TextStyle(
                                                  color: NotixaPalette.received,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              DateFormat('MMM d • h:mm a').format(t.date),
                                              style: TextStyle(fontSize: 11, color: textMuted),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Amount + 3 Dots Menu
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${t.isIncome ? '+' : '-'}${t.amount.toStringAsFixed(2)} $currency',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: t.isIncome ? NotixaPalette.received : NotixaPalette.spent,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Icon(Icons.more_vert, color: textMuted, size: 18),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No hashtags added',
                                style: TextStyle(fontSize: 11, color: textMuted),
                              ),
                            ],
                          ),
                        )),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Center(
                            child: Text(
                              'No transactions found.',
                              style: TextStyle(color: textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 80), // padding for floating button
                    ],
                  ),
                ),

                // Floating Action Button at Bottom Right
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      TransactionFormSheet.show(
                        context,
                        onSave: (t) => context.read<WalletBloc>().add(AddTransactionEvent(t)),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    label: const Text(
                      'Add transaction',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NotixaPalette.primary,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? NotixaPalette.primary
              : (isDark ? NotixaPalette.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? NotixaPalette.primary : (isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}
