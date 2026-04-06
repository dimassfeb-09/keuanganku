class Transaction {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String? note;
  final String walletId;
  final String categoryId;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    required this.walletId,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
      'walletId': walletId,
      'categoryId': categoryId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      walletId: map['walletId'],
      categoryId: map['categoryId'],
    );
  }
}
