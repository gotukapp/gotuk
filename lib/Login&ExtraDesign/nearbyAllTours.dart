// ignore_for_file: file_names

import 'package:dm/Utils/customwidget.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/tour.dart';

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

  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "Nearby Tuk Tuk for you",
              ActionIcon: null,
              bgcolor: notifier.getblackwhitecolor,
              actioniconcolor: notifier.getwhiteblackcolor,
              leadingiconcolor: notifier.getwhiteblackcolor,
              titlecolor: notifier.getwhiteblackcolor)),
      backgroundColor: notifier.getblackwhitecolor,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: SizedBox(
                child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: Tour.availableTours.length,
              itemBuilder: (BuildContext context, int index) {
                return tourLayout(context, notifier, Tour.availableTours[index]);
              },
            )),
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
}
