import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/trips.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';
import '../Domain/slot.dart';

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
    items = generateItems();
  }

  late ColorNotifier notifier;
  late List<TimetableItem<Slot>> items;

  @override
  Widget build(BuildContext context) {
    final controller = TimetableController(
      start: DateUtils.dateOnly(DateTime.now()),
      initialColumns: 4,
      cellHeight: 100.0,
      startHour: 8,
      endHour: 21,
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final db = FirebaseFirestore.instance.collection("trips");
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    final Stream<QuerySnapshot<Map<String, dynamic>>> bookedTrips =
    db
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "booked")
        .where("date", isGreaterThan:  today)
        .orderBy("date")
        .snapshots();

    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: bookedTrips,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            for (var item in snapshot.data!.docs) {
              Trip trip = Trip.fromFirestore(item, null);
              items.add(TimetableItem(
                  trip.date,
                  trip.date.add(const Duration(minutes: 120)),
                  data: Slot(2, trip.tour)
              ));
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
                              onTap: () {
                                setState(() {
                                  if (item.data!.status == 1) {
                                    item.data!.status = 0;
                                  } else if (item.data!.status == 0) {
                                    item.data!.status = 1;
                                  }
                                });
                              },
                              child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5), color: item.data!.status == 0 ? Colors.green :
                                  (item.data!.status == 1 ? Colors.red : Colors.grey) ),
                                  child: Center(
                                      child: Text(item.data!.status == 2 ? item.data!.tour!.name : "Slot",
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
            return const Text("Loading...");
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

  /// Generates some random items for the timetable.
  List<TimetableItem<Slot>> generateItems() {
    final items = <TimetableItem<Slot>>[];
    final today = DateUtils.dateOnly(DateTime.now());
    for (int i = 0; i < 30; i++) {
      for (int h = 8; h < 22; h++) {
        final date = today.add(Duration(hours: (i * 24) + h));
        items.add(TimetableItem(
          date,
          date.add(const Duration(minutes: 30)),
          data: Slot(i == 1 ? 1 : 0, null),
        ));
        items.add(TimetableItem(
          date.add(const Duration(minutes: 30)),
          date.add(const Duration(minutes: 60)),
          data: Slot(i == 1 ? 1 : 0, null),
        ));
      }
    }
    return items;
  }

}
