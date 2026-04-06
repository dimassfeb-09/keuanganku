import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/budget_provider.dart';
import '../../budget/budget_screen.dart';
import '../../../../core/theme/app_colors.dart';

class HomeBudgetBanner extends ConsumerWidget {
  const HomeBudgetBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetProgressAsync = ref.watch(budgetProgressProvider);

    return budgetProgressAsync.when(
      data: (list) {
        final hasBudget = list.isNotEmpty;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasBudget 
                    ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)]
                    : [Colors.orange[400]!, Colors.orange[700]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (hasBudget ? AppColors.primary : Colors.orange).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    hasBudget ? Icons.track_changes_rounded : Icons.tips_and_updates_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasBudget ? 'Pantau Anggaranmu' : 'Atur Anggaran Bulan Ini',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          hasBudget 
                            ? 'Lihat seberapa banyak kamu telah berhemat hari ini.'
                            : 'Mulai batasi pengeluaran agar keuangan lebih sehat.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
