import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../providers/category_provider.dart';
import '../../../../data/models/transaction_model.dart';

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
