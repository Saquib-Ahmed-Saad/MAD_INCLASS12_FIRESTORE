class InventoryValidators {
  static String? requiredText(String? value, String fieldLabel) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldLabel is required';
    }
    return null;
  }

  static String? quantity(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Quantity is required';
    }

    final parsed = int.tryParse(value!.trim());
    if (parsed == null) {
      return 'Quantity must be a whole number';
    }

    if (parsed < 0) {
      return 'Quantity cannot be negative';
    }

    return null;
  }

  static String? price(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Price is required';
    }

    final parsed = double.tryParse(value!.trim());
    if (parsed == null) {
      return 'Price must be numeric';
    }

    if (parsed <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }
}
