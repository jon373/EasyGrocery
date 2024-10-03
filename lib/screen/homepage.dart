import 'package:flutter/material.dart';
import 'package:EasyGrocery/provider/categories.dart';
import 'searchItem.dart';
import 'checkout_direct.dart';
import 'smart_calendar.dart';
import 'package:flutter/services.dart';
import 'package:EasyGrocery/provider/format _number.dart';
import 'carts_display.dart';
import 'package:provider/provider.dart';
import 'package:EasyGrocery/provider/cart_provider.dart';
import 'package:EasyGrocery/provider/recommend.dart';
import 'dart:math'; // Import the dart:math

class HomePage extends StatefulWidget {
  @override
  _GroceryHomePageState createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<HomePage> {
  final TextEditingController _budgetController = TextEditingController();

  double _totalAmount = 0.0;
  double remainingBudget = 0.0; // Remaining budget variable
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
    remainingBudget = 0.0; // Initialize remaining budget
  }

  void _increaseQuantity(quantityItem quantityItem) {
    setState(() {
      quantityItem.quantity++;
      _totalAmount += quantityItem.item.price; // Update total amount
      _updateRemainingBudget(); // Update the remaining budget
    });
  }

  void _decreaseQuantity(quantityItem quantityItem) {
    if (quantityItem.quantity > 1) {
      setState(() {
        quantityItem.quantity--;
        _totalAmount -= quantityItem.item.price; // Update total amount
        _updateRemainingBudget(); // Update the remaining budget
      });
    } else {
      // Show confirmation dialog to remove the item
      _showRemoveConfirmationDialog(quantityItem);
    }
  }

// Function to remove item with swipe-to-delete functionality
  void _removeItemWithUndo(quantityItem item, int index) {
    setState(() {
      _totalAmount -= item.item.price * item.quantity; // Update total amount
      _addedItems.removeAt(index); // Remove the item from the cart
      _updateRemainingBudget(); // Update the remaining budget
    });

    // Show a SnackBar with an Undo button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.item.name} removed from the cart.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Restore the removed item when undo is pressed
            setState(() {
              _addedItems.insert(index, item);
              _totalAmount +=
                  item.item.price * item.quantity; // Restore total amount
              _updateRemainingBudget(); // Update the remaining budget
            });
          },
        ),
        duration: Duration(seconds: 3), // Show the SnackBar for 3 seconds
      ),
    );
  }

// Update remaining budget based on the total amount and budget
  void _updateRemainingBudget() {
    String budgetText = _budgetController.text.replaceAll(',', '');
    double budget = double.tryParse(budgetText) ?? 0.0;
    remainingBudget = budget - _totalAmount;
  }

// Show confirmation dialog before removing an item completely
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
                  _updateRemainingBudget(); // Update remaining budget
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

  void _showCategorySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // List of meal types (Breakfast, Lunch, Dinner) as options
              ListTile(
                title: Text('Breakfast'),
                onTap: () {
                  Navigator.pop(context);
                  _showRecommendedItems('Breakfast');
                },
              ),
              ListTile(
                title: Text('Lunch'),
                onTap: () {
                  Navigator.pop(context);
                  _showRecommendedItems('Lunch');
                },
              ),
              ListTile(
                title: Text('Dinner'),
                onTap: () {
                  Navigator.pop(context);
                  _showRecommendedItems('Dinner');
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Modify the _showRecommendedItems function
  void _showRecommendedItems(String mealType) {
    double budget =
        double.tryParse(_budgetController.text.replaceAll(',', '')) ?? 0.0;
    List<GroceryItem> initialRecommendedItems = [];

    // Filter the grocery items based on the selected mealType
    for (GroceryItem item in groceryItems) {
      if (item.mealType.contains(mealType)) {
        initialRecommendedItems.add(item);
      }
    }

    initialRecommendedItems.sort((a, b) => a.price.compareTo(b.price));
    List<quantityItem> finalRecommendedItems = [];
    double totalCost = 0.0;
    Random random = Random();

    while (totalCost < budget && initialRecommendedItems.isNotEmpty) {
      GroceryItem randomItem = initialRecommendedItems[
          random.nextInt(initialRecommendedItems.length)];
      double newTotalCost = totalCost + randomItem.price;

      if (newTotalCost <= budget) {
        // Use a placeholder item to avoid null issues
        quantityItem placeholder = quantityItem(item: randomItem, quantity: 0);

        // Find if the item already exists in the list
        quantityItem existingItem = finalRecommendedItems.firstWhere(
          (qItem) => qItem.item.name == randomItem.name,
          orElse: () => placeholder,
        );

        if (existingItem.quantity > 0) {
          // If the item already exists, increase its quantity
          existingItem.quantity++;
        } else {
          // If the item does not exist, add it with quantity 1
          finalRecommendedItems
              .add(quantityItem(item: randomItem, quantity: 1));
        }

        totalCost = newTotalCost;
      } else {
        break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendedItemsScreen(
          mealType: mealType,
          budget: budget,
          recommendedItems: finalRecommendedItems,
          onAddToHomeScreen: _addRecommendedItems,
        ),
      ),
    );
  }

// Modify the _addRecommendedItems function similarly
  void _addRecommendedItems(List<quantityItem> recommendedItems) {
    setState(() {
      for (var recommendedItem in recommendedItems) {
        // Use a placeholder to avoid null issues
        quantityItem placeholder =
            quantityItem(item: recommendedItem.item, quantity: 0);

        // Find if the item already exists in the _addedItems list
        quantityItem existingItem = _addedItems.firstWhere(
          (item) => item.item.name == recommendedItem.item.name,
          orElse: () => placeholder,
        );

        if (existingItem.quantity > 0) {
          // If the item already exists, increase its quantity
          existingItem.quantity += recommendedItem.quantity;
        } else {
          // If the item does not exist, add it to the list
          _addedItems.add(recommendedItem);
        }

        // Update the total amount
        _totalAmount += recommendedItem.item.price * recommendedItem.quantity;
      }

      // Recalculate the remaining budget
      String budgetText = _budgetController.text.replaceAll(',', '');
      double budget = double.tryParse(budgetText) ?? 0.0;
      remainingBudget = budget - _totalAmount;
    });
  }

  List<Cart> _carts = [];

// Show cart selection dialog
  void _showCartSelection(BuildContext context) {
    // Create a ScrollController to control the ListView
    ScrollController _scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select a Cart'),
              content: Container(
                width: double.maxFinite, // Set width to fit the screen width
                height: 300.0, // Set a fixed height for the dialog content
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Make the list of carts scrollable
                        Expanded(
                          child: ListView.builder(
                            controller:
                                _scrollController, // Attach the scroll controller
                            shrinkWrap: true,
                            itemCount: cartProvider.carts.length,
                            itemBuilder: (context, index) {
                              var cart = cartProvider.carts[index];
                              return ListTile(
                                title: Text(cart.name),
                                onTap: () {
                                  Navigator.pop(
                                      context); // Close the dialog first
                                  _addItemToCart(context,
                                      cart); // Add selected items to the cart
                                  _showSuccessNotification(
                                      context); // Notify that items were saved
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                            height:
                                16), // Add spacing between the list and button

                        // Add New Cart button with limitation check
                        ElevatedButton(
                          onPressed: cartProvider.carts.length < 10
                              ? () {
                                  // Add a new cart only if there are less than 10 carts
                                  cartProvider.addCart(
                                      'Cart ${cartProvider.carts.length + 1}');

                                  // Use setState to trigger a UI rebuild
                                  setState(() {});

                                  // Scroll to the bottom of the ListView after adding a new cart
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    if (_scrollController.hasClients) {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position.maxScrollExtent,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  });
                                }
                              : null, // Disable the button when 10 carts are reached
                          child: Text(
                            'Add New Cart',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cartProvider.carts.length < 10
                                ? Color(
                                    0xFFBD4254) // Original color when active
                                : Colors.grey, // Turn grey when disabled
                            textStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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

  void _addItemToCart(BuildContext context, Cart cart) {
    for (var item in _addedItems) {
      Provider.of<CartProvider>(context, listen: false)
          .addItemToCart(cart.name, item);
    }
    _clearAddedItems(); // Clear items after they are added to the cart
    _resetBudgetAndItems(); // Reset budget and other related state
  }

  void _clearAddedItems() {
    setState(() {
      _addedItems.clear(); // This clears the list of added items
    });
  }

  void _resetBudgetAndItems() {
    setState(() {
      _budgetController.clear(); // This clears the input field for the budget.
      _addedItems
          .clear(); // This clears all added items, assuming _addedItems is a list of items added to a cart.
      // Assuming you have a variable _totalAmount that tracks the total amount spent or allocated.
      _totalAmount =
          0; // Reset the total amount to reflect that items are cleared.

      // Directly recalculate the remaining budget
      // Here, since the budget is cleared, the remaining budget should also reset to reflect no budget entry.
      double budget =
          double.tryParse(_budgetController.text.replaceAll(',', '')) ?? 0.0;

      // ignore: unused_local_variable
      double remainingBudget = budget -
          _totalAmount; // Also 0 since both budget and total amount are reset.
    });
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
      _carts.add(Cart(name: 'Cart $newCartNumber', items: [], id: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    String budgetText = _budgetController.text.replaceAll(',', '');
    double budget = double.tryParse(budgetText) ?? 0.0;

    double remainingBudget = budget - _totalAmount;
    double getRemainingBudget() {
      double budget =
          double.tryParse(_budgetController.text.replaceAll(',', '')) ?? 0.0;

      return budget - _totalAmount;
    }

    bool isBudgetEntered =
        (budget > 0); // Check if the budget is greater than 0

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
                                    left: 57.0, // Align with "Budget: "
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
                                        // Focus and update state
                                        FocusScope.of(context).unfocus();
                                      });
                                      // Show category selection window when budget is entered
                                      if (isBudgetEntered) {
                                        _showCategorySelectionDialog(context);
                                      }
                                    },
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(
                                      () {}); // Rebuild the widget when budget changes
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only numeric input
                                  ThousandsSeparatorInputFormatter(), // Add thousands separators
                                  LengthLimitingTextInputFormatter(
                                      6), // Limit to 6 characters
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
                      // Display the Remaining Budget text and update only when a valid budget is entered
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining Budget: \₱${isBudgetEntered ? currencyFormat.format(remainingBudget) : '0.00'}',
                            style: TextStyle(
                              fontFamily: 'Poppins-Regular',
                              // If budget is not entered, keep the text color black. Otherwise, change color based on remaining budget
                              color: !isBudgetEntered
                                  ? Colors.black
                                  : (remainingBudget < 0
                                      ? Colors.red
                                      : Colors.black),
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
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _addedItems.length,
              itemBuilder: (context, index) {
                final quantityItem item = _addedItems[index];

                return Dismissible(
                  key: Key(item.item.name), // Unique key for each item
                  direction: DismissDirection.endToStart, // Swipe right-to-left
                  background: Container(
                    color: Colors.red, // Background color for the delete action
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight, // Align to the right side
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.delete, // Trash icon
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    // Remove the item and show the undo SnackBar
                    _removeItemWithUndo(item, index);
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      onTap: () => _showRelevantItems(item),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.item.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFB9ACA6),
                              border:
                                  Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => _decreaseQuantity(item),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => _increaseQuantity(item),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Total: ₱${(item.item.price * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Poppins-Regular',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
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
                    color: _addedItems.isNotEmpty
                        ? Color(0xFFBD4254) // Original color when items exist
                        : Colors.grey, // Darkened grey when no items
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Add to Cart Button
                      IconButton(
                        icon:
                            Icon(Icons.add_shopping_cart, color: Colors.white),
                        onPressed: _addedItems.isNotEmpty
                            ? () {
                                // Show the modal bottom sheet with cart options
                                _showCartSelection(context);
                              }
                            : null, // Disable button if no items to add
                      ),
                      // Divider between Cart and Checkout buttons (optional)
                      Container(
                        height: 48, // Adjust as needed
                        width: 1, // Thin line as a divider
                        color: Colors.white, // Same color as text
                      ),
                      // Check Out Button
                      TextButton(
                        onPressed: _addedItems.isNotEmpty
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutPage(
                                      addedItems: _addedItems,
                                      totalAmount: _totalAmount,
                                      onAddressSelected:
                                          (String selectedAddress) {
                                        // Handle address selection here
                                        print(
                                            'Selected address: $selectedAddress');
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
                              }
                            : null, // Disable button if no items to checkout
                        child: Text(
                          'Check Out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            fontSize: 20, // Keep font size same
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: _addedItems.isNotEmpty
                              ? Color(
                                  0xFFBD4254) // Original color when items exist
                              : Colors.grey, // Grey when no items to checkout
                          minimumSize: Size(120, 48), // Same button size
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius
                                .zero, // Keep button shape consistent
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
