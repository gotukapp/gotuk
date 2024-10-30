import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String? id;
  final String name;
  final DocumentReference tripRef;
  final DateTime creationDate;
  final String comment;
  final double rating;

  Review(this.id, this.name, this.tripRef, this.creationDate, this.comment, this.rating);

  factory Review.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Review(snapshot.id,
        data?['name'],
        data?['tripRef'],
        data?['creationDate'].toDate(),
        data?['comment'],
        data?['rating']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "tripRef": tripRef,
      "creationDate": creationDate,
      "comment": comment,
      "rating": rating
    };
  }

  String get avatarImg {
    return '';
  }
}
