import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_responsive.dart';
import 'home/home_screen.dart';
import 'transaction/transaction_list_screen.dart';
import 'settings/settings_screen.dart';
import 'transaction/add_transaction_screen.dart';
import '../providers/navigation_provider.dart';

import '../providers/recurring_provider.dart';

import 'insight/insight_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringProvider.notifier).processRecurrings();
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const TransactionListScreen(),
    const InsightScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Keuanganku',
    'Riwayat Transaksi',
    'Analisis Keuangan',
    'Pengaturan',
  ];

  List<Widget>? _getActions() {
    return null;
  }

  void _onAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final rp = AppResponsive.of(context);

    if (rp.isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_titles[currentIndex]),
          centerTitle: false,
          actions: _getActions(),
        ),
        body: Row(
          children: [
            NavigationRail(
              extended: rp.screenWidth >= 840,
              minWidth: rp.navRailMinWidth,
              minExtendedWidth: 260,
              backgroundColor: Colors.white,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                ref.read(navigationProvider.notifier).setIndex(index);
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: rp.screenWidth >= 840
                    ? FloatingActionButton.extended(
                        onPressed: _onAddTransaction,
                        icon: const Icon(Icons.add_rounded, size: 28),
                        label: const Text(
                          'Transaksi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        elevation: 4,
                      )
                    : FloatingActionButton(
                        onPressed: _onAddTransaction,
                        tooltip: 'Tambah Transaksi',
                        child: const Icon(Icons.add_rounded, size: 28),
                      ),
              ),
              labelType: rp.screenWidth >= 840 
                  ? NavigationRailLabelType.none 
                  : NavigationRailLabelType.all,
              selectedIconTheme: IconThemeData(
                size: rp.navRailIconSize,
                color: Theme.of(context).primaryColor,
              ),
              unselectedIconTheme: IconThemeData(
                size: rp.navRailIconSize - 2,
                color: Colors.grey[600],
              ),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
              indicatorColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              destinations: const [
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Beranda'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: Text('Riwayat'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  icon: Icon(Icons.pie_chart_outline),
                  selectedIcon: Icon(Icons.pie_chart),
                  label: Text('Insight'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Pengaturan'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    // Phone Layout
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
        centerTitle: true,
        actions: _getActions(),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTransaction,
        tooltip: 'Tambah Transaksi',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
            _buildBottomNavItem(1, Icons.history_rounded, Icons.history_outlined, 'Riwayat'),
            const SizedBox(width: 48), // Space for FAB
            _buildBottomNavItem(2, Icons.analytics_rounded, Icons.pie_chart_outline, 'Insight'),
            _buildBottomNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Atur'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final currentIndex = ref.watch(navigationProvider);
    final isSelected = currentIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[600];

    return InkWell(
      onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
