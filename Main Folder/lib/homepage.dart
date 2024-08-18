import 'package:flutter/material.dart';
import 'categories.dart'; // Import the file with the grocery items and CartItem class
import 'searchItem.dart';

class GroceryHomePage extends StatefulWidget {
  @override
  _GroceryHomePageState createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<GroceryHomePage> {
  final TextEditingController _budgetController = TextEditingController();
  double _totalAmount = 0.0;

  List<CartItem> _addedItems =
      []; // List to hold added items and their quantities

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
                  _totalAmount -= cartItem.item.price *
                      cartItem.quantity; // Update total amount
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

  void _showRelevantItems(CartItem cartItem) {
    // Get the category and name of the selected item
    String selectedCategory = cartItem.item.category;
    String selectedItemName = cartItem.item.name.toLowerCase();

    // Filter items based on the selected item's category and exclude the selected item
    List<GroceryItem> relevantItems = groceryItems.where((item) {
      return item.category.toLowerCase() == selectedCategory.toLowerCase() &&
          item.name.toLowerCase() !=
              selectedItemName; // Exclude the selected item
    }).toList();

    // Sort items by name relevance and then by price
    relevantItems.sort((a, b) {
      // Calculate name relevance for both items
      int relevanceA =
          _calculateNameRelevance(a.name.toLowerCase(), selectedItemName);
      int relevanceB =
          _calculateNameRelevance(b.name.toLowerCase(), selectedItemName);

      // First sort by name relevance (lower value means more relevant)
      if (relevanceA != relevanceB) {
        return relevanceA.compareTo(relevanceB);
      }

      // If name relevance is the same, sort by price (ascending)
      return a.price.compareTo(b.price);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: 300,
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Relevant Items for ${cartItem.item.name}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: relevantItems.map((item) {
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                              '${item.category} - Peso ${item.price.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _calculateNameRelevance(String itemName, String selectedItemName) {
    // Use a simple method to determine name relevance
    if (itemName == selectedItemName) {
      return 0; // Exact match
    }

    if (itemName.contains(selectedItemName)) {
      return 1; // Partial match
    }

    // Calculate partial relevance based on common words
    List<String> selectedWords = selectedItemName.split(' ');
    int matchCount =
        selectedWords.where((word) => itemName.contains(word)).length;

    if (matchCount > 0) {
      return 2; // Partially relevant
    }

    return 3; // Least relevant
  }

  void _updateAddedItems(List<CartItem> items) {
    setState(() {
      _addedItems = items;
      _totalAmount = _addedItems.fold(
          0, (sum, item) => sum + item.item.price * item.quantity);
    });
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
            // Add Item Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the item selection page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemSelectionPage(
                        addedItems: _addedItems,
                        onItemsAdded: _updateAddedItems, // Update added items
                      ),
                    ),
                  );
                },
                child: Text('Add Item'),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ..._addedItems.map((cartItem) {
                    return ListTile(
                      onTap: () => _showRelevantItems(
                          cartItem), // Show relevant items when tapped
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cartItem.item.name),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () => _decreaseQuantity(cartItem),
                              ),
                              Text('${cartItem.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () => _increaseQuantity(cartItem),
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
