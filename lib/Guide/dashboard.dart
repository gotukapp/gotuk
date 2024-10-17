import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/appUser.dart';
import 'package:dm/Guide/tripsPending.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Login&ExtraDesign/notification.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';
import '../Domain/trips.dart';
import '../Utils/dark_lightmode.dart';

class Dashboard extends StatefulWidget {
  final AppUser guide;
  const Dashboard({super.key, required this.guide});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final today = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final lastWeek = DateTime(now.year, now.month, now.day - 7, 0, 0, 0);
    final nextWeek = DateTime(now.year, now.month, now.day + 7, 0, 0, 0);
    final lastMonth = DateTime(now.year, now.month, now.day - 30, 0, 0, 0);
    final nextMonth = DateTime(now.year, now.month, now.day + 30, 0, 0, 0);

    final db = FirebaseFirestore.instance.collection("trips");
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final Stream<QuerySnapshot<Map<String, dynamic>>> finishedTrips =
    db
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "finished")
        .where("date", isGreaterThan:  lastMonth)
        .orderBy("date")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> bookedTrips =
    db
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "booked")
        .where("date", isLessThan:  nextMonth)
        .where("date", isGreaterThan:  today)
        .orderBy("date")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> currentTrips =
    db
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "started")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> pendingTrips =
    db
        .where("date", isGreaterThan:  today)
        .where("status", isEqualTo: "pending")
        .snapshots();

    return SafeArea(
        child: Scaffold(
            backgroundColor: notifier.getblackwhitecolor,
            body: Padding(
              padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 8),
              child: SingleChildScrollView(
                child:
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.01),
                              Text(
                                "Hello, ${FirebaseAuth.instance.currentUser?.displayName}! 👋",
                                style: TextStyle(
                                    color: notifier.getwhiteblackcolor,
                                    fontSize: 16,
                                    fontFamily: "Gilroy Medium"),
                              ),
                              SizedBox(
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.0001),
                              Text(
                                "Good tours with GoTuk",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: LogoColor,
                                    fontFamily: "Gilroy Bold"),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: pendingTrips,
                                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                    if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => const TripsPending()));
                                        },
                                        child: CircleAvatar(
                                            backgroundColor: notifier.getdarkmodecolor,
                                            child: Image.asset(
                                              "assets/images/newTripCalendar.png",
                                              height: 25,
                                              color: LogoColor,
                                            ))
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  }
                                ),
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => const notification()));
                                  },
                                  child: CircleAvatar(
                                      backgroundColor: notifier.getdarkmodecolor,
                                      child: Image.asset(
                                        "assets/images/notification.png",
                                        height: 25,
                                        color: notifier.getwhiteblackcolor,
                                      )))
                            ],
                          )
                        ],
                      ),
                      if (!widget.guide.accountValidated)
                        ...[
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.15),
                          Text(
                              "Your account is not active",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: BlackColor,
                                  fontFamily: "Gilroy Medium"))
                        ]
                      else
                        ...[
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.025),
                          Text(
                            "Completed Tours",
                            style: TextStyle(
                                fontSize: 14,
                                color: LogoColor,
                                fontFamily: "Gilroy Medium"),
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.001),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: finishedTrips,
                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                int finishedTripsToday = 0;
                                int finishedTripsThisWeek = 0;
                                int finishedTripsThisMonth = 0;
                                if(snapshot.hasData) {
                                  finishedTripsToday = snapshot.data!.docs.where((d) => d['date'].toDate().compareTo(today) > 0).length;
                                  finishedTripsThisWeek = snapshot.data!.docs.where((d) => d['date'].toDate().compareTo(lastWeek) > 0).length;
                                  finishedTripsThisMonth = snapshot.data!.docs.length;
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: notifier.getdarklightgreycolor),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment .spaceBetween,
                                          children: [
                                          Row(
                                          mainAxisAlignment: MainAxisAlignment .spaceBetween,
                                          children: [
                                            Transaction(text1: finishedTripsToday.toString(), text2: "Today"),
                                            Transaction(text1: finishedTripsThisWeek.toString(), text2: "Last 7 days"),
                                            Transaction(text1: finishedTripsThisMonth.toString(), text2: "Last 30 days"),
                                          ],
                                        ),
                                    ]
                                  ),
                                ),
                              );
                            }
                          )
                          ,
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.025),
                          Text(
                            "Next Tours",
                            style: TextStyle(
                                fontSize: 14,
                                color: LogoColor,
                                fontFamily: "Gilroy Medium"),
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.001),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: bookedTrips,
                          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                            int bookedTripsToday = 0;
                            int bookedTripsThisWeek = 0;
                            int bookedTripsThisMonth = 0;
                            if(snapshot.hasData) {
                              bookedTripsToday = snapshot.data!.docs.where((d) => d['date'].toDate().compareTo(tomorrow) < 0).length;
                              bookedTripsThisWeek = snapshot.data!.docs.where((d) => d['date'].toDate().compareTo(nextWeek) < 0).length;
                              bookedTripsThisMonth = snapshot.data!.docs.length;
                            }
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: notifier.getdarklightgreycolor),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Transaction(text1: bookedTripsToday.toString(), text2: "Today"),
                                          Transaction(text1: bookedTripsThisWeek.toString(), text2: "Next 7 days"),
                                          Transaction(text1: bookedTripsThisMonth.toString(), text2: "Next 30 days"),
                                        ],
                                      ),
                                    ]
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 30),
                          Text("Current Tour",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: LogoColor,
                                  fontFamily: "Gilroy Bold")),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: currentTrips,
                          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                            if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6),
                                child: guideTripLayout(
                                    context, notifier,  Trip.fromFirestore(snapshot.data!.docs[0], null)),
                              );
                            }
                            return const SizedBox();
                          }),
                          const SizedBox(height: 30),
                          Text("Today Tours",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: LogoColor,
                                  fontFamily: "Gilroy Bold")),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: bookedTrips,
                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot)
                            {
                              List<DocumentSnapshot<Map<String, dynamic>>> todayTrips = snapshot.data != null
                                  ? snapshot.data!.docs.where((d) => d['date'].toDate().compareTo(tomorrow) < 0).toList()
                                  : [];
                              return SizedBox(
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: todayTrips.length,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return guideTripLayout(context, notifier,
                                        Trip.fromFirestore(todayTrips[index], null));
                                  },
                                ),
                              );
                            })
                        ]
                    ]
                ),
              )
            )
    ));
  }

  Transaction({text1, text2}) {
    return Column(
      children: [
        Text(
          text2,
          style: TextStyle(
              fontSize: 14,
              color: notifier.getwhiteblackcolor,
              fontFamily: "Gilroy Medium"),
        ),
        const SizedBox(height: 1),
        Text(
          text1,
          style: TextStyle(
              fontSize: 18,
              color: LogoColor,
              fontFamily: "Gilroy Bold"),
        )
      ],
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

  getTrips(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {

  }
}
