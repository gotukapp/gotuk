import 'package:dm/Domain/trip.dart';

class Slot {
  DateTime start;
  DateTime end;
  final Trip? trip;
  int status;

  Slot(this.start, this.end, this.status, this.trip);
}
