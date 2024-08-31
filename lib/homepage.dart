import 'package:flutter/material.dart';
import 'categories.dart';
import 'package:google_fonts/google_fonts.dart';
import 'smart_calendar.dart';

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
            decoration: const InputDecoration(
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
              child: const Text('Cancel'),
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
                      _addedItems.add(CartItem(
                          item: item, quantity: quantity, dailyConsumption: 3));
                    }
                    _totalAmount +=
                        item.price * quantity; // Update total amount
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Add to Cart'),
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
          title: const Text('Remove Item'),
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
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
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
        elevation: 0,
        backgroundColor: const Color(0xFFfbf7f4),
      ),
      drawer: const Drawer(),
      backgroundColor: const Color(0xFFdbdbdb),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container for "EasyGrocery" text
          Container(
            width:
                MediaQuery.of(context).size.width, // Full width of the screen
            decoration: const BoxDecoration(
              color: Color(0xFFfbf7f4),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF313638),
                  width: 1.0,
                ),
              ),
            ),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 0,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space between text and icon
              children: [
                Text(
                  'EasyGrocery',
                  style: GoogleFonts.dmSerifText(
                    color: const Color(0xFF313638),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SmartCalendarPage(addedItems: _addedItems),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Add a Divider or custom decorated container
          Container(
            width: double.infinity, // Full width of the screen
            height: .5, // Height of the decoration
            color: const Color(0xFF93827f), // Customize the color
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget text input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _budgetController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Budget',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFFEFEFEF),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(
                                () {}); // Update the UI when the budget changes
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Display remaining budget
                  Text(
                    'Remaining Budget: Peso ${remainingBudget.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: remainingBudget < 0 ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (remainingBudget < 0)
                    const Text(
                      'You have exceeded your budget!',
                      style: TextStyle(color: Colors.red),
                    ),

                  const SizedBox(height: 16),

                  // Search input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterItems, // Filter items as you type
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            filled: true, // Enables the background color
                            fillColor: Color(0xFFEFEFEF),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Space between TextField and IconButton
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFEFEF), // Background color
                          shape: BoxShape.circle, // Make the container circular
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            // Logic for filtering categories
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Expanded list of items
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _filteredItems.isEmpty &&
                                  _searchController.text.isNotEmpty
                              ? const Center(child: Text('No items found'))
                              : ListView(
                                  children: [
                                    ..._filteredItems.map((item) {
                                      return ListTile(
                                        title: Text(item.name),
                                        subtitle: Text(
                                          '${item.category} - Peso ${item.price.toStringAsFixed(2)}',
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => _showQuantityDialog(
                                              item), // Show dialog on button press
                                        ),
                                      );
                                    }),
                                    ..._addedItems.map((cartItem) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(
                                              0xFFEFEFEF), // Set your desired background color here
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(cartItem.item.name),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.remove),
                                                    onPressed: () =>
                                                        _decreaseQuantity(
                                                            cartItem),
                                                  ),
                                                  Text('${cartItem.quantity}'),
                                                  IconButton(
                                                    icon: const Icon(Icons.add),
                                                    onPressed: () =>
                                                        _increaseQuantity(
                                                            cartItem),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            'Total: Peso ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Total and checkout button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: Peso ${_totalAmount.toStringAsFixed(2)}'),
                      ElevatedButton(
                        onPressed: () {
                          // Checkout button logic here
                        },
                        child: const Text('Check Out'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
