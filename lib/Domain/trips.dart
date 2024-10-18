import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/tour.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Trip {

  String? id;
  final int tourId;
  final DateTime date;
  final int persons;
  final String status;
  final String guideLang;
  final String paymentMethod;
  final String creditCardId;
  final bool withTaxNumber;
  final String taxNumber;
  DocumentReference? clientRef;
  DocumentReference? guideRef;
  String? reservationId;

  Trip(this.id, this.tourId, this.date, this.persons, this.status, this.clientRef,
      this.guideRef, this.guideLang, this.paymentMethod, this.creditCardId,
      this.withTaxNumber, this.taxNumber, this.reservationId);

  factory Trip.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Trip(snapshot.id,
        data?['tourId'],
        data?['date'].toDate(),
        data?['persons'],
        data?['status'],
        data?['clientRef'],
        data?['guideRef'],
        data?['guideLang'],
        data?['paymentMethod'],
        data?['creditCardId'],
        data?['withTaxNumber'],
        data?['taxNumber'],
        data?['reservationId']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "tourId": tourId,
      "date": date,
      "persons": persons,
      "status": status,
      if (clientRef != null) "clientRef": clientRef,
    };
  }

  Tour get tour {
    return tourList.firstWhere((t) => t.id == tourId);
  }

  double get price {
    if (persons < 4) {
      return tour.getTourPrice(true);
    }

    return tour.getTourPrice(false);
  }

  static Future<DocumentReference<Map<String, dynamic>>> addTrip(DocumentReference guideRef, int tourId,
      DateTime date, int persons, String status,
      String guideLang, String paymentMethod, String creditCardId,
      bool withTaxNumber, String taxNumber) {
    return FirebaseFirestore.instance
        .collection('trips')
        .add(<String, dynamic>{
      'tourId': tourId,
      'reservationId': status == 'booked' ? generateReservationId() : '',
      'clientRef': FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}'),
      'guideRef': guideRef,
      'status': status,
      'date': date,
      'persons': persons,
      'guideLang': guideLang,
      'paymentMethod': paymentMethod,
      'creditCardId': creditCardId,
      'withTaxNumber': withTaxNumber,
      'taxNumber': taxNumber,
      'creationDate': DateTime.now()
    });
  }

  Future<bool> acceptTour() async {
    final sfDocRef = FirebaseFirestore.instance.collection("trips").doc(id);
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(sfDocRef);
      final currentStatus = snapshot.get("status");
      if (currentStatus == 'pending') {
        transaction.update(sfDocRef, {"status": "booked",
            "guideRef": FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}'),
            "acceptedDate": DateTime.now(),
            "reservationId": generateReservationId()});
        return true;
      }
      return false;
    });
  }

  void startTour() {
    FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({"status": "started",
      "startedDate": DateTime.now()});
  }

  void finishTour() {
    FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({"status": "finished",
      "finishedDate": DateTime.now()});
  }

  static String generateReservationId()
  {
    var letters = "ABCDEFGHJKMNPQRSTUXY";
    String text = "";
    for (var i = 0; i < 6; i++) {
      text += letters[(Random().nextDouble() * letters.length).round()];
    }
    return text;
  }
}
