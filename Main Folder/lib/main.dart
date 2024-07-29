import 'package:flutter/material.dart';

void main() {
  runApp(GroceryApp());
}

class GroceryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Recommendation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GroceryHomePage(),
    );
  }
}

class GroceryItem {
  final String name;
  final double price;

  GroceryItem({required this.name, required this.price});
}

class RecommendedItem {
  final GroceryItem item;
  int quantity;

  RecommendedItem({required this.item, required this.quantity});
}

class GroceryHomePage extends StatefulWidget {
  @override
  _GroceryHomePageState createState() => _GroceryHomePageState();
}

// Items that available
class _GroceryHomePageState extends State<GroceryHomePage> {
  final List<GroceryItem> _groceryItems = [
    GroceryItem(name: 'Apples', price: 50.0),
    GroceryItem(name: 'Bananas', price: 30.0),
    GroceryItem(name: 'Bread', price: 70.0),
    GroceryItem(name: 'Milk', price: 105.5),
    GroceryItem(name: 'Eggs', price: 250.5),
    GroceryItem(name: 'Chicken', price: 350.0),
    GroceryItem(name: 'Rice', price: 1500.0),
    GroceryItem(name: 'Pasta', price: 60.0),
    GroceryItem(name: 'Tomatoes', price: 50.0),
    GroceryItem(name: 'Cheese', price: 100.5),
  ];

  final TextEditingController _budgetController = TextEditingController();
  List<RecommendedItem> _recommendedItems = [];
  double _totalPrice = 0.0;

// this is the function of grocery budget
  void _recommendGroceries() {
    final double budget = double.tryParse(_budgetController.text) ?? 0.0;
    List<RecommendedItem> recommendedItems = [];
    double totalPrice = 0.0;

// Loop to add items (this is already fixed bug for freezing)
    while (totalPrice < budget) {
      bool anyItemAdded = false;

      for (GroceryItem item in _groceryItems) {
        if (totalPrice + item.price <= budget) {
          var found = false;

          for (var recommendedItem in recommendedItems) {
            if (recommendedItem.item.name == item.name) {
              recommendedItem.quantity++;
              found = true;
              break;
            }
          }
          // This to perform to add item if not on the list
          if (!found) {
            recommendedItems.add(RecommendedItem(item: item, quantity: 1));
          }
          totalPrice += item.price;
          anyItemAdded = true;
        }
      }

      // Break out of the loop if no more items can be added within the budget
      if (!anyItemAdded) break;
    }

    setState(() {
      _recommendedItems = recommendedItems;
      _totalPrice = totalPrice;
    });
  }

// This is UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery Recommendation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter your budget',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _recommendGroceries,
              child: Text('Get Recommendations'),
            ),
            SizedBox(height: 20.0),
            if (_recommendedItems.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _recommendedItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_recommendedItems[index].item.name),
                      trailing: Text(
                          'P${_recommendedItems[index].item.price.toStringAsFixed(2)} x ${_recommendedItems[index].quantity}'),
                    );
                  },
                ),
              ),
            SizedBox(height: 10.0),
            if (_totalPrice > 0.0)
              Text(
                'Total: P${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
          ],
        ),
      ),
    );
  }
}
