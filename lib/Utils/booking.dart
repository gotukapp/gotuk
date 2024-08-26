import 'package:dm/Utils/tour.dart';

List bookings = [
  Booking(tourList[0], DateTime(2024,8,1,13,0,0), 6, 0),
  Booking(tourList[1], DateTime(2024,8,10,10,30,0), 6, 1),
  Booking(tourList[3], DateTime(2024,8,4,18,30,0), 6, 2),
  Booking(tourList[2], DateTime(2024,8,5,11,30,0), 6, 2),
  Booking(tourList[0], DateTime(2024,8,2,14,0,0), 3, 2)
];

Booking currentBook = Booking(tourList[0], DateTime(2024,7,29,10,0,0), 6, 1);

List driverBookings = [
  Booking(tourList[0], DateTime(2024,7,29,13,0,0), 6, 1),
  Booking(tourList[1], DateTime(2024,7,29,15,30,0), 6, 1),
  Booking(tourList[3], DateTime(2024,7,29,18,30,0), 6, 1)
];

class Booking {

  final DateTime date;
  final int persons;
  final Tour tour;
  final int status;

  Booking(this.tour, this.date, this.persons, this.status);

  double get price {
    if (persons < 4) {
      return tour.getTourPrice(true);
    }

    return tour.getTourPrice(false);
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
