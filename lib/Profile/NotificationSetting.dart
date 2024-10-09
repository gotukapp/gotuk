// ignore_for_file: file_names, non_constant_identifier_names

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  bool status1 = true;
  bool status2 = false;
  bool status3 = true;
  bool switchValue = false;
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getdarkscolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          "Notification Settings",
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getdarkscolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            NotificationSetting(
              title: "Newesletter",
              subtitle: "Alerts for the most important stories",
              status: status1,
              toggel: (bool? value) {
                setState(() {
                  status1 = value!;
                });
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            NotificationSetting(
              title: "Recommendation",
              subtitle: "Get info newest promotion",
              status: status2,
              toggel: (bool? value1) {
                setState(() {
                  status2 = value1!;
                });
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            NotificationSetting(
              title: "Invoice and Payment",
              subtitle: "Information about your payment",
              status: status3,
              toggel: (bool? value2) {
                setState(() {
                  status3 = value2!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  NotificationSetting({title, subtitle, status, toggel}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontFamily: "Gilroy Bold"),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 14,
                      color: greyColor,
                      fontFamily: "Gilroy Medium"),
                ),
              ],
            ),
            // ignore: sized_box_for_whitespace
            Container(
              height: 41.0,
              width: 60.0,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSwitch(
                      value: status,
                      thumbColor: notifier.getdarkwhitecolor,
                      trackColor: notifier.getbuttoncolor,
                      activeColor: notifier.getdarkbluecolor,
                      onChanged: toggel),
                ),
              ),
            ),
          ],
        ),
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
}
