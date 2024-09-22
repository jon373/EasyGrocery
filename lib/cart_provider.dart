import 'package:flutter/material.dart';
import 'categories.dart';

class CartProvider with ChangeNotifier {
  List<Cart> _carts = [];

  List<Cart> get carts => _carts;

  void addCart(String name) {
    _carts.add(Cart(name: name, items: []));
    notifyListeners();
  }

  void addItemToCart(String cartName, quantityItem item) {
    Cart cart;
    try {
      // Try to find the cart with the given name
      cart = _carts.firstWhere((cart) => cart.name == cartName);
    } catch (e) {
      // If no cart is found, create a new one
      print('No cart found with name $cartName, creating a new one.');
      cart = Cart(name: cartName, items: []);
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

  void removeItemFromCart(String cartName, quantityItem item) {
    final Cart cart = _carts.firstWhere((cart) => cart.name == cartName);
    cart.items.remove(item);
    notifyListeners();
  }
}
