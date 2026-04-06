class RecurringTransaction {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? note;
  final String walletId;
  final String categoryId;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final DateTime nextRunDate;
  final bool isActive;

  RecurringTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.note,
    required this.walletId,
    required this.categoryId,
    required this.frequency,
    required this.nextRunDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'note': note,
      'walletId': walletId,
      'categoryId': categoryId,
      'frequency': frequency,
      'nextRunDate': nextRunDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'],
      amount: double.tryParse(map['amount'].toString()) ?? 0.0,
      type: map['type'],
      note: map['note'],
      walletId: map['walletId'],
      categoryId: map['categoryId'],
      frequency: map['frequency'],
      nextRunDate: DateTime.parse(map['nextRunDate']),
      isActive: map['isActive'] == 1,
    );
  }
}
