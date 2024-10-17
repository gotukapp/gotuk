import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final bool accountValidated;
  final num rating;

  AppUser(this.id, this.name, this.email, this.phone, this.accountValidated, this.rating);

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return AppUser(snapshot.id, data?['name'], data?['email'], data?['phone'], data?['accountValidated'], data?['rating']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "accountValidated": accountValidated,
      "rating": rating
    };
  }
}

Future<AppUser> getUserFirebaseInstance(bool guideMode, User user) async {
  final ref = FirebaseFirestore.instance.collection("users").doc(user.uid)
      .withConverter(
    fromFirestore: AppUser.fromFirestore,
    toFirestore: (AppUser user, _) => user.toFirestore(),
  );
  final docSnap = await ref.get();
  AppUser? appUser = docSnap.data();
  if (appUser == null) {
    appUser = AppUser(user.uid, user.displayName, user.email, user.phoneNumber, false, 0.0);
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .set(appUser.toFirestore());
  }
  return appUser;
}
