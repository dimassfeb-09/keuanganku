import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/category_model.dart';

class TransactionItem extends StatelessWidget {
  final Category? category;
  final double amount;
  final String type;
  final DateTime date;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    bool isIncome = type == 'income';
    Color color = isIncome ? AppColors.income : AppColors.expense;
    
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: rp.pagePadding.left, 
        vertical: rp.isTablet ? 8 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(rp.isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          category != null 
              ? IconData(category!.icon, fontFamily: 'MaterialIcons')
              : (isIncome ? Icons.arrow_downward : Icons.arrow_upward),
          color: color,
          size: rp.isTablet ? 28 : 24,
        ),
      ),
      title: Text(
        category?.name ?? 'Kategori Dihapus', 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontSize: rp.isTablet ? 18 : 16,
        ),
      ),
      subtitle: Text(
        DateFormat('dd MMM yyyy, HH:mm').format(date),
        style: TextStyle(
          color: AppColors.textSecondary, 
          fontSize: rp.captionFontSize + 2,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${CurrencyFormat.convertToIdr(amount, 0)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: rp.isTablet ? 18 : 16,
        ),
      ),
    );
  }
}
