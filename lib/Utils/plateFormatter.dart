import 'package:flutter/services.dart';

class PlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase();
    text = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (text.isEmpty) {
      return newValue;
    }

    if (text.length > 6) {
      text = text.substring(0, 6);
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
