import 'package:flutter/material.dart';
import 'package:EasyGrocery/provider/categories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import the dart:convert library for JSON handling

class Searchitem extends StatefulWidget {
  final List<quantityItem> addedItems;
  final Function(List<quantityItem>) onItemsAdded;

  Searchitem({required this.addedItems, required this.onItemsAdded});

  @override
  _SearchitemState createState() => _SearchitemState();
}

class _SearchitemState extends State<Searchitem> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedCategories = [];
  List<GroceryItem> _filteredItems = groceryItems;
  Map<String, int> orderCountMap = {};

  @override
  void initState() {
    super.initState();
    _loadOrderCounts(); // Load order counts on startup
  }

  Future<void> _loadOrderCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? orderCountMapString = prefs.getString('orderCountMap');
    if (orderCountMapString != null) {
      setState(() {
        orderCountMap = Map<String, int>.from(
          jsonDecode(orderCountMapString)
              .map((key, value) => MapEntry(key, value as int)),
        );
      });
    }
  }

  Future<void> _saveOrderCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderCountMapString =
        jsonEncode(orderCountMap); // Convert map to JSON string
    await prefs.setString(
        'orderCountMap', orderCountMapString); // Save JSON string
  }

  void _addItemToCart(quantityItem item) {
    // Update order count
    if (orderCountMap.containsKey(item.item.name)) {
      orderCountMap[item.item.name] =
          orderCountMap[item.item.name]! + item.quantity;
    } else {
      orderCountMap[item.item.name] = item.quantity;
    }

    _saveOrderCounts(); // Save the updated order counts

    // Existing logic to add item to the cart
    int quantity = item.quantity; // Get the updated quantity
    if (quantity > 0) {
      setState(() {
        int existingIndex = widget.addedItems
            .indexWhere((quantityItem) => quantityItem.item == item.item);
        if (existingIndex != -1) {
          widget.addedItems[existingIndex].quantity += quantity;
        } else {
          widget.addedItems.add(
              quantityItem(item: item.item, quantity: quantity, uniqueIds: []));
        }
      });
      widget.onItemsAdded(widget.addedItems);
    }
  }

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

  List<String> categories = ["Meat", "Dairy", "Bakery", "Fruits"];

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                width: 310.0, // Set your desired width here
                height: 450.0, // Set your desired height here
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upper edge color container (completely fills the upper edge)
                    Container(
                      height: 65.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFD7CCC8), // Upper edge color
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.0), // Top rounded corners
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Select Categories',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      color: Color(
                          0xFFEEECE6), // Background color of the main content
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: categories.map((category) {
                            return CheckboxListTile(
                              title: Text(
                                category,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                              activeColor: Color(
                                  0xFFBD4254), // Checkbox active color (inside color)
                              checkColor: Colors.white, // Checkmark color
                              side: BorderSide(
                                color: Color(
                                    0xFFBD4254), // Outline border color of the checkbox
                                width: 2.0, // Border width
                              ),
                              value: _selectedCategories.contains(category),
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    _selectedCategories.add(category);
                                  } else {
                                    _selectedCategories.remove(category);
                                  }
                                  _filterItems(_searchController.text);
                                });
                              },
                            );
                          }).toList()
                            ..add(
                              CheckboxListTile(
                                title: Text('All',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600)),
                                activeColor: Color(
                                    0xFFBD4254), // Checkbox active color (inside color)
                                checkColor: Colors.white, // Checkmark color
                                side: BorderSide(
                                  color: Color(
                                      0xFFBD4254), // Outline border color of the checkbox
                                  width: 2.0, // Border width
                                ),
                                value: _selectedCategories.isEmpty,
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      _selectedCategories
                                          .clear(); // Clear all selections
                                    }
                                    _filterItems(_searchController.text);
                                  });
                                },
                              ),
                            ),
                        ),
                      ),
                    ),
                    // Lower edge color container (completely fills the lower edge)
                    Container(
                      height: 72.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFD7CCC8), // Lower edge color
                        borderRadius: BorderRadius.vertical(
                          bottom:
                              Radius.circular(12.0), // Bottom rounded corners
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(
                                  0xFFBD4254), // Text color for "Done" button
                              fontWeight: FontWeight.bold,
                            ),
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
      },
    );
  }

  void _showQuantityDialog(quantityItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFDBD5CB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${item.item.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFEEECE6),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12.0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        // Outer container for white background
                        Container(
                          width:
                              300.0, // Set the desired width of the outer container
                          height: 60.0,
                          padding: EdgeInsets.all(
                              3.0), // Padding around the quantity adjuster
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // White background for the container
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            // Center the inner container within the outer container
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Color(
                                    0xFFD0C4C0), // Inner container background color
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setDialogState(() {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                        }
                                      });
                                    },
                                    color: Colors.black,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setDialogState(() {
                                        item.quantity++;
                                      });
                                    },
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                backgroundColor: Color(0xFFBD4254),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                backgroundColor: Color(0xFF00B383),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                int quantity = item.quantity;
                                if (quantity > 0) {
                                  setState(() {
                                    int existingIndex = widget.addedItems
                                        .indexWhere((quantityItem) =>
                                            quantityItem.item == item.item);
                                    if (existingIndex != -1) {
                                      widget.addedItems[existingIndex]
                                          .quantity += quantity;
                                    } else {
                                      widget.addedItems.add(
                                        quantityItem(
                                            item: item.item,
                                            quantity: quantity,
                                            uniqueIds: []),
                                      );
                                    }
                                  });

                                  widget.onItemsAdded(widget.addedItems);

                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${item.item.name} added to your order!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Add to cart',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<quantityItem> wrappedItems = _filteredItems
        .map((item) => quantityItem(item: item, quantity: 1, uniqueIds: []))
        .toList();

    // Filter items that have been ordered more than once (e.g., to show in "Your Favorite Ordered")
    List<quantityItem> favoriteItems = wrappedItems
        .where((item) =>
            orderCountMap[item.item.name] != null &&
            orderCountMap[item.item.name]! > 1)
        .toList();

    wrappedItems.sort((a, b) => (orderCountMap[b.item.name] ?? 0)
        .compareTo(orderCountMap[a.item.name] ?? 0));

    List<quantityItem> meatItems =
        wrappedItems.where((item) => item.item.category == "Meat").toList();
    List<quantityItem> dairyItems =
        wrappedItems.where((item) => item.item.category == "Dairy").toList();
    List<quantityItem> bakeryItems =
        wrappedItems.where((item) => item.item.category == "Bakery").toList();
    List<quantityItem> fruitsItems =
        wrappedItems.where((item) => item.item.category == "Fruits").toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDBD5CB),
        title: Text(
          'Select Items',
          style: TextStyle(
              fontFamily: 'Raleway-Bold', fontWeight: FontWeight.w400),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showCategoryFilterDialog,
            color: Color(0xFFBD4254),
          ),
        ],
      ),
      backgroundColor: Color(0xFFEEECE6),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Replace the old TextField with the new CustomSearchBar widget
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        4.0), // Reduced padding to align button correctly
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13.0), // Rounded corners
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterItems,
                        decoration: InputDecoration(
                          border: InputBorder.none, // Remove border
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          prefixIcon: Icon(Icons.search,
                              color: Color(
                                  0xFFBD4254)), // Search icon inside the TextField
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      // Match the height of the Container for the button
                      decoration: BoxDecoration(
                        color: Color(0xFFBD4254), // Same color as button
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13.0),
                          topRight: Radius.circular(13.0),
                          bottomLeft: Radius.circular(13.0),
                          bottomRight: Radius.circular(13.0),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _filterItems(_searchController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Make the button background transparent
                          shadowColor:
                              Colors.transparent, // Remove button shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(13.0),
                              bottomRight: Radius.circular(13.0),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 12.0),
                          child: Text(
                            'Search',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 23.0,
                                fontFamily: 'Raleway-Bold',
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
              // Your Favorite Ordered Header (Only show if there are favorite items)
              if (favoriteItems.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 70.0,
                          width: 378.0, // Set your desired width here
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0), // Spacing around the box
                          padding:
                              EdgeInsets.all(15.0), // Inner padding of the box
                          decoration: BoxDecoration(
                            color: Color(0xFF35E0A0),
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded corners
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            'Best Buy',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 28,
                              fontFamily: 'Raleway-Bold',
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: favoriteItems.length,
                      itemBuilder: (context, index) {
                        final wrappedItem = favoriteItems[index];
                        return Container(
                          height:
                              80.0, // Set the height of the container box manually
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0), // Spacing between items
                          padding:
                              EdgeInsets.all(5.0), // Inner padding of the box
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black, // Outline border color
                              width: 2.0, // Border width
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    8.0), // Adjust padding inside ListTile
                            title: Text(
                              wrappedItem.item.name,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ), // Font size for the title text
                            ),
                            subtitle: Text(
                              'Total: ₱${wrappedItem.item.price.toStringAsFixed(2)}',
                            ),
                            trailing: GestureDetector(
                              onTap: () => _showQuantityDialog(
                                  wrappedItem), // Handle the button tap
                              child: Container(
                                width:
                                    35.0, // Set the width of the square button
                                height:
                                    35.0, // Set the height of the square button
                                decoration: BoxDecoration(
                                  color: Colors
                                      .transparent, // Transparent background
                                  border: Border.all(
                                    color: Color(
                                        0xFFBD4254), // Outline border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    13.0,
                                  ), // Rounded corners (optional, can set to 0 for sharp corners)
                                ),
                                child: Align(
                                  alignment:
                                      Alignment.center, // Align the '+' symbol
                                  child: Text(
                                    '+', // Plus symbol in the middle
                                    style: TextStyle(
                                      color: Color(
                                          0xFFBD4254), // Color of the plus symbol
                                      fontSize: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

              // Display category headers and items
              _buildCategoryHeader('Meat', meatItems),
              _buildCategoryHeader('Dairy', dairyItems),
              _buildCategoryHeader('Bakery', bakeryItems),
              _buildCategoryHeader('Fruits', fruitsItems),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String category, List<quantityItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 70.0,
                width: 378.0, // Set your desired width here
                margin: EdgeInsets.symmetric(
                    vertical: 8.0), // Spacing around the box
                padding: EdgeInsets.all(15.0), // Inner padding of the box
                decoration: BoxDecoration(
                    color: Color(0xFFFFF1E6),
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    border: Border.all(color: Colors.black)),
                child: Text(
                  category,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 28,
                      fontFamily: 'Raleway-Bold'),
                ),
              ),
            ],
          ),
        ...items.map((wrappedItem) {
          return Container(
            height: 80.0, // Set the height of the container box manually
            margin:
                EdgeInsets.symmetric(vertical: 4.0), // Spacing between items
            padding: EdgeInsets.all(5.0), // Inner padding of the box
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black, // Outline border color
                width: 2.0, // Border width
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.0), // Adjust padding inside ListTile
              title: Text(
                wrappedItem.item.name,
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins'), // Font size for the title text
              ),
              subtitle: Text(
                'Total: ₱${wrappedItem.item.price.toStringAsFixed(2)}',
              ),
              trailing: GestureDetector(
                onTap: () =>
                    _showQuantityDialog(wrappedItem), // Handle the button tap
                child: Container(
                  width: 35.0, // Set the width of the square button
                  height: 35.0, // Set the height of the square button
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Transparent background
                    border: Border.all(
                      color: Color(0xFFBD4254), // Outline border color
                      width: 2.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(
                        13.0), // Rounded corners (optional, can set to 0 for sharp corners)
                  ),
                  child: Align(
                    alignment: Alignment
                        .center, // Adjust alignment as needed (center by default)
                    child: Text(
                      '+', // Plus symbol in the middle
                      style: TextStyle(
                        color: Color(0xFFBD4254), // Color of the plus symbol
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
