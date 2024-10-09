// ignore_for_file: file_names

import 'package:dm/Profile/NotificationSetting.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowMassage extends StatefulWidget {
  const ShowMassage({super.key});

  @override
  State<ShowMassage> createState() => _ShowMassageState();
}

class _ShowMassageState extends State<ShowMassage> {
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
      backgroundColor: notifier.getbgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Messages",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.getwhiteblackcolor,
                      fontFamily: "Gilroy Bold"),
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const NotificationSetting()));
                    },
                    child: CircleAvatar(
                        radius: 22,
                        backgroundColor: notifier.getdarkmodecolor,
                        child: Image.asset(
                          "assets/images/setting.png",
                          height: 25,
                          color: notifier.getwhiteblackcolor,
                        )))
              ],
            ),
            const SizedBox(height: 20),
            Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                    color: notifier.getdarkmodecolor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search a tour',
                      hintStyle: TextStyle(
                          color: notifier.getgreycolor,
                          fontFamily: "Gilroy Medium"),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.asset(
                          "assets/images/search.png",
                          height: 25,
                          color: notifier.getgreycolor,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                )),
            const SizedBox(height: 60),
            Image.asset(
              'assets/images/BookingSuccessfull.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              "No Messages Here",
              style: TextStyle(
                  fontSize: 18,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              "Let’s start messaging with others or with seller",
              style: TextStyle(
                  fontSize: 14,
                  color: notifier.getgreycolor,
                  fontFamily: "Gilroy Medium"),
            ),
          ],
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
