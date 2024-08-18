import 'package:flutter/material.dart';
import 'categories.dart'; // Import the file with the grocery items and CartItem class

class ItemSelectionPage extends StatefulWidget {
  final List<CartItem> addedItems;
  final Function(List<CartItem>) onItemsAdded;

  ItemSelectionPage({required this.addedItems, required this.onItemsAdded});

  @override
  _ItemSelectionPageState createState() => _ItemSelectionPageState();
}

class _ItemSelectionPageState extends State<ItemSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedCategories = [];
  List<GroceryItem> _filteredItems = groceryItems;

  void _filterItems(String query) {
    setState(() {
      _filteredItems = groceryItems.where((item) {
        final matchesQuery =
            item.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategories.isEmpty ||
            _selectedCategories.contains(item.category);
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select Categories'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: categories.map((category) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: _selectedCategories.contains(category),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                          _filterItems(_searchController
                              .text); // Apply the category filter
                        });
                      },
                    );
                  }).toList()
                    ..add(
                      CheckboxListTile(
                        title: Text('All'),
                        value: _selectedCategories.isEmpty,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              _selectedCategories.clear();
                            }
                            _filterItems(_searchController
                                .text); // Apply the category filter
                          });
                        },
                      ),
                    ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuantityDialog(GroceryItem item) {
    final TextEditingController _quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adjust Quantity for ${item.name}'),
          content: TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              hintText: 'Enter quantity',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int quantity = int.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0) {
                  setState(() {
                    int existingIndex = widget.addedItems
                        .indexWhere((cartItem) => cartItem.item == item);
                    if (existingIndex != -1) {
                      widget.addedItems[existingIndex].quantity += quantity;
                    } else {
                      widget.addedItems
                          .add(CartItem(item: item, quantity: quantity));
                    }
                  });

                  widget.onItemsAdded(widget.addedItems);

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} added to your order!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Items'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showCategoryFilterDialog, // Show filter dialog
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _filteredItems.map((item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                        '${item.category} - Peso ${item.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _showQuantityDialog(item),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
