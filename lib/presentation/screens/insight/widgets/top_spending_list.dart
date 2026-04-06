import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../providers/insight_provider.dart';
import '../../../providers/category_provider.dart';

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
