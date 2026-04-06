class Category {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final int icon;
  final int color;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      color: map['color'] ?? 0xFF9E9E9E, // Default to grey if null
      isActive: map['isActive'] == 1,
    );
  }
}
