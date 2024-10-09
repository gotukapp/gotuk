import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/tour.dart';
import 'package:firebase_auth/firebase_auth.dart';

List trips = [
  Trip.create(tourList[0].id, DateTime(2024,8,1,13,0,0), 6, 'pending'),
  Trip.create(tourList[1].id, DateTime(2024,8,10,10,30,0), 6, 'booked'),
  Trip.create(tourList[3].id, DateTime(2024,8,4,18,30,0), 6, 'finished'),
  Trip.create(tourList[2].id, DateTime(2024,8,5,11,30,0), 6, 'finished'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'finished'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'finished'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'pending'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'finished'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'booked'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'booked'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'booked'),
  Trip.create(tourList[0].id, DateTime(2024,8,2,14,0,0), 3, 'finished')
];

class Trip {

  String? id;
  final int tourId;
  final DateTime date;
  final int persons;
  final String status;
  String? clientId;
  String? guideId;

  Trip(this.id, this.tourId, this.date, this.persons, this.status, this.clientId);

  Trip.create(this.tourId, this.date, this.persons, this.status);

  factory Trip.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Trip( snapshot.id, data?['tourId'], data?['date'].toDate(), data?['persons'], data?['status'], data?['clientId']);
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

  static List get pendingTrips {
    return trips.where((b) => b.status == 'pending').toList();
  }

  static List get waitingTrips {
    return trips.where((b) => b.status == 'booked').toList();
  }

  static List get finishedTrips {
    return trips.where((b) => b.status == 'finished').toList();
  }

  static addTrip(Trip trip) {
    trips.add(trip);
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
