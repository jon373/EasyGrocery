import 'package:flutter/material.dart';
import 'categories.dart';
import 'dart:math'; // For generating unique IDs

class CartProvider with ChangeNotifier {
  final List<Cart> _carts = [];

  List<Cart> get carts => _carts;

  // Generate a unique ID for each cart
  String _generateCartId() {
    return Random().nextInt(100000).toString(); // Generate a simple random ID
  }

  // Add a new cart with a unique ID
  void addCart(String name) {
    _carts.add(Cart(id: _generateCartId(), name: name, items: []));
    notifyListeners();
  }

  // Remove a cart by its index and rename the remaining carts
  void removeCartAt(int index) {
    _carts.removeAt(index);

    // Rename the remaining carts sequentially
    for (int i = 0; i < _carts.length; i++) {
      _carts[i].name = 'Cart ${i + 1}';
    }

    notifyListeners(); // Notify listeners to update the UI
  }

  // Remove a cart by its ID
  void removeCartById(String cartId) {
    _carts.removeWhere((cart) => cart.id == cartId);

    // Rename the remaining carts sequentially
    for (int i = 0; i < _carts.length; i++) {
      _carts[i].name = 'Cart ${i + 1}';
    }

    notifyListeners(); // Notify listeners to update the UI
  }

  // Add item to cart
  void addItemToCart(String cartName, quantityItem item) {
    Cart cart;
    try {
      // Try to find the cart with the given name
      cart = _carts.firstWhere((cart) => cart.name == cartName);
    } catch (e) {
      // If no cart is found, create a new one
      print('No cart found with name $cartName, creating a new one.');
      cart = Cart(id: _generateCartId(), name: cartName, items: []);
      _carts.add(cart);
    }

    // Check if the item already exists in the cart
    int index = cart.items.indexWhere((it) => it.item.name == item.item.name);
    if (index != -1) {
      // Item exists, update the quantity
      cart.items[index].quantity += item.quantity;
    } else {
      // Item does not exist, add it to the cart
      cart.items.add(item);
    }

    notifyListeners(); // Notify listeners to rebuild the UI
  }

  // Remove item from cart
  void removeItemFromCart(String cartName, quantityItem item) {
    final Cart cart = _carts.firstWhere((cart) => cart.name == cartName);
    cart.items.remove(item);
    notifyListeners();
  }

  // Toggle cart selection (for checkout)
  void toggleCartSelection(String cartName) {
    final cart = _carts.firstWhere((cart) => cart.name == cartName);
    cart.isSelected = !cart.isSelected;
    notifyListeners();
  }

  // Update the quantity of an item in the cart
  void updateItemQuantity(String cartName, quantityItem item, int newQuantity) {
    Cart cart = _carts.firstWhere((cart) => cart.name == cartName);
    int index = cart.items.indexWhere((i) => i.item.name == item.item.name);

    if (index != -1) {
      cart.items[index].quantity = newQuantity; // Update the quantity
      notifyListeners(); // Notify the UI of changes
    }
  }

  // Get the total price of all items in a cart
  double getCartTotal(String cartName) {
    Cart cart = _carts.firstWhere((cart) => cart.name == cartName);
    return cart.items.fold(
      0.0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );
  }
}
