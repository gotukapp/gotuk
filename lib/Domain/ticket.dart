
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Categories and subcategories
final Map<String, List<String>> ticketReasons = {
  'Technical Issue': ['App Crash', 'Login Issue', 'Slow Performance'],
  'Account': ['Profile Update', 'Account Deletion', 'Password Reset'],
  'Reservation': ['Cancel', 'Change Date', 'Incorrect Charge', 'Refund Request', 'Payment Issue']
};

class Ticket {
  String? id;
  DocumentReference? userRef;
  DocumentReference? tripRef;
  final String category;
  final String reason;
  final String subject;
  final String message;
  DateTime? creationDate;

  Ticket(this.id, this.tripRef, this.category, this.reason, this.subject, this.message);

  Future<Future<DocumentReference<Map<String, dynamic>>>> submitTicket() async {
    return FirebaseFirestore.instance
        .collection('tickets')
        .add(<String, dynamic>{
      'userRef': FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid),
      'tripRef': tripRef,
      'category': category,
      'reason': reason,
      'subject': subject,
      'message': message,
      'creationDate': FieldValue.serverTimestamp()
    });
  }
}
