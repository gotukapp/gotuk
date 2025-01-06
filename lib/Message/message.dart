// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Message/ShowMassage.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/appUser.dart';
import '../Domain/trip.dart';
import 'chatting.dart';

class message extends StatefulWidget {
  const message({super.key});

  @override
  State<message> createState() => _messageState();
}

class _messageState extends State<message> {
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

    final db = FirebaseFirestore.instance.collection("chat");
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    print(userDocRef);

    final Stream<QuerySnapshot<Map<String, dynamic>>> chats =
    db
        .where(guideMode ? "guideRef" : "clientRef", isEqualTo: userDocRef)
        .where("hasMessages", isEqualTo: true)
        .orderBy("date", descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Message",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.getwhiteblackcolor,
                      fontFamily: "Gilroy bold"),
                ),
                CircleAvatar(
                    radius: 22,
                    backgroundColor: notifier.getdarkmodecolor,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ShowMassage()));
                      },
                      child: Image.asset(
                        "assets/images/notification.png",
                        height: 25,
                        color: notifier.getwhiteblackcolor,
                      ),
                    ))
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: chats,
                      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> chatSnapshot)
                      {
                        if (!chatSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return SizedBox(
                            child:
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: chatSnapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                for(var doc in chatSnapshot.data!.docs) {
                                  DocumentReference user = doc.get(guideMode ? "clientRef" : "guideRef");
                                  final convertedDocRef = user.withConverter<AppUser>(
                                    fromFirestore: AppUser.fromFirestore,
                                    toFirestore: (AppUser user, _) => user.toFirestore(),
                                  );
                                  return StreamBuilder<DocumentSnapshot<AppUser>>(
                                    stream: convertedDocRef.snapshots(),
                                    builder: (context, userSnapshot) {
                                      if (!userSnapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      AppUser user = userSnapshot.data!.data()!;
                                      final messages = db.doc(doc.id)
                                          .collection('messages')
                                          .orderBy('date', descending: true)
                                          .limit(1);

                                      return StreamBuilder<QuerySnapshot>(
                                        stream: messages.snapshots(),
                                        builder: (context, messageSnapshot) {
                                          if (!messageSnapshot.hasData) {
                                            return const CircularProgressIndicator();
                                          }

                                          var messageData = messageSnapshot.data!.docs[0];

                                          return InkWell(
                                              onTap: () async {
                                                final convertedDocRef =  FirebaseFirestore.instance.collection("trips")
                                                    .doc(doc.id)
                                                    .withConverter<Trip>(
                                                  fromFirestore: Trip.fromFirestore,
                                                  toFirestore: (Trip trip, _) => trip.toFirestore(),
                                                );
                                                DocumentSnapshot<Trip> tripSnapshot = await convertedDocRef.get();
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                    builder: (context) => Chatting(trip: tripSnapshot.data()!, sendTo: user)));
                                              },
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: WhiteColor,
                                                  backgroundImage: const AssetImage(
                                                      'assets/images/avatar.png'),
                                                ),
                                                contentPadding: const EdgeInsets.only(
                                                    left: 0, right: 0),
                                                title: Text(
                                                  user.name!,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: notifier.getwhiteblackcolor,
                                                      fontFamily: "Gilroy Bold"),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  messageData["text"],
                                                  style: TextStyle(
                                                      color: notifier.getgreycolor,
                                                      fontFamily: "Gilroy Medium"),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                trailing: Column(
                                                  children: [
                                                    SizedBox(
                                                        height: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            0.03),
                                                    Text(
                                                      DateFormat('HH:mm').format(messageData["date"].toDate()),
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                          notifier.getwhiteblackcolor,
                                                          fontFamily: "Gilroy Medium"),
                                                    ),
                                                    SizedBox(
                                                        height: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            0.01)
                                                  ],
                                                ),
                                                isThreeLine: false,
                                              ));
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            )
                        );
                      }
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
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
