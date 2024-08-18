// categories.dart
class GroceryItem {
  final String name;
  final String category;
  final double price;

  GroceryItem(
      {required this.name, required this.category, required this.price});
}

class CartItem {
  final GroceryItem item;
  int quantity;

  CartItem({required this.item, required this.quantity});
}

final List<GroceryItem> groceryItems = [
  GroceryItem(name: 'Milk', category: 'Dairy', price: 50.0),
  GroceryItem(name: 'Bread', category: 'Bakery', price: 30.0),
  GroceryItem(name: 'Eggs', category: 'Dairy', price: 10.0),
  GroceryItem(name: 'Apple', category: 'Fruits', price: 20.0),
  // Add more items here
];
