import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendNotification({
  required String targetToken,
  required String title,
  required String body,
  data
}) async {
  final url = Uri.parse('https://sendnotification-m4ti3eo3ua-uc.a.run.app');

  final headers = {
    'Content-Type': 'application/json'
  };

  final payload = {
    "token": targetToken,
    "body": body,
    "title": title,
    "data": data
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully: ${response.body}");
    } else {
      print("Failed to send notification: ${response.body}");
    }
  } catch (e) {
    print("Error sending notification: $e");
  }
}
