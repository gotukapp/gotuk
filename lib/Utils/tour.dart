Tour tour1 = Tour(1,
    "Lisboa Old City",
    "1h30 - 2h",
    "assets/images/tour1_img1.jpg",
    ["assets/images/tour1_img1.jpg","assets/images/tour1_img2.jpg","assets/images/tour1_img3.jpg","assets/images/tour1_img4.jpg"],
    115, 148,
    "Sé de Lisboa",
    "assets/images/tour1_img1.jpg",
    4.5,
    coords);
Tour tour2 = Tour(2, "Lisboa New City", "1h30",
    "assets/images/tour2_img1.jpg",
    ["assets/images/tour2_img1.jpg","assets/images/tour2_img2.jpg","assets/images/tour2_img3.jpg","assets/images/tour2_img4.jpg"],
    110, 135,
    "Terreiro do Paço (Praça do Comércio)",
    "assets/images/tour2_img1.jpg", 4.9, coords);
Tour tour3 = Tour(3, "Discoveries in Belém", "1h30 - 2h30",
    "assets/images/tour3_img1.jpg",
    ["assets/images/tour3_img1.jpg","assets/images/tour3_img2.jpg","assets/images/tour3_img3.jpg","assets/images/tour3_img4.jpg"],
    140, 180,
    "Mosteiro dos Jerónimos",
    "assets/images/tour3_img1.jpg", 4.6, coords);
Tour tour4 = Tour(4, "Cristo Rei",
    "1h30 - 2h30",
    "assets/images/tour4_img1.jpg",
    ["assets/images/tour4_img1.jpg"],
    95, 135,
    "Lisboa", "assets/images/tour4_img1.jpg", 4.6, coords);
Tour tour5 = Tour(5,
    "Three sight hills",
    "1h30 - 2h",
    "assets/images/tour5_img1.jpg",
    ["assets/images/tour5_img1.jpg", "assets/images/tour5_img2.jpg","assets/images/tour5_img3.jpg"],
    105, 152,
    "Parque Eduardo VII, Lisboa", "assets/images/tour5_img1.jpg", 4.7, coords);

List<Tour> tourList = [tour1, tour2, tour3, tour4, tour5];

List nearbyTours = [tour1, tour2, tour3];

List coords = [
  { "lat": 38.709819267469186, "lng": -9.1334956851527 },
  { "lat": 38.71001676449845, "lng": -9.133251628323917 },
  { "lat": 38.71012166974997, "lng": -9.132333529328239 },
  { "lat": 38.71047206982465, "lng": -9.131378071353815 },
  { "lat": 38.71082247044223, "lng": -9.130785677203113 },
  { "lat": 38.7111206891137, "lng": -9.130604128655715 },
  { "lat": 38.71150092353972, "lng": -9.13063277866213 },
  { "lat": 38.7121122730012, "lng": -9.13028878280889 },
  { "lat": 38.71249997162712, "lng": -9.130680514915747 },
  { "lat": 38.71287272883077, "lng": -9.130604136206674 },
  { "lat": 38.714162501741846, "lng": -9.130737908050396 },
  { "lat": 38.71441597726351, "lng": -9.130737911482017 },
  { "lat": 38.7157355366964, "lng": -9.131272967389068 },
  { "lat": 38.71616793251591, "lng": -9.130298382827744 },
  { "lat": 38.71653468498173, "lng": -9.130405003629262 },
  { "lat": 38.71758560872218, "lng": -9.129968876773967 },
  { "lat": 38.71701010654198, "lng": -9.129744384490664 },
  { "lat": 38.71712520844492, "lng": -9.129455761521758 },
  { "lat": 38.71687499004811, "lng": -9.129250517272634 },
  { "lat": 38.71676489357391, "lng": -9.1288400317106 },
  { "lat": 38.716859967617395, "lng": -9.127614986546519 },
  { "lat": 38.717100162530485, "lng": -9.126678553858373 },
  { "lat": 38.71588410614303, "lng": -9.125299594062426 },
  { "lat": 38.71567474750314, "lng": -9.124849167920724 },
  { "lat": 38.71566234975945, "lng": -9.123994221953959 },
  { "lat": 38.715407793095196, "lng": -9.124391871770806 },
  { "lat": 38.71514157932682, "lng": -9.124213198053193 },
  { "lat": 38.715407793095196, "lng": -9.124391871770806 },
  { "lat": 38.71566234975945, "lng": -9.123994221953959 },
  { "lat": 38.71567474750314, "lng": -9.124849167920724 },
  { "lat": 38.71588410614303, "lng": -9.125299594062426 },
  { "lat": 38.71515181170776, "lng": -9.126823132803011 },
  { "lat": 38.71502747481562, "lng": -9.127493899623877 },
  { "lat": 38.71489925495034, "lng": -9.128691239101295 },
  { "lat": 38.71753964948332, "lng": -9.129961095553188 },
  { "lat": 38.718201253569994, "lng": -9.129903706773066 },
  { "lat": 38.71866868323235, "lng": -9.12995877451932 },
  { "lat": 38.71934111602567, "lng": -9.129788633101636 },
  { "lat": 38.71954922137797, "lng": -9.13124132281699 },
  { "lat": 38.71903925877353, "lng": -9.132621313067748 },
  { "lat": 38.71869835844864, "lng": -9.132234207400337 },
  { "lat": 38.71829206082632, "lng": -9.131172119411726 },
  { "lat": 38.717927654943395, "lng": -9.13128570474182 },
  { "lat": 38.7178486610928, "lng": -9.13145282617575 },
  { "lat": 38.71789737587759, "lng": -9.131718874836245 },
  { "lat": 38.71818539878499, "lng": -9.131935388514364 },
  { "lat": 38.71813061935423, "lng": -9.132429043687578 },
  { "lat": 38.71764501077241, "lng": -9.133375728462068 },
  { "lat": 38.717776754377056, "lng": -9.1335869081548 },
  { "lat": 38.717672977274205, "lng": -9.134734671384473 },
  { "lat": 38.718035582046035, "lng": -9.1349831640865 },
  { "lat": 38.71979175694778, "lng": -9.134997484122174 },
  { "lat": 38.71977973949802, "lng": -9.135556874536732 },
  { "lat": 38.71728341207228, "lng": -9.1358803201965 },
  { "lat": 38.71684057674867, "lng": -9.136348988608464 },
  { "lat": 38.71523568759334, "lng": -9.137126871316493 },
  { "lat": 38.714991476373186, "lng": -9.136322281210266 },
  { "lat": 38.716831654325944, "lng": -9.135511918955046 }
];


class Tour {
  final int id;
  final String title;
  final String duration;
  final String img;
  final List<String> images;
  final double priceLow;
  final double priceHigh;
  final String address;
  final String icon;
  final double review;
  final List coords;


  Tour(this.id, this.title, this.duration, this.img, this.images, this.priceLow,
      this.priceHigh, this.address, this.icon, this.review, this.coords);

  Tour.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        title = json['title'] as String,
        duration = json['duration'] as String,
        img = json['img'] as String,
        images = json['images'] as List<String>,
        priceLow = json['priceLow'] as double,
        priceHigh = json['priceHigh'] as double,
        address = json['address'] as String,
        icon = json['icon'] as String,
        review = json['review'] as double,
        coords = json['coords'] as List;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'title': title,
        'duration': duration,
        'img': img,
        'images': images,
        'priceLow': priceLow,
        'priceHigh': priceHigh,
        'address': address,
        'icon': icon,
        'review': review,
        'coords': coords
      };

  double getTourPrice(bool smallPriceSelected) {
    return getTotalPrice(smallPriceSelected) - getFeePrice(smallPriceSelected);
  }

  double getFeePrice(bool smallPriceSelected) {
    return double.parse((getTotalPrice(smallPriceSelected) * 0.15).toStringAsFixed(0));
  }

  double getTotalPrice(bool smallPriceSelected) {
    return smallPriceSelected ? priceLow : priceHigh;
  }
}
