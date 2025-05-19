import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../Domain/point.dart';

class Tour {
  final String id;
  final bool isActive;
  final String name;
  final int duration;
  final String durationDescription;
  final int durationSlots;
  final String mainImage;
  final List<String> images;
  final double lowPrice;
  final double highPrice;
  final String pickupPoint;
  final num rating;
  List<Point>? pickupPoints;
  bool? favorite;

  static List<Tour> availableTours = [];

  Tour(this.id, this.isActive, this.name, this.duration, this.durationDescription, this.durationSlots, this.mainImage, this.images, this.lowPrice,
      this.highPrice, this.pickupPoint, this.rating);

  factory Tour.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    Tour t = Tour(snapshot.id,
        data?['isActive'],
        data?['name'],
        data?['duration'],
        data?['durationDescription'],
        data?['durationSlots'],
        data?['mainImage'],
        (data?['images'] as List<dynamic>).cast<String>(),
        (data?['lowPrice'] as num).toDouble(),
        (data?['highPrice'] as num).toDouble(),
        data?['pickupPoint'],
        data?['rating']
    );
    return t;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isActive': isActive,
      'name': name,
      'duration': duration,
      'durationDescription': durationDescription,
      'durationSlots': durationSlots,
      'mainImage': mainImage,
      'images': images,
      'lowPrice': lowPrice,
      'highPrice': highPrice,
      'pickupPoint': pickupPoint,
      'rating': rating,
      'pickupPoints': pickupPoints
    };
  }

  double getTourPrice(bool smallPriceSelected) {
    return getTotalPrice(smallPriceSelected) - getFeePrice(smallPriceSelected);
  }

  double getFeePrice(bool smallPriceSelected) {
    return double.parse((getTotalPrice(smallPriceSelected) * 0.15).toStringAsFixed(0));
  }

  double getTotalPrice(bool smallPriceSelected) {
    return smallPriceSelected ? lowPrice : highPrice;
  }

  Future<int?> get totalReviews async {
    AggregateQuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tours')
        .doc(id)
        .collection('reviews').count().get();

    return querySnapshot.count;
  }

  Future<void> updateRating(double ratingTour) async {
    DocumentReference tourDoc = FirebaseFirestore.instance
        .collection('tours')
        .doc(id);
    int? totalTourReviews = await totalReviews;

    if (totalTourReviews != null) {
      double result = ((rating * totalTourReviews) + ratingTour) / (totalTourReviews + 1);

      tourDoc.update({
        "rating": double.parse(result.toStringAsFixed(1))
      });
    }
  }

  addReview(String tripId, String clientName, double ratingTour, String commentTour) async {
    DocumentReference tourReviewDoc = FirebaseFirestore.instance
        .collection('tours')
        .doc(id)
        .collection('reviews')
        .doc(tripId);
    await tourReviewDoc.set({
      'name': clientName,
      'rating': ratingTour,
      'comment': commentTour,
      'creationDate': FieldValue.serverTimestamp()
    });
  }

  static Future<void> fetchTours() async {
    while (true) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("tours").get();

        if (snapshot.docs.isNotEmpty) {
          List<Tour> tours = [];
          for (var docSnapshot in snapshot.docs) {
            Tour tour = Tour.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>, null);
            if (tour.isActive) {
              tours.add(tour);
            }
          }
          for(Tour t in tours) {
            await t.loadPickupPoints();
          }

          Tour.availableTours = tours;
          return;
        }
      } catch (e) {
        await Sentry.captureException(e);
      }
      await Future.delayed(const Duration(milliseconds: 300)); // Wait before retrying
    }
  }

  Future<void> loadPickupPoints() async {
    QuerySnapshot snapshot = await  FirebaseFirestore.instance.collection("tours").doc(id).collection("pickupPoints").get();
    List<Point> points = [];
    if (snapshot.docs.isNotEmpty) {
      for (var docSnapshot in snapshot.docs) {
        Point point = Point.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>, null);
        points.add(point);
      }
    }
    pickupPoints = points;
  }
}
