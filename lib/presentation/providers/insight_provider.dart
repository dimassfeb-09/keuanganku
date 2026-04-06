import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';
import '../../data/models/transaction_model.dart';
import 'package:collection/collection.dart';

class MonthlySummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });
}

class CategorySpending {
  final String categoryId;
  final double amount;
  final double percentage;

  const CategorySpending({
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });
}

final monthlySummaryProvider = Provider<AsyncValue<MonthlySummary>>((ref) {
  final transactionsAsync = ref.watch(transactionProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final now = DateTime.now();
      final currentMonthTxs = transactions.where((tx) => 
        tx.date.month == now.month && 
        tx.date.year == now.year
      ).toList();

      double income = 0;
      double expense = 0;

      for (var tx in currentMonthTxs) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }

      return AsyncValue.data(MonthlySummary(
        totalIncome: income,
        totalExpense: expense,
        netBalance: income - expense,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (err, st) => AsyncValue.error(err, st),
  );
});

final topSpendingCategoriesProvider = Provider<AsyncValue<List<CategorySpending>>>((ref) {
  final transactionsAsync = ref.watch(transactionProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final now = DateTime.now();
      final currentMonthExpenses = transactions.where((tx) => 
        tx.type == 'expense' && 
        tx.date.month == now.month && 
        tx.date.year == now.year
      ).toList();

      final totalExpense = currentMonthExpenses.fold(0.0, (sum, tx) => sum + tx.amount);
      if (totalExpense == 0) return const AsyncValue.data([]);

      final grouped = groupBy(currentMonthExpenses, (tx) => tx.categoryId);
      
      final spendings = grouped.entries.map((entry) {
        final amount = entry.value.fold(0.0, (sum, tx) => sum + tx.amount);
        return CategorySpending(
          categoryId: entry.key,
          amount: amount,
          percentage: (amount / totalExpense) * 100,
        );
      }).toList();

      // Sort by amount descending
      spendings.sort((a, b) => b.amount.compareTo(a.amount));

      return AsyncValue.data(spendings);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, st) => AsyncValue.error(err, st),
  );
});

final largestTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final now = DateTime.now();
      final currentMonthExpenses = transactions.where((tx) => 
        tx.type == 'expense' && 
        tx.date.month == now.month && 
        tx.date.year == now.year
      ).toList();

      // Sort by amount descending and take top 5
      currentMonthExpenses.sort((a, b) => b.amount.compareTo(a.amount));
      final top5 = currentMonthExpenses.take(5).toList();

      return AsyncValue.data(top5);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, st) => AsyncValue.error(err, st),
  );
});
