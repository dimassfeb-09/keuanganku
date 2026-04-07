import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import 'app_providers.dart';
import 'package:intl/intl.dart';

class BudgetProgress {
  final Budget budget;
  final double spentAmount;

  BudgetProgress({required this.budget, required this.spentAmount});

  double get percentage =>
      budget.amountLimit == 0 ? 0 : spentAmount / budget.amountLimit;
  double get remaining => budget.amountLimit - spentAmount;
  bool get isExceeded => spentAmount > budget.amountLimit;
}

final budgetRepositoryProvider = Provider((ref) => BudgetRepository());

final budgetProvider = NotifierProvider<BudgetNotifier, AsyncValue<List<Budget>>>(() {
  return BudgetNotifier();
});

class BudgetNotifier extends Notifier<AsyncValue<List<Budget>>> {
  late final BudgetRepository _repository;
  late final String _currentMonthYear;

  @override
  AsyncValue<List<Budget>> build() {
    _repository = ref.read(budgetRepositoryProvider);
    final now = DateTime.now();
    _currentMonthYear = DateFormat('MM-yyyy').format(now);
    loadBudgets();
    return const AsyncValue.loading();
  }

  Future<void> loadBudgets() async {
    try {
      final budgets = await _repository.getBudgetsByMonth(_currentMonthYear);
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> upsertBudget(Budget budget) async {
    await _repository.upsertBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    await loadBudgets();
  }
}

final budgetProgressProvider = Provider<AsyncValue<List<BudgetProgress>>>((ref) {
  final budgetsAsync = ref.watch(budgetProvider);
  final transactionsAsync = ref.watch(transactionProvider);

  return budgetsAsync.when(
    data: (budgets) {
      return transactionsAsync.when(
        data: (transactions) {
          final progressList = budgets.map((budget) {
            final spent = transactions
                .where((tx) {
                  final txMonthYear = DateFormat('MM-yyyy').format(tx.date);
                  return tx.type == 'expense' &&
                      tx.categoryId == budget.categoryId &&
                      txMonthYear == budget.monthYear;
                })
                .fold(0.0, (sum, tx) => sum + tx.amount);

            return BudgetProgress(budget: budget, spentAmount: spent);
          }).toList();

          return AsyncValue.data(progressList);
        },
        loading: () => const AsyncValue.loading(),
        error: (err, st) => AsyncValue.error(err, st),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, st) => AsyncValue.error(err, st),
  );
});
