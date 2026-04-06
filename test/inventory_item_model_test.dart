import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mad_inclass12_firestore/src/features/inventory/data/models/inventory_item_model.dart';

void main() {
  test('InventoryItemModel toMap and fromMap preserve data', () {
    final now = DateTime(2026, 4, 6, 12, 0);
    final model = InventoryItemModel(
      id: 'abc123',
      name: 'Wireless Mouse',
      category: 'Electronics',
      quantity: 4,
      price: 29.5,
      updatedAt: DateTime(2026, 4, 6, 12, 0),
    );

    final map = model.toMap();
    expect(map['name'], 'Wireless Mouse');
    expect(map['category'], 'Electronics');
    expect(map['quantity'], 4);
    expect(map['price'], 29.5);
    expect(map['updatedAt'], isA<Timestamp>());

    final rebuilt = InventoryItemModel.fromMap(<String, dynamic>{
      'name': 'Wireless Mouse',
      'category': 'Electronics',
      'quantity': 4,
      'price': 29.5,
      'updatedAt': Timestamp.fromDate(now),
    }, 'abc123');

    expect(rebuilt.id, 'abc123');
    expect(rebuilt.name, 'Wireless Mouse');
    expect(rebuilt.category, 'Electronics');
    expect(rebuilt.quantity, 4);
    expect(rebuilt.price, 29.5);
    expect(rebuilt.updatedAt, now);
  });
}
