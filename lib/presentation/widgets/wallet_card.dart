import 'package:flutter/material.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/app_responsive.dart';

class WalletCard extends StatelessWidget {
  final String name;
  final double balance;
  final Color color;

  const WalletCard({
    super.key,
    required this.name,
    required this.balance,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    
    return Container(
      width: rp.walletCardWidth,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: rp.isTablet ? 120 : 80,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(rp.isTablet ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.credit_card, color: Colors.white, size: rp.isTablet ? 20 : 16),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: rp.captionFontSize + 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormat.convertToIdr(balance, 0),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rp.isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
