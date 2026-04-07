import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/app_responsive.dart';

class SummaryCard extends StatelessWidget {
  final double totalBalance;

  const SummaryCard({super.key, required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    
    return Padding(
      padding: rp.pagePadding.copyWith(top: 16.0, bottom: 8.0),
      child: Container(
        width: double.infinity,
        padding: rp.cardPadding,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.account_balance_wallet,
                size: rp.isTablet ? 200 : 150,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.white70, size: rp.isTablet ? 24 : 20),
                    const SizedBox(width: 8),
                    Text(
                      'Total Saldo Saya',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: rp.captionFontSize + 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormat.convertToIdr(totalBalance, 0),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rp.displayFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: rp.isTablet ? 24 : 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Aktif & Aman 🔒',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: rp.captionFontSize + 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
