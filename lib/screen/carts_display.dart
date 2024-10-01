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
                  // Remove the cart by ID
                  Provider.of<CartProvider>(context, listen: false)
                      .removeCartById(cart.id);

                  // Update total value
                  _updateTotalValue();

                  // Show a Snackbar with a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${cart.name} deleted")),
                  );
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
