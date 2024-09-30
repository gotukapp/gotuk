// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:dm/CreatAccount/login.dart';
import 'package:dm/Profile/Favourite.dart';
import 'package:dm/Profile/MyCupon.dart';
import 'package:dm/Profile/Settings.dart';
import 'package:dm/Profile/TransactionHistory.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Driver/timetable.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();
  }

  late ColorNotifire notifire;
  late bool isDriver = false;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return SafeArea(
      child: Scaffold(
          backgroundColor: notifire.getblackwhitecolor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 18,
                            color: Darkblue,
                            fontFamily: "Gilroy Bold"),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const Settings()));
                          },
                          child: CircleAvatar(
                              backgroundColor: notifire.getdarkmodecolor,
                              child: Image.asset(
                                "assets/images/setting.png",
                                height: 25,
                                color: notifire.getwhiteblackcolor,
                              ))),
                    ],
                  ),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: notifire.getwhiteblackcolor,
                          backgroundImage:
                              const AssetImage("assets/images/person.jpg"),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${FirebaseAuth.instance.currentUser?.displayName}",
                          style: TextStyle(
                              fontSize: 18,
                              color: LogoColor,
                              fontFamily: "Gilroy Bold"),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Lisboa, Portugal",
                          style: TextStyle(
                              fontSize: 16,
                              color: notifire.getwhiteblackcolor,
                              fontFamily: "Gilroy Medium"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: notifire.getdarklightgreycolor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transaction(text1: "26", text2: "Transactions"),
                          Transaction(text1: "12", text2: "Reviews"),
                          Transaction(text1: "4", text2: "Bookings"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Options",
                        style: TextStyle(
                            fontSize: 18,
                            color: Darkblue,
                            fontFamily: "Gilroy Bold"),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProfileSetting(
                              image: "assets/images/heart.png",
                              text: "Favorites",
                              icon: Icons.keyboard_arrow_right,
                              onclick: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const Favourite()));
                              },
                              boxcolor: notifire.getdarklightgreycolor,
                              iconcolor: notifire.getwhiteblackcolor,
                              ImageColor: notifire.getwhiteblackcolor,
                              TextColor: notifire.getwhiteblackcolor),
                          ProfileSetting(
                              image: "assets/images/clock.png",
                              text: isDriver ? "Calendar" : "Transactions",
                              icon: Icons.keyboard_arrow_right,
                              onclick: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => isDriver ? const timetable()
                                    : const TransactionHistory()));
                              },
                              boxcolor: notifire.getdarklightgreycolor,
                              iconcolor: notifire.getwhiteblackcolor,
                              ImageColor: notifire.getwhiteblackcolor,
                              TextColor: notifire.getwhiteblackcolor),
                          ProfileSetting(
                              image: "assets/images/discount.png",
                              text: "Promotions",
                              icon: Icons.keyboard_arrow_right,
                              onclick: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const MyCupon()));
                              },
                              boxcolor: notifire.getdarkmodecolor,
                              iconcolor: notifire.getwhiteblackcolor,
                              ImageColor: notifire.getwhiteblackcolor,
                              TextColor: notifire.getwhiteblackcolor)
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      AppButton(
                          buttontext: "LOGOUT",
                          onclick: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                builder: (context) => const loginscreen()),
                                    (route) => false);
                          }),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  Transaction({text1, text2}) {
    return Column(
      children: [
        Text(
          text1,
          style: TextStyle(
              fontSize: 18,
              color: LogoColor,
              fontFamily: "Gilroy Bold"),
        ),
        const SizedBox(height: 1),
        Text(
          text2,
          style: TextStyle(
              fontSize: 14,
              color: notifire.getwhiteblackcolor,
              fontFamily: "Gilroy Medium"),
        ),
      ],
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
    bool? previousState = prefs.getBool("setIsDriver");
    isDriver = previousState ?? false;
  }
}
