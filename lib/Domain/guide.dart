import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/appUser.dart';

class Guide extends AppUser {

  Guide(super.id, super.name, super.email, super.phone);

  factory Guide.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return Guide(snapshot.id, data?['name'], data?['email'], data?['phone']);
  }
}
