// import 'package:dm/hoteldetailage.dart';
// ignore_for_file: unused_field, library_private_types_in_public_api, camel_case_types

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Profile/profile.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:dm/Domain/trips.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Domain/appUser.dart';
import '../Domain/guide.dart';
import '../Guide/dashboard.dart';
import 'home.dart';
import '../Message/message.dart';

int selectedIndex = 0;

class homepage extends StatefulWidget {
  final AppUser user;

  const homepage({super.key, required this.user});

  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  late int _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;
  bool guideMode = false;
  StreamSubscription<QuerySnapshot<Object?>>? listener;

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();

    super.initState();
  }

  late ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    final pageOption = [
      const home(),
      const message(),
      const profile(),
    ];

    final driverPageOption = [
      dashboard(guide: widget.user as Guide),
      const message(),
      const profile(),
    ];

    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return
        // WillPopScope(
        // // onWillPop: _handleWillPop,
        // child:
        Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: notifire.getwhiteblackcolor,
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Gilroy Bold', fontWeight: FontWeight.bold),
        fixedColor: notifire.getwhiteblackcolor,
        unselectedLabelStyle: const TextStyle(fontFamily: 'Gilroy Medium'),
        currentIndex: selectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/homeicon.png",
                  color: selectedIndex == 0 ? Darkblue : greyColor,
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/message.png",
                  color: selectedIndex == 1 ? Darkblue : greyColor,
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Message'),
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/profile.png",
                color: selectedIndex == 2 ? Darkblue : greyColor,
                height: MediaQuery.of(context).size.height / 35),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {});
          selectedIndex = index;
        },
      ),
      body: guideMode ? driverPageOption[selectedIndex] : pageOption[selectedIndex],
    );
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;

    if (guideMode) {
      Guide guide = widget.user as Guide;
      if (guide.accountValidated) {
        addFirebaseTripsListen();
      }
    }
  }

  @override
  void dispose() {
    print("dispose homepage");
    if (listener != null) {
      listener?.cancel();
    }
    super.dispose();
  }

  void addFirebaseTripsListen() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
    FirebaseFirestore.instance.collection('trips').snapshots();

    bool isFirtsTime = true;
    listener = usersStream.listen((onData) {
      if (!isFirtsTime) {
        for (var change in onData.docChanges) {
          if (change.type == DocumentChangeType.added) {
            Trip t = Trip.fromFirestore(change.doc, null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 60),
                content: newTripNotification(context, notifire, t),
              ),
            );
          }
        }
      }
      isFirtsTime = false;
    });
  }
}
