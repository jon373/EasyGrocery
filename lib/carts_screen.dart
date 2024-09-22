import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart'; // Ensure you have the CartProvider imported
import 'cart_details_screen.dart';
import 'categories.dart';

class CartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Cart> carts = Provider.of<CartProvider>(context).carts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carts'),
      ),
      body: carts.isEmpty
          ? _buildEmptyCartMessage(context)
          : _buildCartList(carts, context),
    );
  }

  Widget _buildEmptyCartMessage(BuildContext context) {
    return Center(
      child: Text(
        'No carts available. Add a cart to show here.',
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildCartList(List<Cart> carts, BuildContext context) {
    return ListView.builder(
      itemCount: carts.length,
      itemBuilder: (context, index) {
        Cart cart = carts[index];
        return ListTile(
          title: Text(cart.name),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CartDetailsScreen(cart: cart)),
          ),
        );
      },
    );
  }

  void _addCart(BuildContext context) {
    // Call to Provider to add a new cart
    String cartName =
        'Cart ${Provider.of<CartProvider>(context, listen: false).carts.length + 1}';
    Provider.of<CartProvider>(context, listen: false).addCart(cartName);
  }
}
