import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/budget_provider.dart';
import '../../budget/budget_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';

class HomeBudgetBanner extends ConsumerWidget {
  const HomeBudgetBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = AppResponsive.of(context);
    final budgetProgressAsync = ref.watch(budgetProgressProvider);

    return budgetProgressAsync.when(
      data: (list) {
        final hasBudget = list.isNotEmpty;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rp.pagePadding.left,
            vertical: 8,
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
            child: Container(
              padding: rp.cardPadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasBudget
                      ? [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ]
                      : [Colors.orange[400]!, Colors.orange[700]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (hasBudget ? AppColors.primary : Colors.orange)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    hasBudget
                        ? Icons.track_changes_rounded
                        : Icons.tips_and_updates_rounded,
                    color: Colors.white,
                    size: rp.isTablet ? 40 : 32,
                  ),
                  SizedBox(width: rp.isTablet ? 20 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasBudget
                              ? 'Pantau Anggaranmu'
                              : 'Atur Anggaran Bulan Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: rp.isTablet ? 18 : 16,
                          ),
                        ),
                        Text(
                          hasBudget
                              ? 'Lihat seberapa banyak kamu telah berhemat hari ini.'
                              : 'Mulai batasi pengeluaran agar keuangan lebih sehat.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: rp.isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: rp.isTablet ? 20 : 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (err, st) => const SizedBox(),
    );
  }
}
