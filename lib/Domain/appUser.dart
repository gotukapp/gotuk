import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'client.dart';
import 'guide.dart';

class AppUser {

  final String id;
  final String? name;
  final String? email;
  final String? phone;

  AppUser(this.id, this.name, this.email, this.phone);

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return AppUser(snapshot.id, data?['name'], data?['email'], data?['phone']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "phone": phone
    };
  }
}

Future<AppUser> getUserFirebaseInstance(bool guideMode, User user) async {
  String collection = guideMode ? "guides" : "clients";
  final ref = FirebaseFirestore.instance.collection(collection).doc(user.uid)
      .withConverter(
    fromFirestore: guideMode ? Guide.fromFirestore : Client.fromFirestore,
    toFirestore: (AppUser user, _) => user.toFirestore(),
  );
  final docSnap = await ref.get();
  AppUser? appUser = docSnap.data();
  if (appUser == null) {
    appUser = guideMode ? Guide(user.uid,
        user.displayName,
        user.email,
        user.phoneNumber) :
    Client(user.uid,
        user.displayName,
        user.email,
        user.phoneNumber);
    FirebaseFirestore.instance.collection(collection)
        .doc(user.uid)
        .set(appUser.toFirestore());
  }
  return appUser;
}
