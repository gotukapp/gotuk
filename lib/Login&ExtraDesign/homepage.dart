// import 'package:dm/hoteldetailage.dart';
// ignore_for_file: unused_field, library_private_types_in_public_api, camel_case_types

import 'package:dm/Profile/profile.dart';
import 'package:dm/Search/Search.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import '../Driver/dashboard.dart';
import '../Message/message.dart';

int selectedIndex = 0;

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  late int _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;
  late bool isDriver = false;

  final _pageOption = [
    const home(),
    const message(),
    const profile(),
  ];

  final _driverPageOption = [
    const dashboard(),
    const message(),
    const profile(),
  ];
  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();
  }

  late ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
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
      body: isDriver ? _driverPageOption[selectedIndex] : _pageOption[selectedIndex],
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
