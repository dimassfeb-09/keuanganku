import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/app_responsive.dart';
import '../../providers/app_providers.dart';
import 'add_edit_wallet_screen.dart';

class WalletManagementScreen extends ConsumerWidget {
  const WalletManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _WalletManagementScreenContent();
  }
}

class _WalletManagementScreenContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = AppResponsive.of(context);
    final wallets = ref.watch(walletProvider);

    // Hitung total saldo
    final totalBalance = wallets.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Dompet'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(rp.pagePadding.left, 20, rp.pagePadding.right, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // HEADER: TOTAL BALANCE OVERVIEW
            _buildTotalOverview(rp, totalBalance),
  
            const SizedBox(height: 32),
            Text(
              'Daftar Dompet',
              style: TextStyle(
                fontSize: rp.isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
  
            // LIST WALLETS + ADD CARD
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length + 1,
              itemBuilder: (context, index) {
                if (index < wallets.length) {
                  final wallet = wallets[index];
                  return _buildWalletCard(context, ref, rp, wallet);
                } else {
                  return _buildAddWalletCard(context, rp);
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalOverview(AppResponsive rp, double total) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Keseluruhan Saldo',
            style: TextStyle(
              color: Colors.white70, 
              fontSize: rp.isTablet ? 16 : 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormat.convertToIdr(total, 0),
            style: TextStyle(
              color: Colors.white,
              fontSize: rp.isTablet ? 40 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WidgetRef ref, AppResponsive rp, dynamic wallet) {
    final color = Color(wallet.color);

    return GestureDetector(
      onTap: () => _showWalletOptions(context, ref, rp, wallet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: rp.cardPadding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                  wallet.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rp.isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white70,
                  size: rp.isTablet ? 30 : 24,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Saldo Tersedia',
              style: TextStyle(
                color: Colors.white70, 
                fontSize: rp.isTablet ? 14 : 12,
              ),
            ),
            Text(
              CurrencyFormat.convertToIdr(wallet.balance, 0),
              style: TextStyle(
                color: Colors.white,
                fontSize: rp.isTablet ? 30 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWalletCard(BuildContext context, AppResponsive rp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditWalletScreen()),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.2,
              ),
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
            padding: EdgeInsets.symmetric(
              vertical: rp.isTablet ? 24 : 16, 
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                    size: rp.isTablet ? 24 : 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Tambah Dompet Baru',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: rp.isTablet ? 18 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWalletOptions(BuildContext context, WidgetRef ref, AppResponsive rp, dynamic wallet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            rp.isTablet ? 32 : 24, 
            24, 
            rp.isTablet ? 32 : 24, 
            32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Opsi Dompet',
                style: TextStyle(
                  fontSize: rp.isTablet ? 22 : 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _optionTile(
                Icons.edit_outlined,
                'Edit Dompet',
                Colors.indigo,
                rp,
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditWalletScreen(wallet: wallet),
                    ),
                  );
                },
              ),
              _optionTile(
                Icons.delete_outline, 
                'Hapus Dompet', 
                Colors.red, 
                rp,
                () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref, wallet);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _optionTile(
    IconData icon,
    String label,
    Color color,
    AppResponsive rp,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon, 
        color: color,
        size: rp.isTablet ? 28 : 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.bold,
          fontSize: rp.isTablet ? 18 : 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dompet?'),
        content: const Text(
          'Menghapus dompet ini juga akan menghapus semua riwayat transaksi terkait.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(walletProvider.notifier).deleteWallet(wallet.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
