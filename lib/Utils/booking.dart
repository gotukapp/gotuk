import 'package:dm/Utils/tour.dart';

List bookings = [
  Booking(tourList[0], DateTime(2024,7,20,13,0,0), 4, 0),
  Booking(tourList[1], DateTime(2024,7,19,10,30,0), 4, 1),
  Booking(tourList[3], DateTime(2024,4,9,18,30,0), 4, 2),
  Booking(tourList[2], DateTime(2024,5,16,11,30,0), 6, 2),
  Booking(tourList[0], DateTime(2024,5,28,14,0,0), 2, 2)
];

class Booking {

  final DateTime date;
  final int persons;
  final Tour tour;
  final int status;

  Booking(this.tour, this.date, this.persons, this.status);

  double get price {
    if (persons < 4) {
      return tour.priceLow;
    }

    return tour.priceHigh;
  }

  static List get pendingBookings {
    return bookings.where((b) => b.status == 0).toList();
  }

  static List get waitingBookings {
    return bookings.where((b) => b.status == 1).toList();
  }

  static List get finishBookings {
    return bookings.where((b) => b.status == 2).toList();
  }
}
