import 'package:flutter/material.dart';
import 'categories.dart'; // Import the file with the grocery items and quantityItem class
import 'searchItem.dart';
import 'checkout.dart';
import 'smart_calendar.dart';
import 'package:flutter/services.dart';
import 'format _number.dart';
import 'carts_screen.dart';
import 'cart_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _GroceryHomePageState createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<HomePage> {
  final TextEditingController _budgetController = TextEditingController();
  double _totalAmount = 0.0;
  List<quantityItem> _addedItems =
      []; // List to hold added items and their quantities

  String? _selectedStore;
  List<String> _storeList = [
    'Store A',
    'Store B',
    'Store C',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStore = null; // Set a default store if available
  }

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

  void _showRelevantItems(quantityItem selectedItem) {
    String selectedCategory = selectedItem.item.category;
    String selectedItemName = selectedItem.item.name.toLowerCase();

    // Filter items based on the selected item's category and exclude the selected item
    List<GroceryItem> relevantItems = groceryItems.where((item) {
      return item.category.toLowerCase() == selectedCategory.toLowerCase() &&
          item.name.toLowerCase() != selectedItemName;
    }).toList();

    // Sort items by name relevance and then by price
    relevantItems.sort((a, b) {
      int relevanceA =
          _calculateNameRelevance(a.name.toLowerCase(), selectedItemName);
      int relevanceB =
          _calculateNameRelevance(b.name.toLowerCase(), selectedItemName);

      if (relevanceA != relevanceB) {
        return relevanceA.compareTo(relevanceB);
      }
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
                    'Relevant Items for ${selectedItem.item.name}',
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
                          onTap: () {
                            setState(() {
                              // Replace the current item in the list
                              selectedItem.item = item;
                              // Update the added items to reflect the change and recalculate the total
                              _updateAddedItems(_addedItems);
                            });
                            Navigator.of(context).pop(); // Close the dialog
                          },
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
    if (itemName == selectedItemName) {
      return 0; // Exact match
    }

    if (itemName.contains(selectedItemName)) {
      return 1; // Partial match
    }

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
        0,
        (sum, item) => sum + item.item.price * item.quantity,
      );
    });
  }

  List<Cart> _carts = [];

// Show cart selection dialog
  void _showCartSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select a Cart'),
              content: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...cartProvider.carts
                          .map((cart) => ListTile(
                                title: Text(cart.name),
                                onTap: () {
                                  Navigator.pop(
                                      context); // Close the dialog first
                                  _addItemToCart(context,
                                      cart); // Add selected items to the cart
                                  _showSuccessNotification(
                                      context); // Notify that items were saved
                                },
                              ))
                          .toList(),
                      ElevatedButton(
                        onPressed: () {
                          // Add a new cart
                          cartProvider
                              .addCart('Cart ${cartProvider.carts.length + 1}');
                          setState(
                              () {}); // This will force the dialog to rebuild
                        },
                        child: Text('Add New Cart'),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

// Function to show alert when no items are added
  void _showNoItemsAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Items to Save'),
          content: Text('Please add items to the cart before saving.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

// Function to show notification when items are saved
  void _showSuccessNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Added'),
          content: Text('Items have been successfully saved to the cart.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the success notification dialog
              },
            ),
          ],
        );
      },
    );
  }

// Modified Function to add selected items to the cart
  void _addItemToCart(BuildContext context, Cart cart) {
    // Assuming _addedItems holds the items you want to add to the cart
    for (var item in _addedItems) {
      // Ensure _addedItems is accessible here
      Provider.of<CartProvider>(context, listen: false)
          .addItemToCart(cart.name, item);
    }
  }

// Add this method to add items to a selected cart
  void _addItemToCartSingle(Cart cart, quantityItem selectedItem) {
    setState(() {
      // Add a single selected item to the cart
      cart.items.add(selectedItem);
    });
  }

// Method to add a new cart
  void _addNewCart() {
    setState(() {
      int newCartNumber = _carts.length + 1;
      _carts.add(Cart(name: 'Cart $newCartNumber', items: []));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Parse the budget from the text field
    String budgetText = _budgetController.text.replaceAll(',', '');
    double budget = double.tryParse(budgetText) ?? 0.0;
    double remainingBudget = budget - _totalAmount;

    // Calculate remaining budget
    return Scaffold(
      backgroundColor: Color(0xFFEEECE6),
      appBar: AppBar(
        backgroundColor: Color(0xFFEEECE6),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              color: Color(0xFFBD4254),
              iconSize: 36.0,
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
        elevation: 0,
        toolbarHeight: 50,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Carts'),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartsScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
                title: Text('About'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                }),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF313638),
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 0,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Easy Grocery',
                        style: TextStyle(
                          fontFamily: 'Raleway-Bold',
                          fontWeight: FontWeight.w400,
                          fontSize: 40,
                          color: Colors.black,
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
                  SizedBox(height: 25), // Space between the title and TextField

                  // Row containing TextField and DropdownButton
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFFA79B95), // Border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 5.0,
                                top: 15.0, // Adjust this value as needed
                                child: Text(
                                  'Budget:',
                                  style: const TextStyle(
                                    color: Color(0xFFA0616A), // Text color
                                    fontSize: 14.0,
                                    fontFamily: 'Poppins-Regular',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: _budgetController,
                                style: const TextStyle(
                                  color: Color(0xFFA0616A), // Text color
                                  fontSize: 16.0,
                                  fontFamily: 'Poppins-Regular',
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                    left:
                                        57.0, // Adjust this value to align with "Budget: "
                                    top: 10.0,
                                    bottom: 10.0,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: ImageIcon(
                                      AssetImage(
                                          'assets/images/enter_icon.png'),
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        FocusScope.of(context).unfocus();
                                      });
                                    },
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only numeric input
                                  ThousandsSeparatorInputFormatter(), // Add thousands separators
                                  LengthLimitingTextInputFormatter(
                                      6), // Limit to 10 characters
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 180, // Fixed width or adjust as needed
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xFFA79B95), // Border color
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(
                              'Select Store',
                              style: TextStyle(
                                color: Color(0xFFA0616A), // Hint text color
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            value: _selectedStore,
                            items: [
                              DropdownMenuItem<String>(
                                value: null, // No value initially selected
                                child: Text(
                                  'Select Store',
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade600, // Hint text color
                                    fontWeight:
                                        FontWeight.w400, // Lighter font weight
                                  ),
                                ),
                              ),
                              ..._storeList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color:
                                          Color(0xFFBD4254), // Item text color
                                      fontWeight:
                                          FontWeight.w500, // Font weight
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStore = newValue;
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFFBD4254), // Icon color
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining Budget: ₱${currencyFormat.format(remainingBudget)}',
                            style: TextStyle(
                              fontFamily: 'Poppins-Regular',
                              color: remainingBudget < 0
                                  ? Colors.red
                                  : Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // "Add Item" button without box border
                          TextButton(
                            onPressed: () {
                              // Navigate to the item selection page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Searchitem(
                                    addedItems: _addedItems,
                                    onItemsAdded:
                                        _updateAddedItems, // Update added items
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Add Item',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBD4254),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (remainingBudget < 0)
                        Text(
                          'You have exceeded your budget!',
                          style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Poppins-Regular',
                              fontWeight: FontWeight.w400),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ..._addedItems.map((quantityItem) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0), // Space between items
                    padding:
                        const EdgeInsets.all(8.0), // Padding inside the border
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.grey,
                          width: 2.0), // Border width for the item container
                      borderRadius: BorderRadius.circular(
                          8.0), // Optional: Rounded corners
                    ),
                    child: ListTile(
                      onTap: () => _showRelevantItems(
                          quantityItem), // Show relevant items when tapped
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            quantityItem.item.name,
                            style: TextStyle(
                              fontFamily:
                                  'Poppins', // Replace with your custom font family
                              fontSize: 18, // Adjust the font size as needed
                              fontWeight: FontWeight
                                  .w600, // Adjust the font weight as needed
                              color: Colors
                                  .black, // Adjust the text color as needed
                            ),
                          ),
                          // Box border and background color for quantity controls
                          Container(
                            decoration: BoxDecoration(
                              color: Color(
                                  0xFFB9ACA6), // Set the background color here
                              border: Border.all(
                                  color: Colors.grey,
                                  width:
                                      1.0), // Single border around the quantity controls
                              borderRadius: BorderRadius.circular(
                                  5.0), // Rounded corners for the border
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () =>
                                      _decreaseQuantity(quantityItem),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          8.0), // Padding inside the quantity text container
                                  child: Text(
                                    '${quantityItem.quantity}',
                                    style: TextStyle(
                                      fontFamily:
                                          'Poppins', // Replace with your custom font family
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          18, // Adjust the font size as needed
                                      color: Colors
                                          .black, // Adjust the text color as needed
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () =>
                                      _increaseQuantity(quantityItem),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Total: ₱${(quantityItem.item.price * quantityItem.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily:
                              'Poppins-Regular', // Replace with your custom font family
                          fontWeight: FontWeight.w400,
                          fontSize: 16, // Adjust the font size as needed
                          color: Colors.grey, // Adjust the text color as needed
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          SizedBox(height: 16), // Space before the checkout row

          // Checkout Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 2.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Total: ₱${currencyFormat.format(_totalAmount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Combined Cart and Checkout Buttons
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFBD4254),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Add to Cart Button (updated logic to show cart window)
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart,
                            color: Colors.white), // Updated icon
                        onPressed: () {
                          // Show the modal bottom sheet with cart options
                          _showCartSelection(context);
                        },
                      ),
                      // Divider between Cart and Checkout buttons (optional)
                      Container(
                        height: 48, // Adjust as needed
                        width: 1, // Thin line as a divider
                        color: Colors.white, // Same color as text
                      ),
                      // Check Out Button
                      TextButton(
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
                        child: Text(
                          'Check Out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            fontSize: 20, // Increased font size
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size(120, 48), // Increased button size
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
