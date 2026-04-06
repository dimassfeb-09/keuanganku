import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_format.dart';

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
    bool isIncome = type == 'income';
    Color color = isIncome ? AppColors.income : AppColors.expense;
    
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          category != null 
              ? IconData(category!.icon, fontFamily: 'MaterialIcons')
              : (isIncome ? Icons.arrow_downward : Icons.arrow_upward),
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        category?.name ?? 'Kategori Dihapus', 
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        DateFormat('dd MMM yyyy, HH:mm').format(date),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${CurrencyFormat.convertToIdr(amount, 0)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
