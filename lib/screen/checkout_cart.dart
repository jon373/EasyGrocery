import 'package:EasyGrocery/provider/categories.dart';
import 'package:EasyGrocery/screen/checkout_direct.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for JSON handling

class CheckoutPage1 extends StatefulWidget {
  final List<Cart> carts;
  final double totalAmount; // Total amount of items only (without fees)
  final Function(String) onAddressSelected;
  final Function(String) onPaymentMethodSelected;
  final Function onOrderConfirmed;

  const CheckoutPage1({
    super.key,
    required this.totalAmount,
    required this.onAddressSelected,
    required this.onPaymentMethodSelected,
    required this.carts,
    required this.onOrderConfirmed,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage1> {
  List<String> deliveryAddresses = [
    '123 Main St, Cityville',
    '456 Maple Ave, Townsville',
    '789 Oak Rd, Villageville',
  ];

  List<String> paymentMethods = [
    'Credit Card',
    'Debit Card',
    'Cash on Delivery',
  ];

  String? selectedAddress;
  String? selectedPaymentMethod;

  final double deliveryFee = 50.00;
  double serviceFee = 0.00; // This will be calculated as 2% of the item total

  @override
  void initState() {
    super.initState();
    _calculateServiceFee();
  }

  void _calculateServiceFee() {
    setState(() {
      serviceFee = widget.totalAmount * 0.02;
    });
  }

  double _calculateFinalTotal() {
    return widget.totalAmount + serviceFee + deliveryFee;
  }

  Future<void> _updateOrderCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? orderCountMapString = prefs.getString('orderCountMap');
    Map<String, int> orderCountMap = {};

    // If there is an existing orderCountMap, decode it
    if (orderCountMapString != null) {
      orderCountMap = Map<String, int>.from(
        jsonDecode(orderCountMapString)
            .map((key, value) => MapEntry(key, value as int)),
      );
    }

    // Update order counts based on items in all selected carts
    for (var cart in widget.carts) {
      for (var item in cart.items) {
        if (orderCountMap.containsKey(item.item.name)) {
          orderCountMap[item.item.name] =
              orderCountMap[item.item.name]! + item.quantity;
        } else {
          orderCountMap[item.item.name] = item.quantity;
        }
      }
    }

    // Save the updated order counts to SharedPreferences
    String updatedOrderCountMapString = jsonEncode(orderCountMap);
    await prefs.setString('orderCountMap', updatedOrderCountMapString);
    print('Updated orderCountMap: $orderCountMap'); // Debug print
  }

  void _confirmOrder() {
    if (selectedAddress != null && selectedPaymentMethod != null) {
      // Update order counts before navigating
      _updateOrderCounts().then((_) {
        widget.onOrderConfirmed(); // Call callback to clear carts in CartScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select both address and payment method')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Carts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: widget.carts.map((cart) {
                  return ExpansionTile(
                    title: Text(cart.name),
                    children: cart.items.map((item) {
                      return ListTile(
                        title: Text('${item.item.name} x${item.quantity}'),
                        subtitle: Text(
                            'Total: ₱ ${(item.item.price * item.quantity).toStringAsFixed(2)}'),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Horizontal scrolling row for selecting address and payment method
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Select Delivery Address Dropdown
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Delivery Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          hint: const Text('Select an address'),
                          value: selectedAddress,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAddress = newValue;
                              widget.onAddressSelected(newValue!);
                            });
                          },
                          isExpanded: true,
                          items: deliveryAddresses
                              .map<DropdownMenuItem<String>>((String address) {
                            return DropdownMenuItem<String>(
                              value: address,
                              child: Text(address),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Select Payment Method Dropdown
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          hint: const Text('Select a payment method'),
                          value: selectedPaymentMethod,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPaymentMethod = newValue;
                              widget.onPaymentMethodSelected(newValue!);
                            });
                          },
                          isExpanded: true,
                          items: paymentMethods
                              .map<DropdownMenuItem<String>>((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Delivery Fee and Service Fee Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Fee',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₱${deliveryFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Service Fee: 2%',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₱${serviceFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ₱${_calculateFinalTotal().toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _confirmOrder,
                child: Text('Confirm Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
