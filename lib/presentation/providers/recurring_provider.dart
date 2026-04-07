import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recurring_transaction_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/recurring_repository.dart';
import 'app_providers.dart';
import 'package:uuid/uuid.dart';

final recurringRepositoryProvider = Provider((ref) => RecurringRepository());

final recurringProvider = NotifierProvider<RecurringNotifier, AsyncValue<List<RecurringTransaction>>>(() {
  return RecurringNotifier();
});

class RecurringNotifier extends Notifier<AsyncValue<List<RecurringTransaction>>> {
  late final RecurringRepository _repository;

  @override
  AsyncValue<List<RecurringTransaction>> build() {
    _repository = ref.read(recurringRepositoryProvider);
    loadRecurrings();
    return const AsyncValue.loading();
  }

  Future<void> loadRecurrings() async {
    try {
      final recurrings = await _repository.getActiveRecurrings();
      state = AsyncValue.data(recurrings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecurring(RecurringTransaction rt) async {
    await _repository.addRecurringTransaction(rt);
    await loadRecurrings();
  }

  Future<void> updateRecurring(RecurringTransaction rt) async {
    await _repository.updateRecurring(rt);
    await loadRecurrings();
  }

  Future<void> deleteRecurring(String id) async {
    await _repository.deleteRecurring(id);
    await loadRecurrings();
  }

  /// Logic to trigger recurring transactions
  Future<void> processRecurrings() async {
    final recurrings = state.value ?? await _repository.getActiveRecurrings();
    final now = DateTime.now();
    bool generatedAny = false;

    for (var rt in recurrings) {
      var nextRun = rt.nextRunDate;
      var currentRt = rt;
      bool rtChanged = false;

      while (now.isAfter(nextRun) || _isSameDay(now, nextRun)) {
        // Generate transaction
        final tx = Transaction(
          id: const Uuid().v4(),
          amount: currentRt.amount,
          type: currentRt.type,
          date: nextRun,
          note: currentRt.note != null ? "${currentRt.note} (Auto)" : "Auto Recurring",
          walletId: currentRt.walletId,
          categoryId: currentRt.categoryId,
        );

        await ref.read(transactionProvider.notifier).addTransaction(tx);
        
        // Calculate next date
        nextRun = _calculateNextDate(nextRun, currentRt.frequency);
        currentRt = currentRt._copyWith(nextRunDate: nextRun);
        generatedAny = true;
        rtChanged = true;
      }

      if (rtChanged) {
        await _repository.updateRecurring(currentRt);
      }
    }
    
    if (generatedAny) {
      await loadRecurrings();
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  DateTime _calculateNextDate(DateTime current, String frequency) {
    switch (frequency) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        // Handle month overflow
        return DateTime(current.year, current.month + 1, current.day);
      default:
        return current.add(const Duration(days: 1));
    }
  }
}

extension on RecurringTransaction {
  RecurringTransaction _copyWith({DateTime? nextRunDate}) {
    return RecurringTransaction(
      id: id,
      amount: amount,
      type: type,
      note: note,
      walletId: walletId,
      categoryId: categoryId,
      frequency: frequency,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      isActive: isActive,
    );
  }
}
