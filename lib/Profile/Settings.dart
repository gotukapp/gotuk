// ignore_for_file: file_names

import 'package:dm/CreatAccount/login.dart';
import 'package:dm/Profile/Language.dart';
import 'package:dm/Profile/MyProfile.dart';
import 'package:dm/Profile/NotificationSetting.dart';
import 'package:dm/Profile/support.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/customwidget .dart';

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  bool switchValue = false;
  late ColorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getbgcolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          "Settings",
          style: TextStyle(color: notifier.getwhiteblackcolor),
        ),
      ),
      backgroundColor: notifier.getbgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Account Settings",
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              AccountSetting(
                image: "assets/images/profile.png",
                text: "My Profile",
                icon: Icons.keyboard_arrow_right,
                onclick: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MyProfile()));
                },
                boxcolor: notifier.getdarkmodecolor,
                ImageColor: notifier.getwhiteblackcolor,
                iconcolor: notifier.getwhiteblackcolor,
                TextColor: notifier.getwhiteblackcolor,
              ),
              AccountSetting(
                image: "assets/images/notification.png",
                text: "Notifications",
                icon: Icons.keyboard_arrow_right,
                onclick: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const NotificationSetting()));
                },
                boxcolor: notifier.getdarkmodecolor,
                ImageColor: notifier.getwhiteblackcolor,
                iconcolor: notifier.getwhiteblackcolor,
                TextColor: notifier.getwhiteblackcolor,
              ),
              AccountSetting(
                  image: "assets/images/Payments.png",
                  text: "Payments and Payouts",
                  icon: Icons.keyboard_arrow_right,
                  onclick: () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => Favourite()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  ImageColor: notifier.getwhiteblackcolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  TextColor: notifier.getwhiteblackcolor),
              const SizedBox(height: 10),
              Text("Preferences",
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              AccountSetting(
                  image: "assets/images/Langauge.png",
                  text: "Language",
                  icon: Icons.keyboard_arrow_right,
                  onclick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Language()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  ImageColor: notifier.getwhiteblackcolor,
                  TextColor: notifier.getwhiteblackcolor),
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: notifier.getdarkmodecolor,
                  ),
                  child:
                    ListTile(
                      leading: Image.asset(
                        "assets/images/moon.png",
                        height: 30,
                        color: notifier.getwhiteblackcolor,
                      ),
                      title: Text("Dark Mode",
                          style: TextStyle(
                              fontSize: 15,
                              color: notifier.getwhiteblackcolor,
                              fontFamily: "Gilroy Bold")),
                      trailing: CupertinoSwitch(
                        thumbColor: notifier.getdarkwhitecolor,
                        trackColor: notifier.getbuttoncolor,
                        activeColor: notifier.getdarkbluecolor,
                        value: switchValue,
                        onChanged: (value) async {
                          setState(() {
                            switchValue = value;
                          });
                          final prefs =
                          await SharedPreferences.getInstance();
                          setState(() {
                            notifier.setIsDark = value;
                            prefs.setBool("setIsDark", value);
                          });
                        },
                      )
                    )
              ),

              AccountSetting(
                  image: "assets/images/lock.png",
                  text: "Privacy Settings",
                  icon: Icons.keyboard_arrow_right,
                  onclick: () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => Favourite()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  ImageColor: notifier.getwhiteblackcolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  TextColor: notifier.getwhiteblackcolor),
              AccountSetting(
                  image: "assets/images/logout.png",
                  text: "Log Out",
                  icon: null,
                  onclick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const loginscreen()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  ImageColor: RedColor,
                  TextColor: RedColor),
              const SizedBox(height: 10),
              Text("Support",
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              AccountSetting(
                  image: "assets/images/support.png",
                  text: "Support",
                  icon: Icons.keyboard_arrow_right,
                  onclick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Support()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  ImageColor: notifier.getwhiteblackcolor,
                  TextColor: notifier.getwhiteblackcolor),
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
      switchValue = false;
    } else {
      notifier.setIsDark = previusstate;
      switchValue = true;
    }
  }
}
