import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirebase {

  final String id;
  final String? name;
  final String? email;
  final String? phone;

  UserFirebase(this.id, this.name, this.email, this.phone);

  factory UserFirebase.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return UserFirebase(snapshot.id, data?['name'], data?['email'], data?['phone']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "phone": phone
    };
  }
}
