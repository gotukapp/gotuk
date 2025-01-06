import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dm/Domain/appUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/trip.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';
import '../Domain/slot.dart';
import '../Providers/userProvider.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
    slots = generateItems();
  }

  late ColorNotifier notifier;
  late UserProvider userProvider;
  late Map<DateTime,List<Slot>> slots;
  List<TimetableItem<Slot>> items = [];

  @override
  Widget build(BuildContext context) {
    final controller = TimetableController(
      start: DateUtils.dateOnly(DateTime.now()),
      initialColumns: 4,
      cellHeight: 100.0,
      startHour: 9,
      endHour: 20,
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final db = FirebaseFirestore.instance.collection("trips");
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final Stream<QuerySnapshot<Map<String, dynamic>>> guideTrips =
    db
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", whereIn: ["booked", 'started', 'finished'])
        .where("date", isGreaterThan:  today)
        .orderBy("date")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> unavailability = userDocRef
        .collection("unavailability")
        .where("date", isGreaterThanOrEqualTo: today)
        .snapshots();

    items.clear();

    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: guideTrips,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshotTrips) {
          if (snapshotTrips.hasData) {
            for (var item in snapshotTrips.data!.docs) {
              Trip trip = Trip.fromFirestore(item, null);
              final date = DateUtils.dateOnly(trip.date);
              DateTime tripDate = DateTime(
                  trip.date.year,
                  trip.date.month,
                  trip.date.day,
                  trip.date.hour,
                  trip.date.minute,
                  0, 0, 0 );

              try {
                final slotIndex = slots[date]!.indexOf(slots[date]!.firstWhere((s) => s.start == tripDate));
                final slot =  slots[date]?[slotIndex];
                if (slot?.status != 2) {
                  slots[date]?.removeRange(slotIndex,
                      ((slotIndex + trip.tour.durationSlots) > slots[date]!.length
                          ? slots[date]!.length
                          : slotIndex + trip.tour.durationSlots));
                  slots[date]?.insert(slotIndex,
                      Slot(tripDate, tripDate.add(Duration(minutes: 30 * (trip.tour.durationSlots-1))), 2, trip));
                }
              }
              on Exception catch (_, e) {
              }
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: unavailability,
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    for (var item in snapshot.data!.docs) {
                      final date = DateUtils.dateOnly(item.get("date").toDate());
                      List<dynamic> unavailabilitySlots = item.get("slots").toList();
                      for(String time in unavailabilitySlots) {
                        if (slots.containsKey(date)) {
                          int hours = int.parse(time.split(":")[0]);
                          int minutes = int.parse(time.split(":")[1]);
                          DateTime slotStart = date.add(Duration(hours: hours, minutes: minutes));
                          final slot = slots[date]!.firstWhereOrNull((s) => s.start == slotStart);
                          if (slot != null && slot.status != tripStatus) {
                            slot.status = unavailableStatus;
                          }
                        }
                      }
                    }

                    for(List<Slot> daySlots in slots.values) {
                      for(Slot slot in daySlots) {
                        items.add(TimetableItem(slot.start, slot.end, data:slot));
                      }
                    }
                    return SafeArea(
                      child: Scaffold(
                          appBar: PreferredSize(
                              preferredSize: const Size.fromHeight(75),
                              child: CustomAppbar(
                                  centertext: "Calendar",
                                  ActionIcon: null,
                                  bgcolor: notifier.getbgcolor,
                                  actioniconcolor: notifier.getwhiteblackcolor,
                                  leadingiconcolor: notifier.getwhiteblackcolor,
                                  titlecolor: notifier.getwhiteblackcolor)),
                          backgroundColor: notifier.getblackwhitecolor,
                          body: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            child: Timetable<Slot>(
                              controller: controller,
                              items: items,
                              cellBuilder: (datetime) => Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: LogoColor, width: 0.2),
                                ),
                              ),
                              cornerBuilder: (datetime) => Container(
                                color: LogoColor,
                                child: Center(child: Text("${datetime.year}", style: TextStyle(color: WhiteColor, fontFamily: "Gilroy Bold"),)),
                              ),
                              headerCellBuilder: (datetime) {
                                final color = BlackColor;
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: color, width: 2)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat("E\nMMM d").format(datetime),
                                      style: TextStyle(
                                        color: LogoColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                              hourLabelBuilder: (time) {
                                final isCurrentHour = time.hour == DateTime.now().hour;
                                return Text(
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                                  ),
                                );
                              },
                              itemBuilder: (item) => Padding(
                                padding: const EdgeInsets.all(5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(220),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      if (item.data!.status != tripStatus) {
                                        await AppUser.updateUnavailability(item.start, item.data!.status == availableStatus ? unavailableStatus : availableStatus);
                                        setState(() {
                                          item.data!.status == availableStatus ? unavailableStatus : availableStatus;
                                        });
                                      }
                                    },
                                    child: Container(
                                        height: double.infinity,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5), color: item.data!.status == availableStatus ? Colors.green :
                                        (item.data!.status == unavailableStatus ? Colors.red : Colors.grey) ),
                                        child: Center(
                                            child: Text(item.data!.status == tripStatus ? item.data!.trip!.tour.name : "Slot",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: BlackColor,
                                                    fontFamily: "Gilroy Bold")))),
                                  ),
                                ),
                              ),
                              nowIndicatorColor: Colors.red,
                              snapToDay: true,
                            ),
                          )
                      )
                  );
                  } else {
                    return Text("Loading...",
                        style: TextStyle(
                            fontSize: 10,
                            color: BlackColor,
                            fontFamily: "Gilroy Bold"));
                  }
                });
          } else {
            return Text("Loading...",
                style: TextStyle(
                    fontSize: 10,
                    color: BlackColor,
                    fontFamily: "Gilroy Bold"));
          }
        }
    );
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previusstate;
    }
  }

  Map<DateTime,List<Slot>> generateItems() {
    final items = <DateTime,List<Slot>>{};
    final today = DateUtils.dateOnly(DateTime.now());
    for (int i = 0; i < 30; i++) {
      List<Slot> slots = [];
      final current = today.add(Duration(hours: (i * 24)));
      for (int h = 8; h < 22; h++) {
        final date = current.add(Duration(hours: h));
        slots.add(Slot(date, date.add(const Duration(minutes: 30)),date.isAfter(DateTime.now()) ? 0 : -1, null));
        slots.add(Slot(date.add(const Duration(minutes: 30)),
            date.add(const Duration(minutes: 60)),
            date.isAfter(DateTime.now()) ? 0 : -1, null));
      }
      items[current] = slots;
    }
    return items;
  }

}
