import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> createStripPayment({
  required int amount,
  required String currency
}) async {
  final url = Uri.parse('https://createstripepayment-m4ti3eo3ua-uc.a.run.app');

  final headers = {
    'Content-Type': 'application/json'
  };

  final payload = {
    "amount": amount,
    "currency": currency
  };

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(payload),
  );
  if (response.statusCode == 200) {
    return response.body;
  }

  return null;
}
