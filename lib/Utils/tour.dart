Tour tour1 = Tour(1, "Lisboa Old City", "1h30 - 2h", "assets/images/selisboa.jpg", 115, 148, "Sé de Lisboa", "assets/images/old.png", 4.5);
Tour tour2 = Tour(2, "Lisboa New City", "1h30", "assets/images/comercio.jpg", 110, 135,"Terreiro do Paço (Praça do Comércio)", "assets/images/new_city.png", 4.9);
Tour tour3 = Tour(3, "Discoveries in Belém", "1h30 - 2h30", "assets/images/lisboa.jpg", 140, 180, "Mosteiro dos Jerónimos", "assets/images/belem.png", 4.6);
Tour tour4 = Tour(4, "Cristo Rei", "1h30 - 2h30", "assets/images/cristorei.jpg", 95, 135, "Lisboa", "assets/images/cristo_rei.png", 4.6);
Tour tour5 = Tour(5, "Three sight hills", "1h30 - 2h", "assets/images/colinas.jpg", 105, 152, "Parque Eduardo VII, Lisboa", "", 4.7);

List tourList = [tour1, tour2, tour3, tour4, tour5];

List nearbyTours = [tour1, tour2, tour3];


class Tour {
  final int id;
  final String title;
  final String duration;
  final String img;
  final double priceLow;
  final double priceHigh;
  final String address;
  final String icon;
  final double review;


  Tour(this.id, this.title, this.duration, this.img, this.priceLow,
      this.priceHigh, this.address, this.icon, this.review);

  Tour.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        title = json['title'] as String,
        duration = json['duration'] as String,
        img = json['img'] as String,
        priceLow = json['priceLow'] as double,
        priceHigh = json['priceHigh'] as double,
        address = json['address'] as String,
        icon = json['icon'] as String,
        review = json['review'] as double;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'title': title,
        'duration': duration,
        'img': img,
        'priceLow': priceLow,
        'priceHigh': priceHigh,
        'address': address,
        'icon': icon,
        'review': review
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
