// ignore_for_file: file_names

import 'package:dm/CreatAccount/login.dart';
import 'package:dm/Profile/Language.dart';
import 'package:dm/Profile/MyProfile.dart';
import 'package:dm/Profile/NotificationSetting.dart';
import 'package:dm/Profile/privacySettings.dart';
import 'package:dm/Profile/support.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Providers/userProvider.dart';
import '../Utils/customwidget.dart';
import 'Payments.dart';

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
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getbgcolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          AppLocalizations.of(context)!.settings,
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
              Text(AppLocalizations.of(context)!.accountSettings,
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              AccountSetting(
                image: "assets/images/profile.png",
                text: AppLocalizations.of(context)!.myProfile,
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
                text: AppLocalizations.of(context)!.notifications,
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
                  text: AppLocalizations.of(context)!.payments,
                  icon: Icons.keyboard_arrow_right,
                  onclick: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Payments()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  ImageColor: notifier.getwhiteblackcolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  TextColor: notifier.getwhiteblackcolor),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.preferences,
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              AccountSetting(
                  image: "assets/images/language.png",
                  text: AppLocalizations.of(context)!.language,
                  icon: Icons.keyboard_arrow_right,
                  onclick: () async {
                    String selectedLanguage = await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Language(languages: appLanguages))) as String;
                    userProvider.user?.updateAppLanguage(selectedLanguage);
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
                      title: Text(AppLocalizations.of(context)!.darkMode,
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
                  text: AppLocalizations.of(context)!.privacySettings,
                  icon: Icons.keyboard_arrow_right,
                  onclick: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PrivacySettings()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  ImageColor: notifier.getwhiteblackcolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  TextColor: notifier.getwhiteblackcolor),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.support,
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              AccountSetting(
                  image: "assets/images/support.png",
                  text: AppLocalizations.of(context)!.support,
                  icon: Icons.keyboard_arrow_right,
                  onclick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Support()));
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  ImageColor: notifier.getwhiteblackcolor,
                  TextColor: notifier.getwhiteblackcolor),
              const SizedBox(height: 10),
              AccountSetting(
                  image: "assets/images/logout.png",
                  text: AppLocalizations.of(context)!.logOut,
                  icon: null,
                  onclick: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                        builder: (context) => const loginscreen()),
                            (route) => false);
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  ImageColor: RedColor,
                  TextColor: RedColor),
              const SizedBox(height: 10),
              AccountSetting(
                  image: "assets/images/delete.png",
                  text: AppLocalizations.of(context)!.deleteAccount,
                  icon: null,
                  onclick: () async {
                    showConfirmationMessage(context,
                        AppLocalizations.of(context)!.deleteAccount,
                        AppLocalizations.of(context)!.deleteAccountConfirmation,
                            () {}, () {}, AppLocalizations.of(context)!.yes, AppLocalizations.of(context)!.no);
                  },
                  boxcolor: notifier.getdarkmodecolor,
                  iconcolor: notifier.getwhiteblackcolor,
                  ImageColor: RedColor,
                  TextColor: RedColor)
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
