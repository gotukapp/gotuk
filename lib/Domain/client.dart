import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/appUser.dart';

class Client extends AppUser {

  Client(super.id, super.name, super.email, super.phone);

  factory Client.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return Client(snapshot.id, data?['name'], data?['email'], data?['phone']);
  }
}
