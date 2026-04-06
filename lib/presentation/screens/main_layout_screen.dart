import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        tooltip: 'Tambah Transaksi',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                color: currentIndex == 0 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onPressed: () => ref.read(navigationProvider.notifier).setIndex(0),
            ),
            IconButton(
              icon: Icon(
                Icons.history,
                color: currentIndex == 1 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onPressed: () => ref.read(navigationProvider.notifier).setIndex(1),
            ),
            const SizedBox(width: 48), // Space for floating button
            IconButton(
              icon: Icon(
                Icons.pie_chart,
                color: currentIndex == 2 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onPressed: () => ref.read(navigationProvider.notifier).setIndex(2),
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: currentIndex == 3 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onPressed: () => ref.read(navigationProvider.notifier).setIndex(3),
            ),
          ],
        ),
      ),
    );
  }
}
