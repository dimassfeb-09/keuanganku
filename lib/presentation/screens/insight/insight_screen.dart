import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/chart_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/insight_provider.dart';
import '../../widgets/chart_widget.dart';
import '../../widgets/budget_progress_card.dart';
import '../budget/budget_screen.dart';
import 'widgets/summary_overview_card.dart';
import 'widgets/top_spending_list.dart';
import 'widgets/largest_transactions_list.dart';
import 'package:collection/collection.dart';

class InsightScreen extends ConsumerWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final topSpendingAsync = ref.watch(topSpendingCategoriesProvider);
    final topTransactionsAsync = ref.watch(largestTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: summaryAsync.when(
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnimatedSection(
                delay: 0,
                child: const Text(
                  'Analisis Keuangan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 1. CASHFLOW SUMMARY
              _AnimatedSection(
                delay: 100,
                child: SummaryOverviewCard(summary: summary),
              ),

              const SizedBox(height: 32),

              // 2. PIE CHART SECTION
              _AnimatedSection(
                delay: 200,
                child: ref
                    .watch(categoryExpenseChartProvider)
                    .when(
                      data: (chartData) => CategoryExpenseChart(
                        sections: chartData.sections,
                        totalExpense: chartData.total,
                        categoryNames: chartData.categoryNames,
                        categoryIcons: chartData.categoryIcons,
                        categoryColors: chartData.categoryColors,
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error Chart: $err'),
                    ),
              ),

              const SizedBox(height: 32),

              // 3. BUDGET MONITORING
              _AnimatedSection(
                delay: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.track_changes_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pantau Anggaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ref
                        .watch(budgetProgressProvider)
                        .when(
                          data: (progressList) {
                            if (progressList.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.03,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.track_changes_outlined,
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Belum ada Anggaran',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Atur target pengeluaran untuk tiap kategori',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BudgetScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text(
                                        'Buat Anggaran Pertama',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Column(
                              children: [
                                ...progressList.map((p) {
                                  final categoriesAsync = ref.watch(
                                    categoryProvider,
                                  );
                                  return categoriesAsync.when(
                                    data: (categories) {
                                      final cat = categories.firstWhereOrNull(
                                        (c) => c.id == p.budget.categoryId,
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: BudgetProgressCard(
                                          progress: p,
                                          categoryName: cat?.name ?? 'Kategori',
                                        ),
                                      );
                                    },
                                    loading: () => const SizedBox(),
                                    error: (_, _) => const SizedBox(),
                                  );
                                }),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const BudgetScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.tune_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Kelola Semua Anggaran'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.05),
                                      foregroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text('Error Budget: $err'),
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. TOP SPENDING CATEGORIES
              _AnimatedSection(
                delay: 400,
                child: topSpendingAsync.when(
                  data: (spendings) => TopSpendingList(spendings: spendings),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
              ),

              const SizedBox(height: 32),

              // 5. LARGEST TRANSACTIONS
              _AnimatedSection(
                delay: 500,
                child: topTransactionsAsync.when(
                  data: (transactions) =>
                      LargestTransactionsList(transactions: transactions),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedSection({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: delay.toDouble() / 1000),
        child: _DelayedWidget(delay: delay, child: child),
      ),
    );
  }
}

class _DelayedWidget extends StatefulWidget {
  final int delay;
  final Widget child;
  const _DelayedWidget({required this.delay, required this.child});

  @override
  State<_DelayedWidget> createState() => _DelayedWidgetState();
}

class _DelayedWidgetState extends State<_DelayedWidget> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _visible ? 1.0 : 0.0,
      child: widget.child,
    );
  }
}
