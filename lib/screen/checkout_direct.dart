import 'package:EasyGrocery/provider/categories.dart';
import 'package:EasyGrocery/screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for JSON handling

class CheckoutPage extends StatefulWidget {
  final List<quantityItem> addedItems;
  final double totalAmount;
  final Function(String) onAddressSelected;
  final Function(String) onPaymentMethodSelected;

  CheckoutPage({
    required this.addedItems,
    required this.totalAmount,
    required this.onAddressSelected,
    required this.onPaymentMethodSelected,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
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

  // This method will update the order counts and save them
  Future<void> _updateOrderCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> orderCountMap = {};

    // Update order counts based on added items
    for (var item in widget.addedItems) {
      if (orderCountMap.containsKey(item.item.name)) {
        orderCountMap[item.item.name] =
            orderCountMap[item.item.name]! + item.quantity;
      } else {
        orderCountMap[item.item.name] = item.quantity;
      }
    }

    // Save the updated order counts to SharedPreferences
    String orderCountMapString = jsonEncode(orderCountMap);
    await prefs.setString('orderCountMap', orderCountMapString);
    print('Updated orderCountMap: $orderCountMap'); // Debug print
  }

  void _confirmOrder() {
    if (selectedAddress != null && selectedPaymentMethod != null) {
      // Update order counts before navigating
      _updateOrderCounts().then((_) {
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
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: widget.addedItems.map((quantityItem) {
                  return ListTile(
                    title: Text(
                        '${quantityItem.item.name} x${quantityItem.quantity}'),
                    subtitle: Text(
                        'Total: Peso ${(quantityItem.item.price * quantityItem.quantity).toStringAsFixed(2)}'),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Select Delivery Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: Text('Select an address'),
              value: selectedAddress,
              onChanged: (String? newValue) {
                setState(() {
                  selectedAddress = newValue;
                  widget.onAddressSelected(newValue!);
                });
              },
              items: deliveryAddresses
                  .map<DropdownMenuItem<String>>((String address) {
                return DropdownMenuItem<String>(
                  value: address,
                  child: Text(address),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Select Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: Text('Select a payment method'),
              value: selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentMethod = newValue;
                  widget.onPaymentMethodSelected(newValue!);
                });
              },
              items:
                  paymentMethods.map<DropdownMenuItem<String>>((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Total: Peso ${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
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

class OrderSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              'Your order has been placed successfully!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
