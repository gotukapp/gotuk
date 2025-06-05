import 'package:cloud_firestore/cloud_firestore.dart';

void sendEmail(batch, email, subject, body) {
  final mailRef =  FirebaseFirestore.instance.collection("mail").doc();
  print("send Email:" + email);
  batch.set(mailRef, {
    "to": [email],
    "message": {
      "subject": subject,
      "html": body
    }
  });
}
