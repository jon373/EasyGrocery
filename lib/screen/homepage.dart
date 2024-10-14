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
import 'dart:math';
import 'package:EasyGrocery/provider/unique_id_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  final List<String> _storeList = [
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
        duration: const Duration(seconds: 3), // Show the SnackBar for 3 seconds
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
          title: const Text('Remove Item'),
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
            width: 350,
            height: 450,
            decoration: BoxDecoration(
              color: Color(0xFFEEECE6), // Background color of the dialog
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the start (left)
              children: [
                Container(
                  height:
                      55, // Adjust this value to control the title bar height
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color:
                        Color(0xFFDBD5CB), // Background color for the title bar
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.0), // Rounded top corners
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft, // Align title to the left
                    child: Text(
                      'Related Items',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20, // Font size for the title text
                        color: Colors
                            .black, // Change text color to white for contrast
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView(
                      children: relevantItems.map((item) {
                        return Card(
                          // Each item in a card for better separation
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          color: Color(0xFFFFFFFF),
                          child: ListTile(
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600, // Bold item names
                              ),
                            ),
                            subtitle: Text(
                              '${item.category} - P${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedItem.item = item;
                                _updateAddedItems(_addedItems);
                              });
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  // Center the button
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      backgroundColor:
                          Color(0xFFEEECE6), // Button background color
                      foregroundColor:
                          Colors.black, // Text color for the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded button
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
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
          title: const Text('Select category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // List of meal types (Breakfast, Lunch, Dinner) as options
              ListTile(
                title: const Text('Breakfast'),
                onTap: () {
                  Navigator.pop(context);
                  _showRecommendedItems('Breakfast');
                },
              ),
              ListTile(
                title: const Text('Lunch'),
                onTap: () {
                  Navigator.pop(context);
                  _showRecommendedItems('Lunch');
                },
              ),
              ListTile(
                title: const Text('Dinner'),
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
        // Use the new method to fetch unique IDs for this item and its quantity
        List<String> uniqueIds =
            UniqueIdManager.getUniqueIdsForItem(randomItem.name, 1);
        if (uniqueIds.length < 1) {
          UniqueIdManager.generateUniqueIds(
              randomItem.name, 1); // Generate one unique ID
          uniqueIds = UniqueIdManager.getUniqueIdsForItem(randomItem.name, 1);
        }

        // Create a placeholder item with the unique IDs
        quantityItem placeholder =
            quantityItem(item: randomItem, quantity: 0, uniqueIds: []);

        // Find if the item already exists in the list
        quantityItem existingItem = finalRecommendedItems.firstWhere(
          (qItem) => qItem.item.name == randomItem.name,
          orElse: () => placeholder,
        );

        if (existingItem.quantity > 0) {
          // If the item already exists, increase its quantity and add a unique ID
          existingItem.quantity++;
          existingItem.uniqueIds
              .addAll(uniqueIds); // Add the unique IDs for this item
        } else {
          // If the item does not exist, add it with quantity 1 and unique IDs
          finalRecommendedItems.add(quantityItem(
            item: randomItem,
            quantity: 1,
            uniqueIds: uniqueIds,
          ));
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
        // Use the new method to fetch unique IDs for the item based on its quantity
        List<String> uniqueIds = UniqueIdManager.getUniqueIdsForItem(
            recommendedItem.item.name, recommendedItem.quantity);

        if (uniqueIds.length < recommendedItem.quantity) {
          UniqueIdManager.generateUniqueIds(recommendedItem.item.name,
              recommendedItem.quantity - uniqueIds.length);
          uniqueIds = UniqueIdManager.getUniqueIdsForItem(
              recommendedItem.item.name, recommendedItem.quantity);
        }

        // Create a placeholder with unique IDs
        quantityItem placeholder = quantityItem(
            item: recommendedItem.item, quantity: 0, uniqueIds: []);

        // Find if the item already exists in the _addedItems list
        quantityItem existingItem = _addedItems.firstWhere(
          (item) => item.item.name == recommendedItem.item.name,
          orElse: () => placeholder,
        );

        if (existingItem.quantity > 0) {
          // If the item already exists, increase its quantity and add unique IDs
          existingItem.quantity += recommendedItem.quantity;
          existingItem.uniqueIds.addAll(uniqueIds);
        } else {
          // If the item does not exist, add it to the list with unique IDs
          _addedItems.add(quantityItem(
            item: recommendedItem.item,
            quantity: recommendedItem.quantity,
            uniqueIds: uniqueIds,
          ));
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

  final List<Cart> _carts = [];

// Show cart selection dialog
  void _showCartSelection(BuildContext context) {
    // Create a ScrollController to control the ListView
    ScrollController scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select a Cart'),
              content: SizedBox(
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
                                scrollController, // Attach the scroll controller
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
                        const SizedBox(
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
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    if (scrollController.hasClients) {
                                      scrollController.animateTo(
                                        scrollController
                                            .position.maxScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cartProvider.carts.length < 10
                                ? const Color(
                                    0xFFBD4254) // Original color when active
                                : Colors.grey, // Turn grey when disabled
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ), // Disable the button when 10 carts are reached
                          child: Text(
                            'Add New Cart',
                            style: TextStyle(color: Colors.white),
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
          title: const Text('No Items to Save'),
          content: const Text('Please add items to the cart before saving.'),
          actions: [
            TextButton(
              child: const Text('OK'),
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
          title: const Text('Item Added'),
          content:
              const Text('Items have been successfully saved to the cart.'),
          actions: [
            TextButton(
              child: const Text('OK'),
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
      backgroundColor: const Color(0xFFEEECE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEECE6),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: const Color(0xFFBD4254),
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: const Text('Carts'),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartsScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
                title: const Text('About'),
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
                      const Text(
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
                  const SizedBox(
                      height: 25), // Space between the title and TextField

                  // Row containing TextField and DropdownButton
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFA79B95), // Border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Stack(
                            children: [
                              const Positioned(
                                left: 5.0,
                                top: 15.0, // Adjust this value as needed
                                child: Text(
                                  'Budget:',
                                  style: TextStyle(
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
                                    icon: const ImageIcon(
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
                      const SizedBox(width: 8),
                      Container(
                        width: 180, // Fixed width or adjust as needed
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFA79B95), // Border color
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text(
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
                                    style: const TextStyle(
                                      color:
                                          Color(0xFFBD4254), // Item text color
                                      fontWeight:
                                          FontWeight.w500, // Font weight
                                    ),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStore = newValue;
                              });
                            },
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFFBD4254), // Icon color
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 1.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the Remaining Budget text and update only when a valid budget is entered
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining Budget: ₱${isBudgetEntered ? currencyFormat.format(remainingBudget) : '0.00'}',
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
                            child: const Text(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight, // Align to the right side
                    child: const Row(
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
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    color: Color(0xFFFFFFFF),
                    child: Container(
                      padding: EdgeInsets.all(
                          16), // Add padding inside the card for larger area
                      constraints: BoxConstraints(
                        minHeight: 80, // Set a minimum height for the card
                      ),
                      child: ListTile(
                        onTap: () => _showRelevantItems(item),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.item.name, // Item name
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Align quantity controls to the right
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFB9ACA6),
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () => _decreaseQuantity(item),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '${item.quantity}', // Display quantity
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
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16), // Space before the checkout row

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
                      style: const TextStyle(
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
                        ? const Color(
                            0xFFBD4254) // Original color when items exist
                        : Colors.grey, // Darkened grey when no items
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Add to Cart Button
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            color: Colors.white),
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
                            : null,
                        style: TextButton.styleFrom(
                          backgroundColor: _addedItems.isNotEmpty
                              ? const Color(
                                  0xFFBD4254) // Original color when items exist
                              : Colors.grey, // Grey when no items to checkout
                          minimumSize: const Size(120, 48), // Same button size
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius
                                .zero, // Keep button shape consistent
                          ),
                        ), // Disable button if no items to checkout
                        child: Text(
                          'Check Out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            fontSize: 20, // Keep font size same
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
