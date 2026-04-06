import 'package:flutter/material.dart';

import '../../../../core/validators/inventory_validators.dart';
import '../../data/repositories/firestore_inventory_repository.dart';
import '../../data/services/firestore_inventory_service.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, InventoryRepository? repository})
    : _repository = repository;

  final InventoryRepository? _repository;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late final InventoryRepository _repository =
      widget._repository ??
      FirestoreInventoryRepository(FirestoreInventoryService());

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _lowStockOnly = false;
  static const int _lowStockLimit = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Manager')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openItemForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Search by item or category',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: (String value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
              },
            ),
          ),
          SwitchListTile.adaptive(
            title: const Text('Low-stock only'),
            subtitle: Text('Show items with quantity <= $_lowStockLimit'),
            value: _lowStockOnly,
            onChanged: (bool value) {
              setState(() => _lowStockOnly = value);
            },
          ),
          Expanded(
            child: StreamBuilder<List<InventoryItem>>(
              stream: _repository.streamItems(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<InventoryItem>> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Error loading inventory: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = snapshot.data ?? <InventoryItem>[];
                    final filteredItems = _applyFilters(items);

                    if (filteredItems.isEmpty) {
                      return const _EmptyState();
                    }

                    final totalValue = filteredItems.fold<double>(
                      0,
                      (double sum, InventoryItem item) => sum + item.totalValue,
                    );

                    return Column(
                      children: <Widget>[
                        _SummaryHeader(
                          itemCount: filteredItems.length,
                          inventoryValue: totalValue,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = filteredItems[index];
                              final isLowStock =
                                  item.quantity <= _lowStockLimit;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  title: Text(item.name),
                                  subtitle: Text(
                                    '${item.category} | Qty: ${item.quantity} | \$${item.price.toStringAsFixed(2)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      if (isLowStock)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      IconButton(
                                        onPressed: () =>
                                            _openItemForm(existing: item),
                                        icon: const Icon(Icons.edit),
                                        tooltip: 'Edit item',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteItem(item),
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Delete item',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  List<InventoryItem> _applyFilters(List<InventoryItem> items) {
    return items
        .where((InventoryItem item) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              item.name.toLowerCase().contains(_searchQuery) ||
              item.category.toLowerCase().contains(_searchQuery);
          final matchesLowStock =
              !_lowStockOnly || item.quantity <= _lowStockLimit;
          return matchesSearch && matchesLowStock;
        })
        .toList(growable: false);
  }

  Future<void> _openItemForm({InventoryItem? existing}) async {
    final result = await showDialog<_ItemFormData>(
      context: context,
      builder: (BuildContext context) => _ItemFormDialog(item: existing),
    );

    if (result == null) {
      return;
    }

    final now = DateTime.now();

    try {
      if (existing == null) {
        await _repository.addItem(
          InventoryItem(
            id: '',
            name: result.name,
            category: result.category,
            quantity: result.quantity,
            price: result.price,
            updatedAt: now,
          ),
        );
      } else {
        await _repository.updateItem(
          existing.copyWith(
            name: result.name,
            category: result.category,
            quantity: result.quantity,
            price: result.price,
            updatedAt: now,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existing == null ? 'Item added' : 'Item updated'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Operation failed: $error')));
      }
    }
  }

  Future<void> _deleteItem(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete item'),
          content: Text('Delete ${item.name}? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item deleted')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
      }
    }
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.itemCount, required this.inventoryValue});

  final int itemCount;
  final double inventoryValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Visible Items',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$itemCount',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Visible Value',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${inventoryValue.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No inventory items found. Tap Add Item to create one.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ItemFormDialog extends StatefulWidget {
  const _ItemFormDialog({this.item});

  final InventoryItem? item;

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;

  static const List<String> _categories = <String>[
    'General',
    'Electronics',
    'Food',
    'Office',
    'Health',
  ];

  late String _category;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: item?.price.toStringAsFixed(2) ?? '',
    );
    _category = item?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (String? value) =>
                    InventoryValidators.requiredText(value, 'Item name'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (String category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: InventoryValidators.quantity,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: InventoryValidators.price,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _ItemFormData(
        name: _nameController.text.trim(),
        category: _category,
        quantity: int.parse(_quantityController.text.trim()),
        price: double.parse(_priceController.text.trim()),
      ),
    );
  }
}

class _ItemFormData {
  const _ItemFormData({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
  });

  final String name;
  final String category;
  final int quantity;
  final double price;
}
