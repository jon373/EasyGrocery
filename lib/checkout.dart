import 'package:flutter/material.dart';
import 'categories.dart'; // Import the file with the grocery items and quantityItem class

class CheckoutPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Predefined delivery addresses
    List<String> deliveryAddresses = [
      '123 Main St, Cityville',
      '456 Maple Ave, Townsville',
      '789 Oak Rd, Villageville',
    ];

    // Predefined payment methods
    List<String> paymentMethods = [
      'Credit Card',
      'Debit Card',
      'Cash on Delivery',
    ];

    String? selectedAddress;
    String? selectedPaymentMethod;

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
                children: addedItems.map((quantityItem) {
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
                onAddressSelected(newValue!);
                selectedAddress = newValue;
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
                onPaymentMethodSelected(newValue!);
                selectedPaymentMethod = newValue;
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
              'Total: Peso ${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle order confirmation here
                },
                child: Text('Confirm Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
