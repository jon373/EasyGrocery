import 'package:flutter/material.dart';
import 'categories.dart'; // Import the file with the grocery items and quantityItem class
import 'searchItem.dart';
import 'checkout.dart';

class HomePage extends StatefulWidget {
  @override
  _GroceryHomePageState createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<HomePage> {
  final TextEditingController _budgetController = TextEditingController();
  double _totalAmount = 0.0;

  List<quantityItem> _addedItems =
      []; // List to hold added items and their quantities

  void _increaseQuantity(quantityItem quantityItem) {
    setState(() {
      quantityItem.quantity++;
      _totalAmount += quantityItem.item.price; // Update total amount
    });
  }

  void _decreaseQuantity(quantityItem quantityItem) {
    if (quantityItem.quantity > 1) {
      setState(() {
        quantityItem.quantity--;
        _totalAmount -= quantityItem.item.price; // Update total amount
      });
    } else {
      // Show confirmation dialog to remove the item
      _showRemoveConfirmationDialog(quantityItem);
    }
  }

  void _showRemoveConfirmationDialog(quantityItem quantityItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Item'),
          content: Text(
              'Are you sure you want to remove ${quantityItem.item.name} from the cart?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _totalAmount -= quantityItem.item.price *
                      quantityItem.quantity; // Update total amount
                  _addedItems
                      .remove(quantityItem); // Remove the item from the cart
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

  void _showRelevantItems(quantityItem quantityItem) {
    // Get the category and name of the selected item
    String selectedCategory = quantityItem.item.category;
    String selectedItemName = quantityItem.item.name.toLowerCase();

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
                    'Relevant Items for ${quantityItem.item.name}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: relevantItems.map((item) {
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                              '${item.category} - P${item.price.toStringAsFixed(2)}'),
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

  void _updateAddedItems(List<quantityItem> items) {
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
              'Remaining Budget: P${remainingBudget.toStringAsFixed(2)}',
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
                      builder: (context) => Searchitem(
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
                  ..._addedItems.map((quantityItem) {
                    return ListTile(
                      onTap: () => _showRelevantItems(
                          quantityItem), // Show relevant items when tapped
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(quantityItem.item.name),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () =>
                                    _decreaseQuantity(quantityItem),
                              ),
                              Text('${quantityItem.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () =>
                                    _increaseQuantity(quantityItem),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(
                          'Total: P${(quantityItem.item.price * quantityItem.quantity).toStringAsFixed(2)}'),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: P${_totalAmount.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          addedItems: _addedItems,
                          totalAmount: _totalAmount,
                          onAddressSelected: (String selectedAddress) {
                            // Handle address selection here
                            print('Selected address: $selectedAddress');
                          },
                          onPaymentMethodSelected:
                              (String selectedPaymentMethod) {
                            // Handle payment method selection here
                            print(
                                'Selected payment method: $selectedPaymentMethod');
                          },
                        ),
                      ),
                    );
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
