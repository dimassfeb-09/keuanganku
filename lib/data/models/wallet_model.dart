class Wallet {
  final String id;
  final String name;
  final double balance;
  final int color;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'color': color,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      color: map['color'],
    );
  }
}
