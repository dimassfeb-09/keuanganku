import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_responsive.dart';

class AllWalletsScreen extends ConsumerWidget {
  const AllWalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = AppResponsive.of(context);
    final wallets = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Semua Dompet'),
        backgroundColor: AppColors.background,
      ),
      body: wallets.isEmpty
          ? Center(
              child: Text(
                "Belum ada dompet",
                style: TextStyle(
                  fontSize: rp.isTablet ? 18 : 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: rp.pagePadding,
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: rp.cardPadding,
                  decoration: BoxDecoration(
                    color: Color(wallet.color),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Color(wallet.color).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(rp.isTablet ? 14 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet, 
                          color: Colors.white,
                          size: rp.isTablet ? 28 : 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: rp.isTablet ? 22 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Saldo Tersedia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: rp.isTablet ? 15 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormat.convertToIdr(wallet.balance, 0),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rp.isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
