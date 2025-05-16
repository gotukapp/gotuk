import 'package:cloud_firestore/cloud_firestore.dart';

class GeoCoordinates {
  final double latitude;
  final double longitude;

  GeoCoordinates({
    required this.latitude,
    required this.longitude,
  });
}

class Point {
  final String id;
  final String name;
  final GeoCoordinates coordinates;

  Point(this.id, this.name, this.coordinates);

  factory Point.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    final coords = data?['coordinates'] as GeoPoint;
    Point t = Point(snapshot.id,
        data?['name'],
        GeoCoordinates(latitude: coords.latitude, longitude: coords.longitude)
    );
    return t;
  }
}
