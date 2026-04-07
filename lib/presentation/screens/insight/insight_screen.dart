import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_responsive.dart';
import '../../../core/widgets/adaptive_layout.dart';
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
    final rp = AppResponsive.of(context);
    final summaryAsync = ref.watch(monthlySummaryProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: summaryAsync.when(
        data: (summary) => AdaptiveLayout(
          mobile: (context) => _buildMobileLayout(context, ref, summary, rp),
          tablet: (context) => _buildTabletLayout(context, ref, summary, rp),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, MonthlySummary summary, AppResponsive rp) {
    final topSpendingAsync = ref.watch(topSpendingCategoriesProvider);
    final topTransactionsAsync = ref.watch(largestTransactionsProvider);
    
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rp.pagePadding.left, 20, rp.pagePadding.right, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedSection(
            delay: 0,
            child: Text(
              'Analisis Keuangan',
              style: TextStyle(
                fontSize: rp.isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
          SizedBox(height: rp.isTablet ? 24 : 20),

          // 1. CASHFLOW SUMMARY
          _AnimatedSection(
            delay: 100,
            child: SummaryOverviewCard(summary: summary),
          ),

          SizedBox(height: rp.sectionSpacing),

          // 2. PIE CHART SECTION
          _AnimatedSection(
            delay: 200,
            child: _buildChart(ref),
          ),

          SizedBox(height: rp.sectionSpacing),

          // 3. BUDGET MONITORING
          _AnimatedSection(
            delay: 300,
            child: _buildBudgetSection(context, ref, rp),
          ),

          SizedBox(height: rp.sectionSpacing),

          // 4. TOP SPENDING CATEGORIES
          _AnimatedSection(
            delay: 400,
            child: topSpendingAsync.when(
              data: (spendings) => TopSpendingList(spendings: spendings),
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),
          ),

          SizedBox(height: rp.sectionSpacing),

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
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, MonthlySummary summary, AppResponsive rp) {
    final topSpendingAsync = ref.watch(topSpendingCategoriesProvider);
    final topTransactionsAsync = ref.watch(largestTransactionsProvider);
    
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rp.pagePadding.left, 32, rp.pagePadding.right, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedSection(
            delay: 0,
            child: Text(
              'Analisis Keuangan',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _AnimatedSection(
                      delay: 100,
                      child: SummaryOverviewCard(summary: summary),
                    ),
                    const SizedBox(height: 32),
                    _AnimatedSection(
                      delay: 200,
                      child: _buildChart(ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Right Column
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _AnimatedSection(
                      delay: 300,
                      child: _buildBudgetSection(context, ref, rp),
                    ),
                    const SizedBox(height: 32),
                     _AnimatedSection(
                      delay: 400,
                      child: topSpendingAsync.when(
                        data: (spendings) => TopSpendingList(spendings: spendings),
                        loading: () => const SizedBox(),
                        error: (_, _) => const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _AnimatedSection(
                      delay: 500,
                      child: topTransactionsAsync.when(
                        data: (transactions) =>
                            LargestTransactionsList(transactions: transactions),
                        loading: () => const SizedBox(),
                        error: (_, _) => const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildChart(WidgetRef ref) {
    return ref.watch(categoryExpenseChartProvider).when(
      data: (chartData) => CategoryExpenseChart(
        sections: chartData.sections,
        totalExpense: chartData.total,
        categoryNames: chartData.categoryNames,
        categoryIcons: chartData.categoryIcons,
        categoryColors: chartData.categoryColors,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error Chart: $err'),
    );
  }

  Widget _buildBudgetSection(BuildContext context, WidgetRef ref, AppResponsive rp) {
    final budgetProgressAsync = ref.watch(budgetProgressProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.track_changes_rounded,
              color: AppColors.primary,
              size: rp.isTablet ? 24 : 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Pantau Anggaran',
              style: TextStyle(
                fontSize: rp.isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        budgetProgressAsync.when(
          data: (progressList) {
            if (progressList.isEmpty) {
              return _emptyBudgetState(context, rp);
            }
            return Column(
              children: [
                ...progressList.map((p) {
                  final categoriesAsync = ref.watch(categoryProvider);
                  return categoriesAsync.when(
                    data: (categories) {
                      final cat = categories.firstWhereOrNull(
                        (c) => c.id == p.budget.categoryId,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                          builder: (context) => const BudgetScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.tune_rounded,
                      size: rp.isTablet ? 24 : 20,
                    ),
                    label: Text(
                      'Kelola Semua Anggaran',
                      style: TextStyle(fontSize: rp.isTablet ? 16 : 14),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error Budget: $err'),
        ),
      ],
    );
  }

  Widget _emptyBudgetState(BuildContext context, AppResponsive rp) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rp.isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.track_changes_outlined,
              color: AppColors.primary,
              size: rp.isTablet ? 40 : 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada Anggaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: rp.isTablet ? 20 : 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Atur target pengeluaran untuk tiap kategori',
            style: TextStyle(
              color: Colors.grey,
              fontSize: rp.isTablet ? 15 : 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Buat Anggaran Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
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
