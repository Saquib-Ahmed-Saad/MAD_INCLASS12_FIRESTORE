import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Stream<List<InventoryItem>> streamItems();

  Future<void> addItem(InventoryItem item);

  Future<void> updateItem(InventoryItem item);

  Future<void> deleteItem(String id);
}
