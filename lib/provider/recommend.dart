import 'package:flutter/material.dart';
import 'categories.dart'; // Import the categories file

class RecommendedItemsScreen extends StatelessWidget {
  final String mealType;
  final double budget;
  final List<quantityItem> recommendedItems;
  final Function(List<quantityItem>) onAddToHomeScreen; // Callback function

  RecommendedItemsScreen({
    required this.mealType,
    required this.budget,
    required this.recommendedItems,
    required this.onAddToHomeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$mealType Recommendations'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: recommendedItems.length,
              itemBuilder: (context, index) {
                final item = recommendedItems[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(item.item.name),
                    subtitle:
                        Text('Price: ₱${item.item.price.toStringAsFixed(2)}'),
                    trailing: Text(item.item.category),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Trigger the callback to add items to the home screen
                onAddToHomeScreen(recommendedItems);
                Navigator.pop(context); // Go back to the home screen
              },
              child: Text(
                'Add All to Home Screen',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBD4254), // Customize button color
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
