// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:dm/Profile/Favourite.dart';
import 'package:dm/Profile/MyCupon.dart';
import 'package:dm/Profile/Settings.dart';
import 'package:dm/Profile/tripsHistory.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Guide/account.dart';
import '../Guide/timetable.dart';
import '../Providers/userProvider.dart';
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

  late ColorNotifier notifier;
  late UserProvider userProvider;
  late bool guideMode = false;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context);

    ImageProvider imageProvider;
    if (userProvider.user!.profilePhoto != null) {
      imageProvider =  NetworkImage(userProvider.user!.profilePhoto!);
    } else {
      imageProvider = const AssetImage("assets/images/avatar.png");
    }

    return SafeArea(
      child: Scaffold(
          backgroundColor: notifier.getblackwhitecolor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.profile,
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
                              backgroundColor: notifier.getdarkmodecolor,
                              child: Image.asset(
                                "assets/images/setting.png",
                                height: 25,
                                color: notifier.getwhiteblackcolor,
                              ))),
                    ],
                  ),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: notifier.getwhiteblackcolor,
                          backgroundImage: imageProvider,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${userProvider.user!.name}",
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
                              color: notifier.getwhiteblackcolor,
                              fontFamily: "Gilroy Medium"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.options,
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
                          if (!guideMode)
                            ProfileSetting(
                              image: "assets/images/heart.png",
                              text: AppLocalizations.of(context)!.favorites,
                              icon: Icons.keyboard_arrow_right,
                              onclick: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const Favourite()));
                              },
                              boxcolor: notifier.getdarklightgreycolor,
                              iconcolor: notifier.getwhiteblackcolor,
                              ImageColor: notifier.getwhiteblackcolor,
                              TextColor: notifier.getwhiteblackcolor)
                          else
                            const SizedBox(width: 15)
                          ,
                          ProfileSetting(
                              image: "assets/images/clock.png",
                              text: guideMode ? AppLocalizations.of(context)!.calendar : AppLocalizations.of(context)!.history,
                              icon: Icons.keyboard_arrow_right,
                              onclick: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => guideMode ? const TimeTable()
                                    : const TripsHistory()));
                              },
                              boxcolor: notifier.getdarklightgreycolor,
                              iconcolor: notifier.getwhiteblackcolor,
                              ImageColor: notifier.getwhiteblackcolor,
                              TextColor: notifier.getwhiteblackcolor),
                          if (guideMode)
                            ...[
                              ProfileSetting(
                                image: "assets/images/profile.png",
                                text: AppLocalizations.of(context)!.account,
                                icon: Icons.keyboard_arrow_right,
                                onclick: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const account()
                                  ));
                                },
                                boxcolor: notifier.getdarkmodecolor,
                                iconcolor: notifier.getwhiteblackcolor,
                                ImageColor: notifier.getwhiteblackcolor,
                                TextColor: notifier.getwhiteblackcolor),
                              const SizedBox(width: 15)
                            ]
                          else
                            ProfileSetting(
                                image: "assets/images/discount.png",
                                text: AppLocalizations.of(context)!.promotions,
                                icon: Icons.keyboard_arrow_right,
                                onclick: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const MyCupon()));
                                },
                                boxcolor: notifier.getdarkmodecolor,
                                iconcolor: notifier.getwhiteblackcolor,
                                ImageColor: notifier.getwhiteblackcolor,
                                TextColor: notifier.getwhiteblackcolor)
                        ],
                      )
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
              color: notifier.getwhiteblackcolor,
              fontFamily: "Gilroy Medium"),
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

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
  }
}
