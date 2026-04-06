class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final DateTime updatedAt;

  double get totalValue => quantity * price;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    double? price,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
