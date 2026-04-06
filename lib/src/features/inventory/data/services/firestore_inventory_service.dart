import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item_model.dart';

class FirestoreInventoryService {
  FirestoreInventoryService({FirebaseFirestore? firestore})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection(
        _collectionName,
      );

  static const String _collectionName = 'inventory_items';

  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<InventoryItemModel>> streamItems() {
    return _collection.orderBy('updatedAt', descending: true).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      return snapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                InventoryItemModel.fromMap(doc.data(), doc.id),
          )
          .toList(growable: false);
    });
  }

  Future<void> addItem(InventoryItemModel item) {
    return _collection.add(item.toMap());
  }

  Future<void> updateItem(InventoryItemModel item) {
    return _collection.doc(item.id).update(item.toMap());
  }

  Future<void> deleteItem(String id) {
    return _collection.doc(id).delete();
  }
}
