import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import 'carts_details_screen.dart';
import '../provider/categories.dart';
import 'checkout_cart.dart';

class CartsScreen extends StatefulWidget {
  @override
  _CartsScreenState createState() => _CartsScreenState();
}

class _CartsScreenState extends State<CartsScreen> {
  ValueNotifier<double> _selectedTotalAmount = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _selectedTotalAmount.dispose();
    super.dispose();
  }

// List to keep track of deleted carts
  List<Cart> _deletedCarts = [];

// Function to delete multiple carts and show a combined SnackBar
  void _deleteMultipleCarts(BuildContext context, List<Cart> cartsToDelete) {
    // Store all deleted carts in a temporary variable
    _deletedCarts =
        List.from(cartsToDelete); // Update the global _deletedCarts list

    List<String> cartIds = _deletedCarts.map((cart) => cart.id).toList();

    // Remove all the carts by their IDs
    Provider.of<CartProvider>(context, listen: false)
        .removeMultipleCarts(cartIds);

    // Show a combined SnackBar for multiple carts
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(); // Hide any existing SnackBars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Multiple carts deleted"),
        duration: Duration(seconds: 3), // Show for 3 seconds
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            // Restore all the deleted carts
            Provider.of<CartProvider>(context, listen: false)
                .restoreMultipleCarts(_deletedCarts);

            // Clear the _deletedCarts list after restoring
            _deletedCarts.clear();

            // Re-update the total value after restoration
            _updateTotalValue();
          },
        ),
      ),
    );
  }

  void _deleteCart(Cart cart) {
    // Store the deleted cart in a temporary variable
    _deletedCarts.add(cart);

    // Remove the cart by ID
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeCartById(cart.id);

    // Show a combined SnackBar for single or multiple deletions
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(); // Hide any existing SnackBars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _deletedCarts.length > 1
              ? "Multiple carts deleted" // Message for multiple deletions
              : "${cart.name} deleted", // Message for single deletion
        ),
        duration: Duration(seconds: 3), // Show for 3 seconds
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            try {
              // Restore all the deleted carts
              cartProvider.restoreMultipleCarts(_deletedCarts);

              // Clear the _deletedCarts list after restoring to avoid duplications
              _deletedCarts.clear();

              // Re-update the total value after restoration
              _updateTotalValue();
            } catch (e) {
              // If there was an error during restoration, handle it gracefully
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: Unable to restore carts')),
              );
            }
          },
        ),
      ),
    );
  }

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
      bottomNavigationBar: _buildBottomBar(),
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
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: carts.length,
            itemBuilder: (context, index) {
              Cart cart = carts[index];
              // Calculate the total amount and total quantity for each cart
              double cartTotal = 0.0;
              int totalItems = 0;
              cart.items.forEach((quantityItem item) {
                cartTotal += item.item.price * item.quantity;
                totalItems += item.quantity; // Accumulate total items count
              });

              // Dismissible widget with the modified onDismissed method
              return Dismissible(
                key: Key(cart.id), // Use cart ID as the key for stability
                direction: DismissDirection.endToStart, // Swipe right to left
                background: Container(
                  color: Colors.red, // Background color when swiping
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _deleteCart(cart);
                },

                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(cart.name),
                    subtitle: Text(
                        'Total: ₱${cartTotal.toStringAsFixed(2)} - Items: $totalItems'), // Display the total amount and item count
                    leading: Checkbox(
                      value: cart.isSelected,
                      onChanged: (bool? value) {
                        Provider.of<CartProvider>(context, listen: false)
                            .toggleCartSelection(cart.name);

                        _updateTotalValue();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartDetailsScreen(cart: cart),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return ValueListenableBuilder<double>(
      valueListenable: _selectedTotalAmount,
      builder: (context, totalAmount, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₱${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Keep the total value in black
                ),
              ),
              ElevatedButton(
                onPressed: totalAmount > 0
                    ? () {
                        _checkoutSelectedCarts(context);
                      }
                    : null, // Disable the button when no carts are selected
                style: ElevatedButton.styleFrom(
                  backgroundColor: totalAmount > 0
                      ? Color(0xFFBD4254)
                      : Colors.grey, // Use backgroundColor instead of primary
                ),
                child: Text(
                  'Check Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTotalValue() {
    // Recalculate the total amount of selected carts
    List<Cart> selectedCarts = Provider.of<CartProvider>(context, listen: false)
        .carts
        .where((cart) => cart.isSelected)
        .toList();

    double totalAmount = selectedCarts.fold(
        0.0,
        (sum, cart) =>
            sum +
            cart.items.fold(0.0,
                (itemSum, item) => itemSum + item.item.price * item.quantity));

    // Update the value of the total amount
    _selectedTotalAmount.value = totalAmount;
  }

  void _checkoutSelectedCarts(BuildContext context) {
    List<Cart> selectedCarts = Provider.of<CartProvider>(context, listen: false)
        .carts
        .where((cart) => cart.isSelected)
        .toList();

    if (selectedCarts.isNotEmpty) {
      // Calculate the total amount from all selected carts
      double totalAmount = selectedCarts.fold(
          0.0,
          (sum, cart) =>
              sum +
              cart.items.fold(
                  0.0,
                  (itemSum, item) =>
                      itemSum + item.item.price * item.quantity));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage1(
            carts: selectedCarts,
            totalAmount: totalAmount, // Pass the calculated total amount
            onAddressSelected: (address) {},
            onPaymentMethodSelected: (method) {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No carts selected for checkout."),
        ),
      );
    }
  }
}
