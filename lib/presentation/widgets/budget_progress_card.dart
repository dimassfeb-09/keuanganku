import 'package:flutter/material.dart';
import '../providers/budget_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import 'package:intl/intl.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetProgress progress;
  final String categoryName;

  const BudgetProgressCard({
    super.key,
    required this.progress,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final percentage = progress.percentage.clamp(0.0, 1.0);
    final isExceeded = progress.isExceeded;

    return Container(
      padding: rp.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: rp.isTablet ? 18 : 16,
                ),
              ),
              Text(
                '${(progress.percentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isExceeded ? AppColors.expense : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: rp.isTablet ? 16 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: rp.isTablet ? 16 : 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color: isExceeded ? AppColors.expense : AppColors.primary,
              minHeight: rp.isTablet ? 12 : 8,
            ),
          ),
          SizedBox(height: rp.isTablet ? 16 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai: ${currencyFormat.format(progress.spentAmount)}',
                style: TextStyle(
                  fontSize: rp.captionFontSize + 1, 
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Limit: ${currencyFormat.format(progress.budget.amountLimit)}',
                style: TextStyle(
                  fontSize: rp.captionFontSize + 1, 
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (isExceeded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Melebihi anggaran: ${currencyFormat.format(progress.spentAmount - progress.budget.amountLimit)}',
                style: TextStyle(
                  fontSize: rp.captionFontSize + 1, 
                  color: AppColors.expense, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Sisa: ${currencyFormat.format(progress.remaining)}',
                style: TextStyle(
                  fontSize: rp.captionFontSize + 1, 
                  color: Colors.green, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
