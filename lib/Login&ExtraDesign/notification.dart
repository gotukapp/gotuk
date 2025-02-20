// ignore_for_file: camel_case_types, unnecessary_import, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Login&ExtraDesign/tripDetail.dart';
import 'package:dm/Profile/NotificationSetting.dart';
import 'package:dm/Profile/Settings.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/appUser.dart';
import '../Domain/trip.dart';
import '../Message/chatting.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}

class _notificationState extends State<notification> {
  bool guideMode = false;

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();
  }

  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final Stream<QuerySnapshot<Map<String, dynamic>>> notifications = FirebaseFirestore.instance
        .collection('notifications')
        .where("userRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "new")
        .orderBy("timestamp", descending: true).snapshots();

    return Scaffold(
      backgroundColor: notifier.getblackwhitecolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: StreamBuilder(
        stream: notifications,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: WhiteColor));
          }
          var notificationList =  snapshot.data!.docs;
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Recent",
                          style: TextStyle(
                              fontSize: 16,
                              color: notifier.getwhiteblackcolor,
                              fontFamily: "Gilroy Bold"),
                        ),
                        // CircleAvatar(
                        //   radius: 10,
                        //   backgroundColor: RedColor,
                        //   child: Text(
                        //     "4",
                        //     style: TextStyle(fontSize: 13),
                        //   ),
                        // )
                      ],
                    ),
                    InkWell(
                        onTap: () {
                          clearAllNotifications();
                        },
                        child: Text(
                          "Clear All",
                          style: TextStyle(
                              color: notifier.getwhitelogocolor,
                              fontFamily: "Gilroy Bold"),
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: notificationList.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentReference<Map<String, dynamic>> tripRef = notificationList[index]["tripRef"];
                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: tripRef.get(), // Fetch the document
                      builder: (context, snapshot) {
                        String content = notificationList[index]["content"];
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator()); // Show loading indicator
                        }
                        Trip? t;
                        if (snapshot.hasData && snapshot.data!.exists && notificationList[index]["type"] != "message") {
                          t = Trip.fromFirestore(snapshot.data!, null);
                          content = "${t.reservationId!} - ${DateFormat("yyyy-MM-dd HH:mm").format(t.date)}";
                        }

                        return InkWell(
                            onTap: () async {
                              if (notificationList[index]["type"] == 'message') {
                                DocumentSnapshot<Map<String, dynamic>> tripSnapshot = await notificationList[index]["tripRef"].get();
                                Trip trip = Trip.fromFirestore(tripSnapshot, null);
                                DocumentSnapshot<AppUser>? snapshot;
                                if (guideMode) {
                                  final convertedDocRef = trip.guideRef!.withConverter<AppUser>(
                                    fromFirestore: AppUser.fromFirestore,
                                    toFirestore: (AppUser user, _) => user.toFirestore(),
                                  );
                                  snapshot = await convertedDocRef.get();
                                } else {
                                  final convertedDocRef = trip.guideRef!.withConverter<AppUser>(
                                    fromFirestore: AppUser.fromFirestore,
                                    toFirestore: (AppUser user, _) => user.toFirestore(),
                                  );
                                  snapshot = await convertedDocRef.get();
                                }
                                AppUser appUser = snapshot.data()!;
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Chatting(trip: trip, sendTo: appUser)));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => TripDetail(notificationList[index]["tripRef"].id)));
                              }
                              await FirebaseFirestore.instance
                                  .collection('notifications')
                                  .doc(notificationList[index].id)
                                  .update({"status": "read"});
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    if (t == null)
                                      CircleAvatar(
                                        backgroundColor: WhiteColor,
                                        backgroundImage:
                                        const AssetImage("assets/images/avatar.png"),
                                        radius: 25,
                                      )
                                    else
                                      CircleAvatar(
                                        backgroundColor: WhiteColor,
                                        backgroundImage: AssetImage(t.tour.mainImage),
                                        radius: 25,
                                      ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width *
                                                    0.60,
                                                child: Text(
                                                  getTitleByType(notificationList[index]["type"]),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: "Gilroy Bold",
                                                    color: notifier.getwhiteblackcolor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      DateFormat('yyyy-MM-dd').format(notificationList[index]["timestamp"].toDate()),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: notifier.getgreycolor,
                                                          fontFamily: "Gilroy Medium")),
                                                  Text(
                                                      DateFormat('HH:mm').format(notificationList[index]["timestamp"].toDate()),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: notifier.getgreycolor,
                                                          fontFamily: "Gilroy Medium"))
                                                ])
                                          ],
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context).size.height *
                                                0.007),
                                        SizedBox(
                                          height: 40,
                                          width: MediaQuery.of(context).size.width * 0.70,
                                          child: Text(
                                            content,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: darkGrey,
                                                fontFamily: "Gilroy Medium"),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: greyColor,
                                )
                              ],
                            )
                        );
                      });
                    },
                ),
              ),
            ],
          );
        })
      ),
      appBar: AppBar(
        leading: BackButton(
          color: notifier.getwhiteblackcolor,
        ),
        elevation: 0,
        backgroundColor: notifier.getblackwhitecolor,
        title: Text(
          "Notification",
          style: TextStyle(
              fontSize: 20,
              color: notifier.getwhiteblackcolor,
              fontFamily: "Gilroy Bold"),
        ),
        centerTitle: true,
      ),
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

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
  }

  String getTitleByType(String type) {
    if (type.startsWith("message")) {
      return 'Chat Message';
    }

    if (type.startsWith("trip booked")) {
      return 'New Tour Booked';
    }

    if (type.startsWith("trip started")) {
      return 'Tour Started';
    }

    if (type.startsWith("trip finished")) {
      return 'Tour Finished';
    }

    return '';
  }

  Future<void> clearAllNotifications() async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where("userRef", isEqualTo: userDocRef)
        .where("status", isEqualTo: "new")
        .get();

    if (snapshot.docs.isEmpty) return;

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {"status": "read"});
    }
    await batch.commit();
  }
}
