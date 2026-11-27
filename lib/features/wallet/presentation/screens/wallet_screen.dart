import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/design_system/notixa_app_bar.dart';
import '../../domain/models/transaction.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/transaction_form_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: NotixaAppBar(
        title: 'Wallet & Expenses',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: NotixaPalette.primary),
            onPressed: () {
              TransactionFormSheet.show(
                context,
                onSave: (t) => context.read<WalletBloc>().add(AddTransactionEvent(t)),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(const LoadTransactionsEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Hero Card
                    _buildBalanceCard(state, isDark),
                    const SizedBox(height: 20),

                    // Income / Expense Stats Row (with extracted SVGs!)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Received',
                            amount: state.totalIncome,
                            currency: state.selectedCurrency,
                            svgPath: 'assets/SVGs/recved_icon.svg',
                            color: NotixaPalette.received,
                            bgColor: NotixaPalette.receivedBackground,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Spent',
                            amount: state.totalExpense,
                            currency: state.selectedCurrency,
                            svgPath: 'assets/SVGs/spent_icon.svg',
                            color: NotixaPalette.spent,
                            bgColor: NotixaPalette.spentBackground,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.transactions.length} items',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Transactions List
                    if (state.transactions.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = state.transactions[index];
                          return _buildTransactionItem(context, item, isDark);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Load your wallet'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NotixaPalette.primary,
        onPressed: () {
          TransactionFormSheet.show(
            context,
            onSave: (t) => context.read<WalletBloc>().add(AddTransactionEvent(t)),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceCard(WalletLoaded state, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NotixaPalette.primary, NotixaPalette.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: NotixaPalette.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat('#,##0.00').format(state.balance)} ${state.selectedCurrency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required double amount,
    required String currency,
    required String svgPath,
    required Color color,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight,
                ),
              ),
              SvgPicture.asset(
                svgPath,
                width: 32,
                height: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${NumberFormat('#,##0.00').format(amount)} $currency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction item, bool isDark) {
    final dateFormat = DateFormat('MMM dd, yyyy · hh:mm a');

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: NotixaPalette.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<WalletBloc>().add(DeleteTransactionEvent(item.id));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.isIncome ? NotixaPalette.receivedBackground : NotixaPalette.spentBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: item.isIncome ? NotixaPalette.received : NotixaPalette.spent,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(item.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${item.isIncome ? '+' : '-'}${NumberFormat('#,##0.00').format(item.amount)} ${item.currency}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: item.isIncome ? NotixaPalette.received : NotixaPalette.spent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 54,
            color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + or record a voice note to add expenses',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
