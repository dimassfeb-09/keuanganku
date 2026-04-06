import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransactionTypeSelector extends StatelessWidget {
  final String selectedType; // 'income' or 'expense'
  final Function(String) onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isExpense = selectedType == 'expense';

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isExpense ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.44, // Roughly half minus padding
              decoration: BoxDecoration(
                color: isExpense ? AppColors.expense : AppColors.income,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged('expense'),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Pengeluaran',
                      style: TextStyle(
                        color: isExpense ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged('income'),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Pemasukan',
                      style: TextStyle(
                        color: !isExpense ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
