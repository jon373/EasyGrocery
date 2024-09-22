import 'package:flutter/material.dart';
import 'categories.dart';

class CartDetailsScreen extends StatelessWidget {
  final Cart cart;

  CartDetailsScreen({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cart.name),
      ),
      body: ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          quantityItem item = cart.items[index];
          return ListTile(
            title: Text(item.item.name),
            subtitle: Text('Quantity: ${item.quantity}'),
          );
        },
      ),
    );
  }
}
