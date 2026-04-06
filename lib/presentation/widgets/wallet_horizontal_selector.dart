import 'package:flutter/material.dart';
import '../../data/models/wallet_model.dart';
import '../../core/utils/currency_format.dart';

class WalletHorizontalSelector extends StatelessWidget {
  final List<Wallet> wallets;
  final String? selectedWalletId;
  final Function(String) onSelected;

  const WalletHorizontalSelector({
    super.key,
    required this.wallets,
    this.selectedWalletId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Dompet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              bool isSelected = wallet.id == selectedWalletId;
              Color walletColor = Color(wallet.color);

              return GestureDetector(
                onTap: () => onSelected(wallet.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? walletColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected 
                      ? null 
                      : Border.all(color: Colors.grey[300]!, width: 1.5),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: walletColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ] : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        wallet.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormat.convertToIdr(wallet.balance, 0),
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
