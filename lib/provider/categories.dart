// categories.dart
class GroceryItem {
  final String name;
  final String category;
  final double price;
  final List<String> mealType; // New field to categorize items by meal type

  GroceryItem({
    required this.name,
    required this.category,
    required this.price,
    required this.mealType, // Add the mealType field in the constructor
  });
}

class quantityItem {
  GroceryItem item; // Removed `final`
  int quantity;
  List<String> uniqueIds;
  quantityItem(
      {required this.item, required this.quantity, required this.uniqueIds});
}

// Updated list of grocery items with mealType included
final List<GroceryItem> groceryItems = [
  GroceryItem(
    name: 'Spring Chicken',
    category: 'Meat',
    price: 200.0,
    mealType: ['Lunch', 'Dinner'],
  ),
  GroceryItem(
    name: 'Whole Chicken',
    category: 'Meat',
    price: 250.0,
    mealType: ['Lunch', 'Dinner'],
  ),
  GroceryItem(
    name: 'Grind Beef',
    category: 'Meat',
    price: 350.0,
    mealType: ['Lunch', 'Dinner'],
  ),
  GroceryItem(
    name: 'Corned Beef',
    category: 'Meat',
    price: 80.0,
    mealType: ['Breakfast', 'Lunch'],
  ),
  GroceryItem(
    name: 'Bearbrand Milk',
    category: 'Dairy',
    price: 98.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Nestle Non-Fat Milk',
    category: 'Dairy',
    price: 105.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Alaska Milk',
    category: 'Dairy',
    price: 98.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Eggs',
    category: 'Dairy',
    price: 250.0,
    mealType: ['Breakfast', 'Lunch'],
  ),
  GroceryItem(
    name: 'Jeach Bread',
    category: 'Bakery',
    price: 45.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'J.CO Donut',
    category: 'Bakery',
    price: 549.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Dunkin Donut',
    category: 'Bakery',
    price: 529.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Louella Bread',
    category: 'Bakery',
    price: 45.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Hulyana Bread',
    category: 'Bakery',
    price: 40.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Andrei Bread',
    category: 'Bakery',
    price: 30.0,
    mealType: ['Breakfast'],
  ),
  GroceryItem(
    name: 'Apple',
    category: 'Fruits',
    price: 20.0,
    mealType: ['Breakfast', 'Lunch'],
  ),
  GroceryItem(
    name: 'Pears',
    category: 'Fruits',
    price: 20.0,
    mealType: ['Breakfast', 'Lunch'],
  ),
  // Add more items here with mealType categorized appropriately
];

// Updated list of categories
final List<String> categories = [
  'Dairy',
  'Bakery',
  'Fruits',
  'Meat',
  'Breakfast', // Added meal types as categories
  'Lunch',
  'Dinner',
];

class Cart {
  String id; // Unique identifier
  String name;
  List<quantityItem> items;
  bool isSelected;

  Cart(
      {required this.id,
      required this.name,
      required this.items,
      this.isSelected = false});
}
