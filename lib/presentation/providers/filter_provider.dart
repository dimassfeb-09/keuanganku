import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';
import '../../data/models/transaction_model.dart';

class FilterConfig {
  final String? type;
  final String? categoryId;
  final String? walletId;
  final DateTime? startDate;
  final DateTime? endDate;

  FilterConfig({
    this.type,
    this.categoryId,
    this.walletId,
    this.startDate,
    this.endDate,
  });

  FilterConfig copyWith({
    String? type,
    String? categoryId,
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
    bool clearType = false,
    bool clearCategory = false,
    bool clearWallet = false,
    bool clearDate = false,
  }) {
    return FilterConfig(
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      startDate: clearDate ? null : (startDate ?? this.startDate),
      endDate: clearDate ? null : (endDate ?? this.endDate),
    );
  }
}

class FilterNotifier extends StateNotifier<FilterConfig> {
  FilterNotifier() : super(FilterConfig());

  void updateType(String? type) =>
      state = state.copyWith(type: type, clearType: type == null);
  void updateCategory(String? id) =>
      state = state.copyWith(categoryId: id, clearCategory: id == null);
  void updateWallet(String? id) =>
      state = state.copyWith(walletId: id, clearWallet: id == null);
  void updateDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      state = state.copyWith(clearDate: true);
    } else {
      state = state.copyWith(startDate: start, endDate: end);
    }
  }

  void reset() => state = FilterConfig();
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterConfig>((
  ref,
) {
  return FilterNotifier();
});

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final allTxAsync = ref.watch(transactionProvider);
  final filter = ref.watch(filterProvider);

  return allTxAsync.when(
    data: (transactions) {
      return transactions.where((tx) {
        if (filter.type != null && tx.type != filter.type) return false;
        if (filter.categoryId != null && tx.categoryId != filter.categoryId) {
          return false;
        }
        if (filter.walletId != null && tx.walletId != filter.walletId) {
          return false;
        }
        if (filter.startDate != null && filter.endDate != null) {
          final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
          final start = DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            filter.startDate!.day,
          );
          final end = DateTime(
            filter.endDate!.year,
            filter.endDate!.month,
            filter.endDate!.day,
          );
          if (txDate.isBefore(start) || txDate.isAfter(end)) return false;
        }
        return true;
      }).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});
