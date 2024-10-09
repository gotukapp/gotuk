import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/guide.dart';
import '../Login&ExtraDesign/notification.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';
import '../Domain/trips.dart';
import '../Utils/dark_lightmode.dart';

class dashboard extends StatefulWidget {
  final Guide guide;
  const dashboard({super.key, required this.guide});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {

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
    final month = DateTime(now.year, now.month, now.day - 30, 0, 0, 0);

    final db = FirebaseFirestore.instance.collection("trips");

    final Stream<QuerySnapshot<Map<String, dynamic>>> finishedTrips =
    db
        .where("guidId", isEqualTo: widget.guide.id)
        .where("status", isEqualTo: "finished")
        .where("date", isGreaterThan:  month)
        .orderBy("date")
        .snapshots();


    final Stream<QuerySnapshot<Map<String, dynamic>>> bookedTrips =
        db
        .where("guidId", isEqualTo: widget.guide.id)
        .where("status", isEqualTo: "booked")
        .where("date", isLessThan:  tomorrow)
        .where("date", isGreaterThan:  today)
        .orderBy("date")
        .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> currentTrips =
    db
        .where("guidId", isEqualTo: widget.guide.id)
        .where("status", isEqualTo: "started")
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
                                            Transaction(text1: "2", text2: "Today"),
                                            Transaction(text1: "9", text2: "Last 7 days"),
                                            Transaction(text1: snapshot.data != null ? snapshot.data!.docs.length.toString() : "0", text2: "Last 30 days"),
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
                          Container(
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
                                        Transaction(
                                            text1: "3", text2: "Today"),
                                        Transaction(text1: "6",
                                            text2: "Next 7 days"),
                                        Transaction(text1: "10",
                                            text2: "Next 30 days"),
                                      ],
                                    ),
                                  ]
                              ),
                            ),
                          ),
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
                                child: tripInfo(
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
                              return SizedBox(
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: snapshot.data != null ? snapshot.data!.docs.length : 0,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return tripInfo(context, notifier,
                                        Trip.fromFirestore(snapshot.data!.docs[index], null));
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
