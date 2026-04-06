import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_providers.dart';
import 'category_provider.dart';
import 'package:collection/collection.dart';
import '../../data/models/category_model.dart';

final categoryExpenseChartProvider = Provider<AsyncValue<ChartData>>((ref) {
  final transactionsAsync = ref.watch(transactionProvider);
  final categoriesAsync = ref.watch(categoryProvider);

  return transactionsAsync.when(
    data: (transactions) {
      return categoriesAsync.when(
        data: (categories) {
          final now = DateTime.now();
          final currentMonthExpenses = transactions
              .where(
                (tx) =>
                    tx.type == 'expense' &&
                    tx.date.month == now.month &&
                    tx.date.year == now.year,
              )
              .toList();

          final total = currentMonthExpenses.fold(
            0.0,
            (sum, tx) => sum + tx.amount,
          );

          if (total == 0)
            return const AsyncValue.data(
              ChartData(
                sections: [],
                total: 0,
                categoryNames: [],
                categoryIcons: [],
                categoryColors: [],
              ),
            );

          final grouped = groupBy(currentMonthExpenses, (tx) => tx.categoryId);

          final sortedEntries = grouped.entries.toList();

          final sections = sortedEntries.map((entry) {
            final categoryId = entry.key;
            final amount = entry.value.fold(0.0, (sum, tx) => sum + tx.amount);

            final category = categories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () => Category(
                id: 'unknown',
                name: 'Lainnya',
                type: 'expense',
                icon: Icons.help.codePoint,
                color: 0xFF9E9E9E,
              ),
            );

            return PieChartSectionData(
              color: Color(category.color),
              value: amount,
              title: '${(amount / total * 100).toStringAsFixed(0)}%',
              radius: 50,
              showTitle: true,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList();

          final categoryNames = sortedEntries.map((entry) {
            final categoryId = entry.key;
            return categories
                .firstWhere(
                  (c) => c.id == categoryId,
                  orElse: () => categories.first,
                )
                .name;
          }).toList();

          final categoryIcons = sortedEntries.map((entry) {
            final categoryId = entry.key;
            return categories
                .firstWhere(
                  (c) => c.id == categoryId,
                  orElse: () => categories.first,
                )
                .icon;
          }).toList();

          final categoryColors = sortedEntries.map((entry) {
            final categoryId = entry.key;
            return categories
                .firstWhere(
                  (c) => c.id == categoryId,
                  orElse: () => categories.first,
                )
                .color;
          }).toList();

          return AsyncValue.data(
            ChartData(
              sections: sections,
              total: total,
              categoryNames: categoryNames,
              categoryIcons: categoryIcons,
              categoryColors: categoryColors,
            ),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (err, st) => AsyncValue.error(err, st),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, st) => AsyncValue.error(err, st),
  );
});

class ChartData {
  final List<PieChartSectionData> sections;
  final double total;
  final List<String> categoryNames;
  final List<int> categoryIcons;
  final List<int> categoryColors;

  const ChartData({
    required this.sections,
    required this.total,
    required this.categoryNames,
    required this.categoryIcons,
    required this.categoryColors,
  });
}
