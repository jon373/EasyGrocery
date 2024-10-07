import 'package:flutter/material.dart';
import 'package:EasyGrocery/provider/categories.dart';

class Searchitem extends StatefulWidget {
  final List<quantityItem> addedItems;
  final Function(List<quantityItem>) onItemsAdded;

  const Searchitem(
      {super.key, required this.addedItems, required this.onItemsAdded});

  @override
  _SearchitemState createState() => _SearchitemState();
}

class _SearchitemState extends State<Searchitem> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedCategories = [];
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
              title: const Text('Select Categories'),
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
                        title: const Text('All'),
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
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuantityDialog(GroceryItem item) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int currentQuantity = 1; // Initialize the quantity to 1

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Quantity for ${item.name}'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (currentQuantity > 1) {
                          currentQuantity--;
                        }
                      });
                    },
                  ),
                  Text(
                    '$currentQuantity',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        currentQuantity++;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (currentQuantity > 0) {
                      setState(() {
                        int existingIndex = widget.addedItems.indexWhere(
                            (quantityItem) => quantityItem.item == item);
                        if (existingIndex != -1) {
                          widget.addedItems[existingIndex].quantity +=
                              currentQuantity;
                        } else {
                          widget.addedItems.add(quantityItem(
                              item: item, quantity: currentQuantity));
                        }
                      });

                      widget.onItemsAdded(widget.addedItems);

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to your order!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
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
              decoration: const InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _filteredItems.map((item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                        '${item.category} - ₱${item.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
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
