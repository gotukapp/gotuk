import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/tour.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Utils/notification.dart';

class Trip {

  String? id;
  final DocumentReference tourRef;
  final DateTime date;
  final int persons;
  String status;
  final String guideLang;
  final String paymentMethod;
  final String creditCardId;
  final bool withTaxNumber;
  final String taxNumber;
  final bool rateSubmitted;
  DocumentReference? clientRef;
  DocumentReference? guideRef;
  String? reservationId;
  bool? showStartButton;
  bool? showEndButton;
  bool? onlyElectricVehicles;
  bool? clientIsReady;

  Trip(this.id, this.tourRef, this.date, this.persons, this.status, this.clientRef,
      this.guideRef, this.guideLang, this.paymentMethod, this.creditCardId,
      this.withTaxNumber, this.taxNumber, this.reservationId, this.rateSubmitted, this.onlyElectricVehicles, this.clientIsReady);

  factory Trip.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    Trip t = Trip(snapshot.id,
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
        data?['reservationId'],
        data?['rateSubmitted'],
        data?['onlyElectricVehicles'],
        data?['clientIsReady']
    );
    t.showStartButton = t.allowShowStart();
    t.showEndButton = t.allowShowEnd();
    return t;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "tourId": tourRef,
      "date": date,
      "persons": persons,
      "status": status,
      if (clientRef != null) "clientRef": clientRef,
    };
  }

  Tour get tour {
    return tourList.firstWhere((t) => t.id == tourRef.id);
  }

  double get price {
    if (persons < 4) {
      return tour.getTourPrice(true);
    }

    return tour.getTourPrice(false);
  }

  static Future<DocumentReference<Map<String, dynamic>>> addTrip(DocumentReference? guideRef, String tourId,
      DateTime date, int persons, String status,
      String guideLang, String paymentMethod, String creditCardId,
      bool withTaxNumber, String taxNumber, bool onlyElectricVehicles) async {
    DocumentReference<Map<String, dynamic>> trip = await FirebaseFirestore.instance
        .collection('trips')
        .add(<String, dynamic>{
      'tourId': FirebaseFirestore.instance.doc('tours/$tourId'),
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
      'rateSubmitted': false,
      'creationDate': FieldValue.serverTimestamp(),
      'onlyElectricVehicles': onlyElectricVehicles
    });

    FirebaseFirestore.instance
        .collection('chat')
        .doc(trip.id)
        .update({
      "clientRef": FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}'),
      "guideRef": guideRef,
      "date": date
    });

    return trip;
  }

  Future<bool> acceptTour() async {
    final sfDocRef = FirebaseFirestore.instance.collection("trips").doc(id);
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(sfDocRef);
      final currentStatus = snapshot.get("status");
      if (currentStatus == 'pending') {
        transaction.update(sfDocRef, {"status": "booked",
            "guideRef": FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}'),
            "acceptedDate": FieldValue.serverTimestamp(),
            "reservationId": generateReservationId()});

        FirebaseFirestore.instance
            .collection('chat')
            .doc(id)
            .update({
          "guideRef": FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser!.uid}'),
        });

        DocumentSnapshot<Object?> client = await clientRef!.get();
        if (client.exists) {
          if (client.data() != null && (client.data() as Map<String, dynamic>).containsKey('firebaseToken')) {
            await sendNotification(targetToken: client.get("firebaseToken"),
              title: "Accepted Tour",
              body: "$reservationId - ${tour.name} tour was accepted");
          } else {
            print('Field "firebaseToken" does not exist or is null.');
            return true;
          }
        } else {
          print('Document does not exist.');
          return false;
        }
      }
      return false;
    });
  }

  Future<void> startTour() async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({"status": "started",
      "startedDate": FieldValue.serverTimestamp()});

    DocumentSnapshot<Object?> client = await clientRef!.get();
    await sendNotification(targetToken: client.get("firebaseToken"), title: "Start Tour", body: "$reservationId - ${tour.name} tour was started");
  }

  Future<void> finishTour() async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({"status": "finished",
      "finishedDate": FieldValue.serverTimestamp()});

    DocumentSnapshot<Object?> client = await clientRef!.get();
    await sendNotification(targetToken: client.get("firebaseToken"), title: "Finish Tour", body: "$reservationId - ${tour.name} tour was finished");
  }

  void cancelTour() {
    FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({"status": "canceled",
      "canceledDate": FieldValue.serverTimestamp()});
  }


  void setClientIsReady() {
    clientIsReady = true;
    FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({"clientIsReady": true});
  }

  static String generateReservationId()
  {
    var letters = "ABCDEFGHJKMNPQRSTUXY";
    String text = "";
    for (var i = 0; i < 3; i++) {
      text += letters[(Random().nextDouble() * letters.length).round()];
    }

    Random random = Random();
    int number = 1000 + random.nextInt(9000);

    return "$text$number";
  }

  Future<void>  submitReview(double ratingTour, String commentTour, double ratingGuide, String commentGuide) async {
    DocumentReference trip = FirebaseFirestore.instance
        .collection('trip')
        .doc(id);

    CollectionReference tourReviews = FirebaseFirestore.instance
        .collection('tours')
        .doc(tour.id)
        .collection('reviews');

    DocumentReference<Object?> tourReview = await tourReviews.add({
      'tripRef': trip,
      'name': FirebaseAuth.instance.currentUser?.displayName,
      'rating': ratingTour,
      'comment': commentTour,
      'creationDate': FieldValue.serverTimestamp()
    });

    CollectionReference guideReviews = FirebaseFirestore.instance
        .collection('users')
        .doc(guideRef?.id)
        .collection('reviews');

    DocumentReference<Object?> guideReview = await guideReviews.add({
      'tripRef': trip,
      'rating': ratingGuide,
      'comment': commentGuide,
      'creationDate': FieldValue.serverTimestamp()
    });

    FirebaseFirestore.instance
        .collection('trips')
        .doc(id)
        .update({ "rateSubmitted": true,
                  "tourReviewRef": tourReview,
                  "guideReviewRef": guideReview });
  }


  Future<void> sendChatMessage(String text, String? token, String title) async {
    CollectionReference chatMessages = FirebaseFirestore.instance
        .collection('chat')
        .doc(id)
        .collection('messages');

    DateTime messageDate = DateTime.now();

    await chatMessages.add({
      'text': text,
      'date': messageDate,
      'origin': FirebaseAuth.instance.currentUser!.uid
    });

    FirebaseFirestore.instance
        .collection('chat')
        .doc(id)
        .update({
      "hasMessages": true
    });

    if (token != null) {
      await sendNotification(targetToken: token, title: title, body: text);
    }
  }

  bool allowShowGuide() {
    int differenceInMinutes = date.difference(DateTime.now()).inMinutes;
    return (status == 'booked' || status == 'started' || status == 'finished')  && differenceInMinutes <= 60;
  }

  bool allowShowChatting() {
    int differenceInMinutes = date.difference(DateTime.now()).inMinutes;
    return (status == 'booked' || status == 'started' || status == 'finished')  && differenceInMinutes <= 60;
  }

  bool allowShowStart() {
    int differenceInMinutes = date.difference(DateTime.now()).inMinutes;
    return status == 'booked' && differenceInMinutes <= 15;
  }

  bool allowShowEnd() {
    int differenceInMinutes = date.add(Duration(minutes: tour.durationSlots - 1 * 30)).difference(DateTime.now()).inMinutes;
    return status == 'started' && differenceInMinutes <= 15;
  }
}
