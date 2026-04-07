import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/budget_progress_card.dart';
import 'add_edit_budget_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/app_responsive.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = AppResponsive.of(context);
    final budgetProgressAsync = ref.watch(budgetProgressProvider);
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Anggaran Bulanan'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_chart_rounded, size: rp.isTablet ? 28 : 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditBudgetScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          budgetProgressAsync.when(
            data: (list) {
              if (list.isEmpty) return const SizedBox();
              final totalLimit = list.fold<double>(
                0,
                (sum, p) => sum + p.budget.amountLimit,
              );
              final totalSpent = list.fold<double>(
                0,
                (sum, p) => sum + p.spentAmount,
              );

              return Container(
                width: double.infinity,
                padding: rp.cardPadding,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Periode $monthName',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: rp.isTablet ? 14 : 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Anggaran',
                              style: TextStyle(
                                fontSize: rp.isTablet ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(totalLimit, 0),
                          style: TextStyle(
                            fontSize: rp.isTablet ? 24 : 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: totalLimit > 0 ? (totalSpent / totalLimit) : 0,
                        backgroundColor: Colors.grey[100],
                        color: totalSpent > totalLimit
                            ? Colors.red
                            : AppColors.primary,
                        minHeight: rp.isTablet ? 14 : 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terpakai: ${CurrencyFormat.convertToIdr(totalSpent, 0)}',
                          style: TextStyle(
                            fontSize: rp.isTablet ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${((totalSpent / totalLimit) * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: rp.isTablet ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: totalSpent > totalLimit
                                ? Colors.red
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (err, st) => const SizedBox(),
          ),
          Expanded(
            child: budgetProgressAsync.when(
              data: (progressList) {
                if (progressList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(rp.isTablet ? 48 : 32),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: rp.isTablet ? 64 : 48,
                          horizontal: rp.isTablet ? 32 : 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment_outlined,
                                size: rp.isTablet ? 64 : 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Anggaran Bulan Ini Kosong',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: rp.isTablet ? 22 : 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mulai kelola pengeluaran Anda dengan membuat anggaran kategori hari ini.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: rp.isTablet ? 16 : 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddEditBudgetScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Buat Anggaran Pertama'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: rp.pagePadding,
                  itemCount: progressList.length,
                  itemBuilder: (context, index) {
                    final progress = progressList[index];
                    final categoriesAsync = ref.watch(categoryProvider);

                    return categoriesAsync.when(
                      data: (categories) {
                        final cat = categories.firstWhere(
                          (c) => c.id == progress.budget.categoryId,
                          orElse: () => null as dynamic,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditBudgetScreen(
                                    budget: progress.budget,
                                  ),
                                ),
                              );
                            },
                            child: BudgetProgressCard(
                              progress: progress,
                              categoryName: cat.name,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(height: 100),
                      error: (err, st) => const SizedBox(),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
