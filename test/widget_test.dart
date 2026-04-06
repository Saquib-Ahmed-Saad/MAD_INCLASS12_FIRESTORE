import 'package:flutter_test/flutter_test.dart';
import 'package:mad_inclass12_firestore/src/core/validators/inventory_validators.dart';

void main() {
  group('InventoryValidators', () {
    test('requiredText rejects empty values', () {
      expect(
        InventoryValidators.requiredText('', 'Item name'),
        'Item name is required',
      );
    });

    test('quantity validates numeric and positive values', () {
      expect(
        InventoryValidators.quantity('abc'),
        'Quantity must be a whole number',
      );
      expect(InventoryValidators.quantity('-1'), 'Quantity cannot be negative');
      expect(InventoryValidators.quantity('2'), isNull);
    });

    test('price validates numeric and greater-than-zero values', () {
      expect(InventoryValidators.price('abc'), 'Price must be numeric');
      expect(InventoryValidators.price('0'), 'Price must be greater than 0');
      expect(InventoryValidators.price('19.99'), isNull);
    });
  });
}
