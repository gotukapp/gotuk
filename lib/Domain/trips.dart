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
  String? clientId;
  String? guideId;
  String? reservationId;

  Trip(this.id, this.tourId, this.date, this.persons, this.status,
      this.clientId, this.guideId, this.guideLang, this.paymentMethod, this.creditCardId,
      this.withTaxNumber, this.taxNumber, this.reservationId);

  Trip.create(this.tourId, this.date, this.persons, this.status,
      this.guideLang, this.paymentMethod, this.creditCardId,
      this.withTaxNumber, this.taxNumber);

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
        data?['clientId'],
        data?['guideId'],
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
      if (clientId != null) "clientId": clientId,
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

  static Future<DocumentReference<Map<String, dynamic>>> addTrip(Trip trip) {
    return FirebaseFirestore.instance
        .collection('trips')
        .add(<String, dynamic>{
      'tourId': trip.tour.id,
      'clientId': FirebaseAuth.instance.currentUser?.uid,
      'status': trip.status,
      'date': trip.date,
      'persons': trip.persons,
      'guideLang': trip.guideLang,
      'paymentMethod': trip.paymentMethod,
      'creditCardId': trip.creditCardId,
      'withTaxNumber': trip.withTaxNumber,
      'taxNumber': trip.taxNumber,
    });
  }

  Future<bool> acceptTour() async {
    final sfDocRef = FirebaseFirestore.instance.collection("trips").doc(id);
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(sfDocRef);
      final currentStatus = snapshot.get("status");
      if (currentStatus == 'pending') {
        transaction.update(sfDocRef, {"status": "booked",
            "guideId": FirebaseAuth.instance.currentUser?.uid,
            "bookedDate": DateTime.now(),
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

  String generateReservationId()
  {
    var letters = "ABCDEFGHJKMNPQRSTUXY";
    String text = "";
    for (var i = 0; i < 6; i++) {
      text += letters[(Random().nextDouble() * letters.length).round()];
    }
    return text;
  }
}
