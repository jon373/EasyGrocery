import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final currencyFormat = NumberFormat('#,###', 'en_US');

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any existing commas in the input
    String newText = newValue.text.replaceAll(',', '');

    // Parse the input as an integer and format it with commas
    if (newText.isNotEmpty) {
      int value = int.parse(newText);
      String formattedValue = NumberFormat('#,###').format(value);

      return TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(
          offset: formattedValue.length,
        ),
      );
    }

    // Return the new value if empty
    return newValue;
  }
}
