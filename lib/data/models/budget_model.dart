class Budget {
  final String id;
  final String categoryId;
  final double amountLimit;
  final String monthYear; // Format: MM-yyyy

  Budget({
    required this.id,
    required this.categoryId,
    required this.amountLimit,
    required this.monthYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amountLimit': amountLimit,
      'monthYear': monthYear,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      amountLimit: map['amountLimit'] as double,
      monthYear: map['monthYear'],
    );
  }
}
