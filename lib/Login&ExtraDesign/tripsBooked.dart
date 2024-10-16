// ignore_for_file: file_names

// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/trips.dart';
import '../Utils/customwidget .dart';


class TripsBooked extends StatefulWidget {
  const TripsBooked({super.key});

  @override
  State<TripsBooked> createState() => _TripsBookedState();
}

class _TripsBookedState extends State<TripsBooked> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance.collection("trips");
    final Stream<QuerySnapshot<Map<String, dynamic>>> pendingTrips =
    db
        .where("clientId", isEqualTo:  FirebaseAuth.instance.currentUser?.uid)
        .where("status", whereIn: ["pending", "booked", 'started'])
        .orderBy("date")
        .snapshots();

    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getblackwhitecolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          "My Tours",
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getblackwhitecolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: pendingTrips,
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
                          return clientTripLayout(context, notifier,
                              Trip.fromFirestore(snapshot.data!.docs[index], null));
                        },
                      ),
                    );
                  })
            ],
          ),
        ),
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
}
