import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';
import '../services/firestore_inventory_service.dart';

class FirestoreInventoryRepository implements InventoryRepository {
  FirestoreInventoryRepository(this._service);

  final FirestoreInventoryService _service;

  @override
  Future<void> addItem(InventoryItem item) {
    final model = InventoryItemModel.fromEntity(item);
    return _service.addItem(model);
  }

  @override
  Future<void> deleteItem(String id) {
    return _service.deleteItem(id);
  }

  @override
  Stream<List<InventoryItem>> streamItems() {
    return _service.streamItems();
  }

  @override
  Future<void> updateItem(InventoryItem item) {
    final model = InventoryItemModel.fromEntity(item);
    return _service.updateItem(model);
  }
}
