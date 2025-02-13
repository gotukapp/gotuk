import 'package:cloud_firestore/cloud_firestore.dart';

List coords = [
  { "lat": 38.709819267469186, "lng": -9.1334956851527, "course": 50 },
  { "lat": 38.709829, "lng": -9.133445, "course": 30 },
  { "lat": 38.709884, "lng": -9.133400, "course": 30 },
  { "lat": 38.709932, "lng": -9.133363, "course": 30 },
  { "lat": 38.709987, "lng": -9.133312, "course": 30 },
  { "lat": 38.71001676449845, "lng": -9.133251628323917, "course": 80 },
{ "lat": 38.71003841396122, "lng": -9.133152825418737, "course": 80 },
{ "lat": 38.710063527581276, "lng": -9.132939798124234, "course": 85 },
{ "lat": 38.71008180973361, "lng": -9.132747826073564, "course": 85 },
{ "lat": 38.71010163729936, "lng": -9.13253881197139, "course": 85 },
{ "lat": 38.71011326613459, "lng": -9.132391179107497, "course": 85 },
  { "lat": 38.71012166974997, "lng": -9.132333529328239, "course": 60 },
  { "lat": 38.71047206982465, "lng": -9.131378071353815, "course": 60 },
  { "lat": 38.71082247044223, "lng": -9.130785677203113, "course": 30 },
  { "lat": 38.7111206891137, "lng": -9.130604128655715, "course": 30 },
  { "lat": 38.71150092353972, "lng": -9.13063277866213, "course": 0 },
  { "lat": 38.7121122730012, "lng": -9.13028878280889, "course": 30 },
  { "lat": 38.71249997162712, "lng": -9.130680514915747, "course": 0 },
  { "lat": 38.71287272883077, "lng": -9.130604136206674, "course": 20 },
  { "lat": 38.714162501741846, "lng": -9.130737908050396, "course": 20 },
  { "lat": 38.71441597726351, "lng": -9.130737911482017, "course": 0 },
  { "lat": 38.7157355366964, "lng": -9.131272967389068, "course": 0 },
  { "lat": 38.71616793251591, "lng": -9.130298382827744, "course": 50 },
  { "lat": 38.71653468498173, "lng": -9.130405003629262, "course": 0 },
  { "lat": 38.71758560872218, "lng": -9.129968876773967, "course": 0 },
  { "lat": 38.71701010654198, "lng": -9.129744384490664, "course": 0 },
  { "lat": 38.71712520844492, "lng": -9.129455761521758, "course": 50 },
  { "lat": 38.71687499004811, "lng": -9.129250517272634, "course": 50 },
  { "lat": 38.71676489357391, "lng": -9.1288400317106, "course": 200 },
  { "lat": 38.716859967617395, "lng": -9.127614986546519, "course": 200 },
  { "lat": 38.717100162530485, "lng": -9.126678553858373, "course": 200 },
  { "lat": 38.71588410614303, "lng": -9.125299594062426, "course": 200 },
  { "lat": 38.71567474750314, "lng": -9.124849167920724, "course": 200 },
  { "lat": 38.71566234975945, "lng": -9.123994221953959, "course": 200 },
  { "lat": 38.715407793095196, "lng": -9.124391871770806, "course": 200 },
  { "lat": 38.71514157932682, "lng": -9.124213198053193, "course": 0 },
  { "lat": 38.715407793095196, "lng": -9.124391871770806, "course": 0 },
  { "lat": 38.71566234975945, "lng": -9.123994221953959, "course": 0 },
  { "lat": 38.71567474750314, "lng": -9.124849167920724, "course": 0 },
  { "lat": 38.71588410614303, "lng": -9.125299594062426, "course": 0 },
  { "lat": 38.71515181170776, "lng": -9.126823132803011, "course": 0 },
  { "lat": 38.71502747481562, "lng": -9.127493899623877, "course": 0 },
  { "lat": 38.71489925495034, "lng": -9.128691239101295, "course": 0 },
  { "lat": 38.71753964948332, "lng": -9.129961095553188, "course": 0 },
  { "lat": 38.718201253569994, "lng": -9.129903706773066, "course": 0 },
  { "lat": 38.71866868323235, "lng": -9.12995877451932, "course": 0 },
  { "lat": 38.71934111602567, "lng": -9.129788633101636, "course": 0 },
  { "lat": 38.71954922137797, "lng": -9.13124132281699, "course": 0 },
  { "lat": 38.71903925877353, "lng": -9.132621313067748, "course": 0 },
  { "lat": 38.71869835844864, "lng": -9.132234207400337, "course": 0 },
  { "lat": 38.71829206082632, "lng": -9.131172119411726, "course": 0 },
  { "lat": 38.717927654943395, "lng": -9.13128570474182, "course": 0 },
  { "lat": 38.7178486610928, "lng": -9.13145282617575, "course": 0 },
  { "lat": 38.71789737587759, "lng": -9.131718874836245, "course": 0 },
  { "lat": 38.71818539878499, "lng": -9.131935388514364, "course": 0 },
  { "lat": 38.71813061935423, "lng": -9.132429043687578, "course": 0 },
  { "lat": 38.71764501077241, "lng": -9.133375728462068, "course": 0 },
  { "lat": 38.717776754377056, "lng": -9.1335869081548, "course": 0 },
  { "lat": 38.717672977274205, "lng": -9.134734671384473, "course": 0 },
  { "lat": 38.718035582046035, "lng": -9.1349831640865, "course": 0 },
  { "lat": 38.71979175694778, "lng": -9.134997484122174, "course": 0 },
  { "lat": 38.71977973949802, "lng": -9.135556874536732, "course": 0 },
  { "lat": 38.71728341207228, "lng": -9.1358803201965, "course": -90 },
  { "lat": 38.71684057674867, "lng": -9.136348988608464, "course": -90 },
  { "lat": 38.71523568759334, "lng": -9.137126871316493, "course": 0 },
  { "lat": 38.714991476373186, "lng": -9.136322281210266, "course": 0 },
  { "lat": 38.716831654325944, "lng": -9.135511918955046, "course": 0 }
];

List starPoints = [
  { "index": 0, "name": "Sé", "img": "assets/images/tour1_img4.jpg" },
  { "index":17, "name": "Portas do Sol", "img": "assets/images/tour1_img3.jpg" },
  { "index":35, "name": "Panteão Nacional", "img": "assets/images/tour1_img2.jpg" },
  { "index":42, "name": "São Vicente", "img": "assets/images/tour1_img1.jpg" },
  { "index":48, "name": "Miradouro da Senhora do Monte", "img": "assets/images/tour1_img1.jpg" },
  { "index":66, "name": "Mouraria", "img": "assets/images/tour1_img1.jpg" }
];

List starPoints2 = [
  { "index": 0, "name": "Praça do Comércio", "img": "assets/images/tour1_img4.jpg" },
  { "index":17, "name": "Chiado Garrett", "img": "assets/images/tour1_img3.jpg" },
  { "index":35, "name": "Largo do Carmo", "img": "assets/images/tour1_img2.jpg" },
  { "index":42, "name": "Bairro Alto", "img": "assets/images/tour1_img1.jpg" },
  { "index":48, "name": "Elevador de Santa Justa", "img": "assets/images/tour1_img1.jpg" },
  { "index":66, "name": "São Pedro de Alcântara", "img": "assets/images/tour1_img1.jpg" },
  { "index":66, "name": "Parlamento São Bento", "img": "assets/images/tour1_img1.jpg" }
];

List starPoints3 = [
  { "index": 0, "name": "Mosteiro dos Jerónimos", "img": "assets/images/tour1_img4.jpg" },
  { "index":17, "name": "Museu dos Descobrimentos", "img": "assets/images/tour1_img3.jpg" },
  { "index":35, "name": "Torre de Belém", "img": "assets/images/tour1_img2.jpg" }
];

List starPoints4 = [
  { "index": 0, "name": "Lisboa", "img": "assets/images/tour1_img4.jpg" },
  { "index":17, "name": "Cristo Rei", "img": "assets/images/tour1_img3.jpg" }
];

List starPoints5 = [
  { "index": 0, "name": "Senhora do Monte", "img": "assets/images/tour1_img4.jpg" },
  { "index":17, "name": "Parque Eduardo Sétimo", "img": "assets/images/tour1_img3.jpg" },
  { "index":35, "name": "São Pedro de Alcântara", "img": "assets/images/tour1_img2.jpg" }
];

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
  final List? coords;
  final List? starPoints;
  final List<String> pickupPoints;
  bool? favorite;

  static List<Tour> availableTours = [];
  static List<Tour> allTours = [];

  Tour(this.id, this.isActive, this.name, this.duration, this.durationDescription, this.durationSlots, this.mainImage, this.images, this.lowPrice,
      this.highPrice, this.pickupPoint, this.rating, this.coords, this.starPoints, this.pickupPoints);

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
        data?['rating'],
        data?['coords'],
        data?['starPoints'],
        (data?['pickupPoints'] as List<dynamic>).cast<String>()
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
      'coords': coords,
      'starPoints': starPoints,
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
}
