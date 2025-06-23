import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

bool isTestUser() {
  var user = FirebaseAuth.instance.currentUser!;
  final isTestUser = user.phoneNumber == '+351333333333';
  return isTestUser;
}

Future<void> initStripeForUser() async {
  Stripe.publishableKey = isTestUser()
      ? 'pk_test_51RRUKlFMhm7qZENEb6CwzRNQARJBJeeHBJcBTEtWbp5f6vQpwdNtynsQ55pfWEL8b06yMLTTyPCMycvSgvwOjEk600qIAIrw4k'
      : 'pk_live_51RBeS1Deaim5Yl16fKW8HuUfqwcCz0WtYL7tGnnwDHC95oSdakh3NmrmgYLOZKk7WzzDm4Efw2MS8DNNcBvP8lHs007NQDkrxp';

  await Stripe.instance.applySettings();
}

Future<String?> createStripPayment({
  required int amount,
  required String currency
}) async {
  final url = isTestUser()
      ? Uri.parse('https://createteststripepayment-m4ti3eo3ua-uc.a.run.app')
      : Uri.parse('https://createstripepayment-m4ti3eo3ua-uc.a.run.app');

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
