import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_responsive.dart';
import '../../providers/app_providers.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/transaction_item.dart';
import '../../widgets/transaction_detail_modal.dart';
import '../../widgets/view_all_wallets_card.dart';
import '../wallet/wallet_management_screen.dart';
import 'widgets/home_budget_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = AppResponsive.of(context);
    final wallets = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(transactionProvider);

    double totalBalance = wallets.fold(0, (sum, item) => sum + item.balance);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryCard(totalBalance: totalBalance),
                const HomeBudgetBanner(),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    rp.pagePadding.left, 
                    8, 
                    rp.pagePadding.right, 
                    12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dompet Anda',
                        style: TextStyle(
                          fontSize: rp.isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WalletManagementScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Kelola',
                          style: TextStyle(fontSize: rp.isTablet ? 16 : 14),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: rp.isTablet ? 180 : 156,
                  child: wallets.isEmpty
                      ? Center(
                          child: Text(
                            "Belum ada dompet",
                            style: TextStyle(fontSize: rp.isTablet ? 16 : 14),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: rp.pagePadding.left),
                          itemCount: wallets.length > 3
                              ? 4
                              : (wallets.length + 1),
                          itemBuilder: (context, index) {
                            if (index < wallets.length && index < 3) {
                              final w = wallets[index];
                              return WalletCard(
                                name: w.name,
                                balance: w.balance,
                                color: Color(w.color),
                              );
                            } else {
                              return const ViewAllWalletsCard();
                            }
                          },
                        ),
                ),
                SizedBox(height: rp.sectionSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rp.pagePadding.left),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                        'Transaksi Terakhir',
                        style: TextStyle(
                          fontSize: rp.isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(navigationProvider.notifier).setIndex(1),
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(fontSize: rp.isTablet ? 16 : 14),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: rp.isTablet ? 12 : 8),
                transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            "Belum ada transaksi",
                            style: TextStyle(fontSize: rp.isTablet ? 16 : 14),
                          ),
                        ),
                      );
                    }

                    final categoriesAsync = ref.watch(categoryProvider);
                    final walletsData = ref.watch(walletProvider);

                    return categoriesAsync.when(
                      data: (categories) {
                        final latestTransactions = transactions
                            .take(5)
                            .toList();
                        return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: latestTransactions.length,
                          itemBuilder: (context, index) {
                            final t = latestTransactions[index];
                            final category = categories.firstWhere(
                              (c) => c.id == t.categoryId,
                              orElse: () => null as dynamic,
                            );
                            final wallet = walletsData.firstWhere(
                              (w) => w.id == t.walletId,
                              orElse: () => null as dynamic,
                            );

                            return TransactionItem(
                              category: category,
                              amount: t.amount,
                              type: t.type,
                              date: t.date,
                              onTap: () => showTransactionDetail(
                                context,
                                ref,
                                t,
                                category,
                                wallet,
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, st) =>
                          Text('Error loading categories: $err'),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text('Error: $err')),
                ),
                SizedBox(height: rp.isTablet ? 120 : 100), // Padding for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }
}
