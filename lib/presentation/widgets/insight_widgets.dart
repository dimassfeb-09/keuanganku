import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_format.dart';
import '../providers/insight_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SummaryOverviewCard extends StatelessWidget {
  final MonthlySummary summary;

  const SummaryOverviewCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context,
                'Pemasukan',
                summary.totalIncome,
                AppColors.income,
                Icons.arrow_downward_rounded,
              ),
              Container(width: 1, height: 50, color: Colors.grey[200]),
              _buildSummaryItem(
                context,
                'Pengeluaran',
                summary.totalExpense,
                AppColors.expense,
                Icons.arrow_upward_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selisih (Net)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormat.convertToIdr(summary.netBalance, 0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: summary.netBalance >= 0
                      ? AppColors.income
                      : AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              CurrencyFormat.convertToIdr(amount, 0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopSpendingList extends ConsumerWidget {
  final List<CategorySpending> spendings;

  const TopSpendingList({super.key, required this.spendings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (spendings.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analisis Per Kategori',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 16),
        ...spendings.take(5).map((s) {
          final categoriesAsync = ref.watch(categoryProvider);
          return categoriesAsync.when(
            data: (categories) {
              final cat = categories.firstWhereOrNull(
                (c) => c.id == s.categoryId,
              );
              if (cat == null) return const SizedBox();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconData(cat.icon, fontFamily: 'MaterialIcons'),
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(s.amount, 0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0, end: s.percentage / 100),
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.05,
                          ),
                          color: AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${s.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          'dari total pengeluaran',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
          );
        }),
      ],
    );
  }
}

class LargestTransactionsList extends ConsumerWidget {
  final List<Transaction> transactions;

  const LargestTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaksi Terbesar (Bulan Ini)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            children: transactions.mapIndexed((index, tx) {
              final categoriesAsync = ref.watch(categoryProvider);
              return categoriesAsync.when(
                data: (categories) {
                  final cat = categories.firstWhereOrNull(
                    (c) => c.id == tx.categoryId,
                  );
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.expense.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            cat != null
                                ? IconData(
                                    cat.icon,
                                    fontFamily: 'MaterialIcons',
                                  )
                                : Icons.money_off,
                            color: AppColors.expense,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          (tx.note?.isEmpty ?? true)
                              ? (cat?.name ?? 'Pengeluaran')
                              : tx.note!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM').format(tx.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        trailing: Text(
                          '-${CurrencyFormat.convertToIdr(tx.amount, 0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.expense,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (index < transactions.length - 1)
                        const Divider(height: 1, indent: 70),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
