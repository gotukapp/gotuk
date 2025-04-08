// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Login&ExtraDesign/nearbyAllTours.dart';
import 'package:dm/Login&ExtraDesign/showAllTours.dart';
import 'package:dm/Login&ExtraDesign/tripsBooked.dart';
import 'package:dm/Providers/userProvider.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:dm/Domain/tour.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Domain/trip.dart';
import '../Utils/customwidget .dart';
import 'checkout.dart';
import 'tourDetail.dart';
import 'notification.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  List<Trip> bookedTrips = [];
  StreamSubscription<QuerySnapshot<Object?>>? listener;

  @override
  void initState() {
    getdarkmodepreviousstate();
    Firebase.initializeApp().whenComplete(() {
      final db = FirebaseFirestore.instance.collection("trips");
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid);

      final Query<Map<String, dynamic>> pendingTrips =
      db
          .where("clientRef", isEqualTo: userDocRef)
          .where("status", whereIn: ["pending", "booked", 'started'])
          .orderBy("date");

      pendingTrips.get().then( (querySnapshot) {
          if (!mounted) return;
          setState(() {
            bookedTrips.clear();
            for (var docSnapshot in querySnapshot.docs) {
              bookedTrips.add(Trip.fromFirestore(docSnapshot, null));
            }
          });
      });

      listener = pendingTrips.snapshots().listen((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          setState(() {
            try {
              Trip? trip = bookedTrips.firstWhere((t) => t.id == doc.id);
              trip.status = doc.get("status");
            } catch (e) {
              bookedTrips.add(Trip.fromFirestore(doc, null));
            }
          });
        }
      });
    });
    super.initState();
  }

  late UserProvider userProvider;
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final Stream<int> notificationCountStream = FirebaseFirestore.instance
        .collection('notifications')
        .where("userRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "new")
        .snapshots()
        .map((snapshot) => snapshot.size);

    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: notifier.getblackwhitecolor,
        body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01),
                          Text(
                            "${AppLocalizations.of(context)!.hello}, ${userProvider.user!.name}! 👋",
                            style: TextStyle(
                                color: notifier.getwhiteblackcolor,
                                fontSize: 16,
                                fontFamily: "Gilroy Medium"),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.0001),
                          Text(
                            AppLocalizations.of(context)!.letsFindTour,
                            style: TextStyle(
                                fontSize: 16,
                                color: LogoColor,
                                fontFamily: "Gilroy Bold"),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (bookedTrips.isNotEmpty)
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const TripsBooked()));
                              },
                              child: CircleAvatar(
                                  backgroundColor: notifier.getdarkmodecolor,
                                  child: Image.asset(
                                    "assets/images/newTripCalendar.png",
                                    height: 25,
                                    color: LogoColor,
                                  ))
                          ),
                          StreamBuilder<int>(
                              stream: notificationCountStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const CircularProgressIndicator();
                                int count = snapshot.data ?? 0; // Ensure count is not null
                                return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => const notification()));
                                    },
                                    child: Badge.count(
                                        count: count,
                                        isLabelVisible: count > 0,
                                        child: CircleAvatar(
                                        backgroundColor: notifier.getdarkmodecolor,
                                        child: Image.asset(
                                          "assets/images/notification.png",
                                          height: 25,
                                          color: notifier.getwhiteblackcolor,
                                        )))
                                );
                          })]
                      )
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: 190,
                            decoration: BoxDecoration(
                                border: Border.all(color: LogoColor),
                                borderRadius: BorderRadius.circular(50),
                                color: WhiteColor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset(
                                  "assets/images/location.png",
                                  height: 24,
                                  color: LogoColor,
                                ),
                                Text(
                                  "Lisboa, PT",
                                  style: TextStyle(
                                      color: BlackColor,
                                      fontFamily: "Gilroy Medium"),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: LogoColor,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03),
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (context) => checkout(tourId: Tour.availableTours[0].id, goNow: true)));
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50), color: LogoColor),
                              child: Center(
                                child: Text(
                                  "Go Now",
                                  style: TextStyle(
                                      color: WhiteColor,
                                      fontSize: 18,
                                      fontFamily: "Gilroy Bold"),
                                ),
                              ),
                            ),
                          ),
                          if (bookedTrips.isNotEmpty)
                            ...[SizedBox( height: MediaQuery.of(context).size.height * 0.025),
                                Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.bookedTours,
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      color: notifier.getwhiteblackcolor),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const TripsBooked(),
                                    ));
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.seeAll,
                                    style: TextStyle(
                                        color: notifier.getdarkbluecolor,
                                        fontFamily: "Gilroy Medium"),
                                  ),
                                ),
                              ],
                            ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.018),
                              // const SizedBox(height: 10),
                              SizedBox(
                                  height: 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: bookedTrips.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: clientTripLayout(context, notifier, bookedTrips[index])
                                      );
                                    },
                                  )),],
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.025),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.recommended,
                                style: TextStyle(
                                    fontFamily: "Gilroy Bold",
                                    color: notifier.getwhiteblackcolor),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const showAllTours(),
                                  ));
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.seeAll,
                                  style: TextStyle(
                                      color: notifier.getdarkbluecolor,
                                      fontFamily: "Gilroy Medium"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.018),
                          // const SizedBox(height: 10),
                          SizedBox(
                              height: 240,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: Tour.availableTours.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) =>
                                                  TourDetail(Tour.availableTours[index].id)));
                                        },
                                        child: Stack(
                                            children: [
                                              Positioned(
                                                width: 240,
                                                height: 150,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.asset(
                                                    Tour.availableTours[index].mainImage,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                left: 185,
                                                child: tourReview(review: Tour.availableTours[index].rating),
                                              ),
                                              Container(
                                                  height: 240,
                                                  alignment: const Alignment(-1, -1),
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(height: 130),
                                                      Container(
                                                        width: 240,
                                                        height: 90,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(12),
                                                            color: notifier.getdarklightgreycolor),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 10, vertical: 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                Tour.availableTours[index].name.toUpperCase(),
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: "Gilroy Bold",
                                                                    color:
                                                                    notifier.getwhiteblackcolor),
                                                              ),
                                                              SizedBox(
                                                                  height: MediaQuery.of(context)
                                                                      .size
                                                                      .height *
                                                                      0.0005),
                                                              Text(
                                                                Tour.availableTours[index].pickupPoint,
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: notifier.getwhiteblackcolor,
                                                                    fontFamily: "Gilroy Medium",
                                                                    overflow: TextOverflow.ellipsis),
                                                              ),
                                                              SizedBox(
                                                                  height: MediaQuery.of(context)
                                                                      .size
                                                                      .height *
                                                                      0.01),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      "${Tour.availableTours[index].lowPrice}€ - ${Tour.availableTours[index].highPrice}€",
                                                                      style: TextStyle(
                                                                          color: Darkblue,
                                                                          fontFamily:
                                                                          "Gilroy Bold")
                                                                  ),
                                                                  tourDuration(
                                                                      image: "assets/images/timer.png",
                                                                      text: Tour.availableTours[index].durationDescription,
                                                                      radi: 0)
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              )
                                              ]
                                            ),
                                      )
                                  );
                                },
                              )),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.nearbyTours,
                                style: TextStyle(
                                    fontFamily: "Gilroy Bold",
                                    color: notifier.getwhiteblackcolor),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                      const nearbyAllTours()));
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.seeAll,
                                  style: TextStyle(
                                    color: notifier.getdarkbluecolor,
                                    fontFamily: "Gilroy Medium",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: Tour.availableTours.length,
                            itemBuilder: (BuildContext context, int index) {
                              return tourLayout(context, notifier, Tour.availableTours[index]);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
    ));
  }

  tourDuration({String? image, text, double? radi}) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          image!,
          height: 20,
          color: LogoColor,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Medium"),
        )
      ],
    );
  }

  @override
  void dispose() {
    if (listener != null) {
      listener?.cancel();
    }
    super.dispose();
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
}
