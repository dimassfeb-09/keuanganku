import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../budget/budget_screen.dart';
import '../category/category_management_screen.dart';
import '../wallet/wallet_management_screen.dart';
import '../../providers/app_providers.dart';
import '../../providers/category_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/chart_provider.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/utils/app_responsive.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = AppResponsive.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(rp.pagePadding.left, 20, rp.pagePadding.right, 20),
      children: [
        Text(
          'Kelola Data',
          style: TextStyle(
            fontSize: rp.isTablet ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        _buildManagementCard(
          context: context,
          rp: rp,
          title: 'Dompet & Saldo',
          subtitle: 'Atur daftar dompet penyimpanan',
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WalletManagementScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildManagementCard(
          context: context,
          rp: rp,
          title: 'Kategori Transaksi',
          subtitle: 'Atur kategori pemasukan/pengeluaran',
          icon: Icons.category_rounded,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryManagementScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildManagementCard(
          context: context,
          rp: rp,
          title: 'Anggaran Bulanan',
          subtitle: 'Atur limit pengeluaran bulanan',
          icon: Icons.track_changes_rounded,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BudgetScreen()),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Lainnya',
          style: TextStyle(
            fontSize: rp.isTablet ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          rp: rp,
          title: 'Hapus Semua Data',
          subtitle: 'Reset aplikasi ke pengaturan awal',
          icon: Icons.delete_forever_rounded,
          color: Colors.red,
          onTap: () => _confirmReset(context, ref),
        ),
        const Divider(height: 32),
        AboutListTile(
          icon: Icon(Icons.info_outline_rounded, size: rp.isTablet ? 28 : 24),
          applicationName: 'Keuanganku',
          applicationVersion: '1.0.0 (MVP)',
          applicationLegalese: '© 2026 Dimas',
          child: Text(
            'Tentang Aplikasi', 
            style: TextStyle(fontSize: rp.isTablet ? 17 : 15),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required AppResponsive rp,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(rp.isTablet ? 24 : 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(rp.isTablet ? 14 : 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: rp.isTablet ? 32 : 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: rp.isTablet ? 18 : 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600], 
                      fontSize: rp.isTablet ? 15 : 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded, 
              color: Colors.grey[400],
              size: rp.isTablet ? 28 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required AppResponsive rp,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(rp.isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: rp.isTablet ? 28 : 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.bold,
          fontSize: rp.isTablet ? 17 : 15,
        ),
      ),
      subtitle: Text(
        subtitle, 
        style: TextStyle(fontSize: rp.isTablet ? 14 : 12),
      ),
      onTap: onTap,
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Reset Factory Data?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Seluruh data berikut akan DIHAPUS PERMANEN:'),
            SizedBox(height: 8),
            Text('• Semua Riwayat Transaksi'),
            Text('• Semua Dompet & Saldo'),
            Text('• Semua Kategori Kustom'),
            Text('• Semua Anggaran (Budget)'),
            SizedBox(height: 12),
            Text(
              'Aplikasi akan dikembalikan ke pengaturan awal pabrik.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              await DatabaseHelper.instance.resetDatabase();

              // Invalidate all relevant providers
              ref.invalidate(walletProvider);
              ref.invalidate(transactionProvider);
              ref.invalidate(categoryProvider);
              ref.invalidate(budgetProvider);
              ref.invalidate(recurringProvider);
              ref.invalidate(categoryExpenseChartProvider);

              if (context.mounted) {
                Navigator.pop(context); // Close loading
                Navigator.pop(context); // Close confirm dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aplikasi telah di-reset ke pengaturan awal'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('YA, HAPUS SEMUA'),
          ),
        ],
      ),
    );
  }
}
