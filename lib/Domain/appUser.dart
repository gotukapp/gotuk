import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class AppUser {

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final bool accountValidated;
  num? rating;
  List<String>? languages;

  AppUser(this.id, this.name, this.email, this.phone, this.accountValidated, this.rating, this.languages);

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return AppUser(snapshot.id, data?['name'], data?['email'],
        data?['phone'], data?['accountValidated'],
        data?['rating'], data?['languages']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "accountValidated": accountValidated,
      "rating": rating,
      "languages": languages
    };
  }

  Future<void> updateAvailability(DateTime date,int status) async {
    CollectionReference userUnavailability = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('unavailability');

    String day = DateFormat('yyyy-MM-dd').format(date);
    String hour = DateFormat('HH:mm').format(date);
    DocumentSnapshot dayUnavailability = await userUnavailability.doc(day).get();
    List<dynamic> slots = [];
    if (dayUnavailability.exists) {
      slots = dayUnavailability.get("slots");
    }
    if (status == 1) {
      slots.remove(hour);
    } else {
      slots.add(hour);
    }
    userUnavailability.doc(day).set({
      "date": DateTime.parse(day),
      "slots": slots
    });
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
    appUser = AppUser(user.uid, user.displayName, user.email, user.phoneNumber, false, 0.0, null);
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .set(appUser.toFirestore());
  }

  if (guideMode) {
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .update({"guideMode": true});
  }

  if (!guideMode) {
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .update({"clientMode": true});
  }

  return appUser;
}

class UserProvider with ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;

  void setUser(AppUser newUser) {
    _user = newUser;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
