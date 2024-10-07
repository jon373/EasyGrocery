import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/categories.dart';
import '../provider/cart_provider.dart'; // Import the CartProvider to manage the state

class CartDetailsScreen extends StatefulWidget {
  final Cart cart;

  const CartDetailsScreen({super.key, required this.cart});

  @override
  _CartDetailsScreenState createState() => _CartDetailsScreenState();
}

class _CartDetailsScreenState extends State<CartDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Use Provider to get the cart items and total price
    final cartProvider = Provider.of<CartProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cart.name),
      ),
      body: ListView.builder(
        itemCount: widget.cart.items.length,
        itemBuilder: (context, index) {
          quantityItem item = widget.cart.items[index];

          return Dismissible(
            key: Key(item.item.name),
            direction: DismissDirection.endToStart, // Swipe left to right
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              color: Colors.red, // Background color for dismiss action
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              // Remove the item from the cart
              setState(() {
                cartProvider.removeItemFromCart(widget.cart.name, item);
              });

              // Show a snackbar to indicate item removal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("${item.item.name} removed from the cart")),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display the item name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Display the total price based on quantity
                        Text(
                          'Price: ₱${(item.item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    // Display the plus and minus buttons for quantity adjustment
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (item.quantity > 1) {
                                // Decrease quantity and update the cart
                                cartProvider.updateItemQuantity(
                                    widget.cart.name, item, item.quantity - 1);
                              } else {
                                _showRemoveConfirmationDialog(item);
                              }
                            });
                          },
                        ),
                        Text('${item.quantity}',
                            style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              // Increase quantity and update the cart
                              cartProvider.updateItemQuantity(
                                  widget.cart.name, item, item.quantity + 1);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Display the total value at the bottom of the screen
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₱${cartProvider.getCartTotal(widget.cart.name).toStringAsFixed(2)}', // Display total price formatted
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show confirmation dialog before removing item
  void _showRemoveConfirmationDialog(quantityItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text("Are you sure you want to remove this item?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                Provider.of<CartProvider>(context, listen: false)
                    .removeItemFromCart(widget.cart.name,
                        item); // Remove the item from the cart
              });
              Navigator.of(context).pop();
            },
            child: const Text("Remove"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
