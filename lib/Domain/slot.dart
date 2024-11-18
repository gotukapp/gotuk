import 'package:dm/Domain/trips.dart';

class Slot {
  DateTime start;
  DateTime end;
  final Trip? trip;
  int status;

  Slot(this.start, this.end, this.status, this.trip);
}
