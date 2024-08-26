// ignore_for_file: file_names

import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/tour.dart';

class nearbyAllTours extends StatefulWidget {
  const nearbyAllTours({super.key});

  @override
  State<nearbyAllTours> createState() => _nearbyAllToursState();
}

class _nearbyAllToursState extends State<nearbyAllTours> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifire notifire;
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "Nearby Tuk Tuk for you",
              ActionIcon: null,
              bgcolor: notifire.getblackwhitecolor,
              actioniconcolor: notifire.getwhiteblackcolor,
              leadingiconcolor: notifire.getwhiteblackcolor,
              titlecolor: notifire.getwhiteblackcolor)),
      backgroundColor: notifire.getblackwhitecolor,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: SizedBox(
                child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: nearbyTours.length,
              itemBuilder: (BuildContext context, int index) {
                return tourListInfo(context, notifire, nearbyTours[index]);
              },
            )),
      )
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
}
