import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/appUser.dart';
import 'package:dm/Guide/tripsList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Login&ExtraDesign/notification.dart';
import '../Providers/userProvider.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';
import '../Domain/trip.dart';
import '../Utils/dark_lightmode.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool showButton = false;
  Timer? timer;
  late List<Trip>? todayTrips;

  @override
  void initState() {
    getdarkmodepreviousstate();
    startMonitoring();
    super.initState();
  }

  void startMonitoring() {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (todayTrips != null) {
        for (var t in todayTrips!) {
          if (t.allowShowStart() && t.showStartButton == false) {
            setState(() {
              t.showStartButton = true;
            });
          }
          if (t.allowShowEnd() && t.showEndButton == false) {
            setState(() {
              t.showEndButton = true;
            });
          }
        }
      }
    });
  }

  late UserProvider userProvider;
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final today = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final lastWeek = DateTime(now.year, now.month, now.day - 7, 0, 0, 0);
    final nextWeek = DateTime(now.year, now.month, now.day + 7, 0, 0, 0);
    final lastMonth = DateTime(now.year, now.month, now.day - 30, 0, 0, 0);
    final nextMonth = DateTime(now.year, now.month, now.day + 30, 0, 0, 0);

    final tripsCollection = FirebaseFirestore.instance.collection("trips");
    final notificationsCollection = FirebaseFirestore.instance.collection("notifications");
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final Stream<QuerySnapshot<Map<String, dynamic>>> queryFinishedTrips =
    tripsCollection
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", whereIn: ["booked", 'started', 'finished'])
        .where("date", isGreaterThan:  lastMonth)
        .orderBy("date")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> queryBookedTrips =
    tripsCollection
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "booked")
        .where("date", isLessThan:  nextMonth)
        .where("date", isGreaterThan:  today)
        .orderBy("date")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> queryCurrentTrips =
    tripsCollection
        .where("guideRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "started")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> queryPendingTrips =
    tripsCollection
        .where("date", isGreaterThan:  today)
        .where("status", isEqualTo: "pending")
        .snapshots();

    final Stream<int> notificationCountStream = notificationsCollection
        .where("userRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "new")
        .snapshots()
        .map((snapshot) => snapshot.size);

    return SafeArea(
        child: Scaffold(
          backgroundColor: notifier.getblackwhitecolor,
          body: Padding(
            padding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 8),
            child: SingleChildScrollView(
              child:
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: userDocRef.snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("Document does not exist");
                    }
                    Map<String, dynamic>?  guide = snapshot.data!.data();
                    return Column(
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
                                            "${AppLocalizations.of(context)!.hello}, ${userProvider.user!.name}! 👋",
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
                                            stream: queryPendingTrips,
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                                if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                                                  List<DocumentSnapshot<Map<String, dynamic>>> pendingTripsSnap = snapshot.data!.docs;
                                                  var pendingTrips = pendingTripsSnap.map<Trip>((d) => Trip.fromFirestore(d, null)).toList();
                                                  return InkWell(
                                                    onTap: () {
                                                      Navigator.of(context).push(MaterialPageRoute(
                                                          builder: (context) => TripsList(title:"Pending Tours", trips:pendingTrips)));
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
                                            StreamBuilder<int>(
                                            stream: notificationCountStream,
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) return const CircularProgressIndicator();
                                              int count = snapshot.data ?? 0; // Ensure count is not null

                                              return InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (
                                                                context) => const notification()));
                                                  },
                                                  child: Badge.count(
                                                      count: count,
                                                      isLabelVisible: count > 0,
                                                      child: CircleAvatar(
                                                          backgroundColor: notifier
                                                              .getdarkmodecolor,
                                                          child: Image.asset(
                                                            "assets/images/notification.png",
                                                            height: 25,
                                                            color: notifier
                                                                .getwhiteblackcolor,
                                                          ))));
                                            })
                                        ],
                                      )
                                    ],
                                  ),
                                  if (!guide!["accountValidated"])
                                    ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            color: notifier.getlogobgcolor),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Text(
                                              "Your account is not active."
                                              "\nYou will not receive new tours."
                                              "\nPlease check your account details.",
                                              softWrap: true,
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: WhiteColor,
                                                  fontFamily: "Gilroy Medium"))
                                          ),
                                        ),
                                    ],
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
                                    stream: queryFinishedTrips,
                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                        if(!snapshot.hasData) {
                                          return Center(child: CircularProgressIndicator(color: WhiteColor));
                                        }

                                        List<DocumentSnapshot<Map<String, dynamic>>> finishedTripsSnap = snapshot.data!.docs;
                                        List<Trip> finishedTripsThisMonth = finishedTripsSnap.map<Trip>((d) => Trip.fromFirestore(d, null)).toList();;
                                        List<Trip> finishedTripsToday = finishedTripsThisMonth.where((d) => d.date.compareTo(today) > 0).toList();
                                        List<Trip> finishedTripsThisWeek = finishedTripsThisMonth.where((d) => d.date.compareTo(lastWeek) > 0).toList();

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
                                                    dashboardValue(title: "Today", trips:finishedTripsToday),
                                                    dashboardValue(title: "Last 7 days", trips:finishedTripsThisWeek),
                                                    dashboardValue(title: "Last 30 days", trips:finishedTripsThisMonth),
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
                                  stream: queryBookedTrips,
                                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                    if(!snapshot.hasData) {
                                      return Center(child: CircularProgressIndicator(color: WhiteColor));
                                    }

                                    List<DocumentSnapshot<Map<String, dynamic>>> bookedTripsSnap = snapshot.data!.docs;

                                    List<Trip> bookedTripsThisMonth = bookedTripsSnap.map<Trip>((d) => Trip.fromFirestore(d, null)).toList();
                                    List<Trip> bookedTripsToday = bookedTripsThisMonth.where((d) => d.date.compareTo(tomorrow) < 0).toList();
                                    List<Trip> bookedTripsThisWeek = bookedTripsThisMonth.where((d) => d.date.compareTo(nextWeek) < 0).toList();

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
                                                  dashboardValue(title: "Today", trips:bookedTripsToday),
                                                  dashboardValue(title: "Next 7 days", trips:bookedTripsThisWeek),
                                                  dashboardValue(title: "Next 30 days", trips:bookedTripsThisMonth),
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
                                  stream: queryCurrentTrips,
                                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                    if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: guideTripLayout(
                                            context, notifier,  Trip.fromFirestore(snapshot.data!.docs[0], null), true),
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
                                    stream: queryBookedTrips,
                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot)
                                    {
                                      List<DocumentSnapshot<Map<String, dynamic>>> todayTripsSnap = snapshot.data != null
                                          ? snapshot.data!.docs.where((d) => d['date'].toDate().compareTo(tomorrow) < 0).toList()
                                          : [];
                                      todayTrips = todayTripsSnap.map<Trip>((t) =>  Trip.fromFirestore(t, null)).toList();
                                      return SizedBox(
                                        child: ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemCount: todayTrips?.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return guideTripLayout(context, notifier, todayTrips![index], true);
                                          },
                                        ),
                                      );
                                    })
                                  ]
                            );
                })
            )
          )
      )
    );
  }

  dashboardValue({title, trips}) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TripsList(title: title, trips: trips)));
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Medium"),
            ),
            const SizedBox(height: 1),
            Text(
              trips.length.toString(),
              style: TextStyle(
                  fontSize: 18,
                  color: LogoColor,
                  fontFamily: "Gilroy Bold"),
            )
          ],
        )
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
