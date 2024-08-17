import 'package:flutter/material.dart';
import 'categories.dart'; // Import the file with the grocery items and CartItem class

class GroceryHomePage extends StatefulWidget {
  @override
  _GroceryHomePageState createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<GroceryHomePage> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  double _totalAmount = 0.0;

  List<CartItem> _addedItems =
      []; // List to hold added items and their quantities
  List<GroceryItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = []; // Start with an empty list
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = []; // Show no items if query is empty
      } else {
        _filteredItems = groceryItems
            .where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int quantity = int.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0) {
                  setState(() {
                    // Check if the item already exists in the added items list
                    int existingIndex = _addedItems
                        .indexWhere((cartItem) => cartItem.item == item);
                    if (existingIndex != -1) {
                      // Update the quantity for the existing item
                      _addedItems[existingIndex].quantity +=
                          quantity; // Increase the quantity
                    } else {
                      // Add the item and quantity to the added items list
                      _addedItems.add(CartItem(item: item, quantity: quantity));
                    }
                    _totalAmount +=
                        item.price * quantity; // Update total amount
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  void _increaseQuantity(CartItem cartItem) {
    setState(() {
      cartItem.quantity++;
      _totalAmount += cartItem.item.price; // Update total amount
    });
  }

  void _decreaseQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      setState(() {
        cartItem.quantity--;
        _totalAmount -= cartItem.item.price; // Update total amount
      });
    } else {
      // Show confirmation dialog to remove the item
      _showRemoveConfirmationDialog(cartItem);
    }
  }

  void _showRemoveConfirmationDialog(CartItem cartItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Item'),
          content: Text(
              'Are you sure you want to remove ${cartItem.item.name} from the cart?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _totalAmount -= cartItem.item.price; // Update total amount
                  _addedItems.remove(cartItem); // Remove the item from the cart
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse the budget from the text field
    double budget = double.tryParse(_budgetController.text) ?? 0.0;
    double remainingBudget =
        budget - _totalAmount; // Calculate remaining budget

    return Scaffold(
      appBar: AppBar(
        title: Text('EasyGrocery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Budget: '),
                Expanded(
                  child: TextField(
                    controller: _budgetController,
                    decoration: InputDecoration(
                      hintText: 'Enter your budget',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {}); // Update the UI when the budget changes
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Display remaining budget
            Text(
              'Remaining Budget: Peso ${remainingBudget.toStringAsFixed(2)}',
              style: TextStyle(
                color: remainingBudget < 0 ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (remainingBudget < 0)
              Text(
                'You have exceeded your budget!',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems, // Filter items as you type
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.filter_list),
                        onPressed: () {
                          // Logic for filtering categories
                        },
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _filteredItems.isEmpty &&
                            _searchController.text.isNotEmpty
                        ? Center(child: Text('No items found'))
                        : ListView(
                            children: [
                              ..._filteredItems.map((item) {
                                return ListTile(
                                  title: Text(item.name),
                                  subtitle: Text(
                                      '${item.category} - Peso ${item.price.toStringAsFixed(2)}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () => _showQuantityDialog(
                                        item), // Show dialog on button press
                                  ),
                                );
                              }),
                              ..._addedItems.map((cartItem) {
                                return ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(cartItem.item.name),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () =>
                                                _decreaseQuantity(cartItem),
                                          ),
                                          Text('${cartItem.quantity}'),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () =>
                                                _increaseQuantity(cartItem),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                      'Total: Peso ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}'),
                                );
                              }),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: Peso ${_totalAmount.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: () {
                    // Checkout button logic here
                  },
                  child: Text('Check Out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
