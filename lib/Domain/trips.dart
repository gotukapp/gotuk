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

  Trip(this.id, this.tourId, this.date, this.persons, this.status,
      this.clientId, this.guideLang, this.paymentMethod, this.creditCardId,
      this.withTaxNumber, this.taxNumber);

  Trip.create(this.tourId, this.date, this.persons, this.status,
      this.guideLang, this.paymentMethod, this.creditCardId,
      this.withTaxNumber, this.taxNumber);

  factory Trip.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Trip( snapshot.id,
        data?['tourId'],
        data?['date'].toDate(),
        data?['persons'],
        data?['status'],
        data?['clientId'],
        data?['guideLang'],
        data?['paymentMethod'],
        data?['creditCardId'],
        data?['withTaxNumber'],
        data?['taxNumber']
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

  static addTrip(Trip trip) {
    FirebaseFirestore.instance
        .collection('trips')
        .add(<String, dynamic>{
      'tourId': trip.tour.id,
      'clientId': FirebaseAuth.instance.currentUser?.uid,
      'status': trip.status,
      'date': trip.date,
      'persons': trip.persons
    });
  }

  void acceptTour() {
    FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({"status": "booked",
      "guideId": FirebaseAuth.instance.currentUser?.uid,
      "bookedDate": DateTime.now()});
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
}
