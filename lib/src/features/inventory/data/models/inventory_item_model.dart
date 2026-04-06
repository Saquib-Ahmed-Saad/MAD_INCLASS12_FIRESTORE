import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/inventory_item.dart';

class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.quantity,
    required super.price,
    required super.updatedAt,
  });

  factory InventoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['updatedAt'];
    final updatedAt = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.now();

    return InventoryItemModel(
      id: id,
      name: (map['name'] as String? ?? '').trim(),
      category: (map['category'] as String? ?? 'General').trim(),
      quantity: (map['quantity'] as num? ?? 0).toInt(),
      price: (map['price'] as num? ?? 0).toDouble(),
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory InventoryItemModel.fromEntity(InventoryItem item) {
    return InventoryItemModel(
      id: item.id,
      name: item.name,
      category: item.category,
      quantity: item.quantity,
      price: item.price,
      updatedAt: item.updatedAt,
    );
  }
}
