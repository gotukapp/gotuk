List tourList = [
  Tour(1, "Lisboa Old City", "1h30 - 2h", "assets/images/eco-tuk-tours.jpg", 115, 148, "Sé de Lisboa"),
  Tour(2, "Lisboa New City", "1h30", "", 110, 135,"Terreiro do Paço (Praça do Comércio)"),
  Tour(3, "Discoveries in Belém", "1h30 - 2h30", "", 140, 180, "Mosteiro dos Jerónimos"),
  Tour(4, "Cristo Rei", "1h30 - 2h30", "", 95, 135, "Lisboa"),
  Tour(5, "Three sight hills", "1h30 - 2h", "", 105, 152, "Parque Eduardo VII, Lisboa")
];

class Tour {
  final int id;
  final String title;
  final String duration;
  final String img;
  final int priceLow;
  final int priceHigh;
  final String address;

  Tour(this.id, this.title, this.duration, this.img, this.priceLow, this.priceHigh, this.address);

  Tour.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        title = json['title'] as String,
        duration = json['duration'] as String,
        img = json['img'] as String,
        priceLow = json['priceLow'] as int,
        priceHigh = json['priceHigh'] as int,
        address = json['address'] as String;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'title': title,
        'duration': duration,
        'img': img,
        'priceLow': priceLow,
        'priceHigh': priceHigh,
        'address': address,
      };
}

