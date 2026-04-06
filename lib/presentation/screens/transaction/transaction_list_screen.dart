import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../providers/category_provider.dart';
import '../../widgets/transaction_item.dart';
import '../../widgets/transaction_detail_modal.dart';
import '../../widgets/filter_bar_widget.dart';
import '../../providers/filter_provider.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final wallets = ref.watch(walletProvider);

    return Column(
      children: [
        const FilterBarWidget(),
        Expanded(
          child: categoriesAsync.when(
            data: (categories) {
              if (transactions.isEmpty) {
                return const Center(child: Text("Tidak ada transaksi"));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  final category = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => null as dynamic);
                  final wallet = wallets.firstWhere((w) => w.id == t.walletId, orElse: () => null as dynamic);
                  
                  return TransactionItem(
                    category: category,
                    amount: t.amount,
                    type: t.type,
                    date: t.date,
                    onTap: () => showTransactionDetail(context, ref, t, category, wallet),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error loading categories: $err')),
          ),
        ),
      ],
    );
  }
}
