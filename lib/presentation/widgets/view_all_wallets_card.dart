import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../screens/wallet/all_wallets_screen.dart';

class ViewAllWalletsCard extends StatelessWidget {
  const ViewAllWalletsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllWalletsScreen()),
        );
      },
      child: Container(
        width: rp.walletCardWidth * 0.85, // Proporsional terhadap wallet card lainnya
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: rp.cardPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(rp.isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: rp.isTablet ? 28 : 24,
                ),
              ),
              SizedBox(height: rp.isTablet ? 16 : 12),
              Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: rp.isTablet ? 16 : 14,
                ),
              ),
              Text(
                'Dompet Saya',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: rp.isTablet ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
