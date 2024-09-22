// categories.dart
class GroceryItem {
  final String name;
  final String category;
  final double price;

  GroceryItem(
      {required this.name, required this.category, required this.price});
}

class quantityItem {
  GroceryItem item; // Removed `final`
  int quantity;

  quantityItem({required this.item, required this.quantity});
}

final List<GroceryItem> groceryItems = [
  GroceryItem(name: 'Spring Chicken', category: 'Meat', price: 200.0),
  GroceryItem(name: 'Whole Chicken', category: 'Meat', price: 250.0),
  GroceryItem(name: 'Grind Beef', category: 'Meat', price: 350.0),
  GroceryItem(name: 'Corned Beef', category: 'Meat', price: 80.0),
  GroceryItem(name: 'Bearbrand Milk', category: 'Dairy', price: 98.0),
  GroceryItem(name: 'Nestle Non-Fat Milk', category: 'Dairy', price: 105.0),
  GroceryItem(name: 'Alaska Milk', category: 'Dairy', price: 98.0),
  GroceryItem(name: 'Eggs', category: 'Dairy', price: 250.0),
  GroceryItem(name: 'Jeach Bread', category: 'Bakery', price: 45.0),
  GroceryItem(name: 'J.CO Donut', category: 'Bakery', price: 549.0),
  GroceryItem(name: 'Dunkin Donut', category: 'Bakery', price: 529.0),
  GroceryItem(name: 'Louella Bread', category: 'Bakery', price: 45.0),
  GroceryItem(name: 'Hulyana Bread', category: 'Bakery', price: 40.0),
  GroceryItem(name: 'Andrei Bread', category: 'Bakery', price: 30.0),
  GroceryItem(name: 'Apple', category: 'Fruits', price: 20.0),
  GroceryItem(name: 'Piers', category: 'Fruits', price: 20.0),
  // Add more items here
];

final List<String> categories = [
  'Dairy',
  'Bakery',
  'Fruits',
  'Meat',
  // Add more categories here
];

class Cart {
  String name;
  List<quantityItem> items;

  Cart({
    required this.name,
    required this.items,
  });
}
