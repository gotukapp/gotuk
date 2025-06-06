// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:dm/CreatAccount/login.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:dm/Utils/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CreatAccount/createScreen.dart';
import '../Domain/appUser.dart';
import '../Login&ExtraDesign/homepage.dart';
import '../Providers/userProvider.dart';

class onbording extends StatefulWidget {
  const onbording({super.key});

  @override
  State<onbording> createState() => _onbordingState();
}

class _onbordingState extends State<onbording> {
  late bool guideMode = false;

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();

    Future.microtask(() async {
      if (FirebaseAuth.instance.currentUser != null) {
          try {
            AppUser? user = await getUserFirebaseInstance(
                guideMode, FirebaseAuth.instance.currentUser!);
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (context) => const homepage()),
                    (route) => false);
          } catch (exception, stackTrace) {
              await Sentry.captureException(
              exception,
              stackTrace: stackTrace,
              );

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const BoardingPage()));
          }
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const BoardingPage()));
        }
      },
   );
  }

  late ColorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      body: Center(
          child: Image.asset("assets/images/applogo.png",
              height: 170, width: 200)),
    );
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
  }
}

class BoardingPage extends StatefulWidget {
  const BoardingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BoardingScreenState createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingPage> {

  void initState() {
    getdarkmodepreviousstate();
    _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage);
    super.initState();
  }

  int _currentPage = 0;
  List<Slide> slides = [];
  PageController _pageController = PageController();

  // the list which contain the build slides
  List<Widget> _buildSlides() {
    return slides.map(_buildSlide).toList();
  }

  late ColorNotifier notifier;

  Widget _buildSlide(Slide slide) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      body: Column(
        children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.04),
          // ignore: sized_box_for_whitespace
          Container(
            height: MediaQuery.of(context).size.height / 2.2, //imagee size
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.fill,
              child:Image.asset(slide.image),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(),
            child: Text(
              slide.heading,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontFamily: "Gilroy Bold",
                  color: notifier.getwhiteblackcolor), //heding Text
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Padding(
            padding: const EdgeInsets.symmetric(),
            child: Text(
              slide.subtext,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: notifier.getdarkgreycolor,
                  fontFamily: "Gilroy Medium"), //subtext
            ),
          ),
        ],
      ),
    );
  }

  // handling the on page changed
  void _handlingOnPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  // building page indicator
  Widget _buildDots({
    int? index,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      for(int i=0;i<slides.length;i++)
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // borderRadius: const BorderRadius.all(
          //   Radius.circular(50),
          // ),
          // color: Color(0xFF000000),
          color: _currentPage == i ? Darkblue : greyColor,
        ),
        margin: const EdgeInsets.only(right: 8),
        curve: Curves.easeIn,
        width: _currentPage == i ? 12 : 8,
        height: _currentPage == i ? 12 : 8,
      )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (slides.isEmpty) {
      print("Add slides");
      setState(() {
        slides.add(Slide("assets/images/onboarding1.jpg",
            AppLocalizations.of(context)!.onboardingTitle_1,
            AppLocalizations.of(context)!.onboardingText_1));
        slides.add(Slide("assets/images/onboarding2.jpg",
            AppLocalizations.of(context)!.onboardingTitle_2,
            AppLocalizations.of(context)!.onboardingText_2));
        slides.add(Slide("assets/images/onboarding3.jpg",
            AppLocalizations.of(context)!.onboardingTitle_3,
            AppLocalizations.of(context)!.onboardingText_3));
      });
    }
    return Scaffold(
      backgroundColor: WhiteColor,
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            onPageChanged: _handlingOnPageChanged,
            physics: const BouncingScrollPhysics(),
            children: _buildSlides(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: <Widget>[
                _buildDots(index: _currentPage),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.06, //indicator set screen
                ),
                _currentPage == 2
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const loginpage()));
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: LogoColor,
                                  borderRadius: BorderRadius.circular(50)),
                              height: 50,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.getStarted,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: WhiteColor,
                                      fontFamily: "Gilroy Bold"),
                                ),
                              )),
                        ))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () {
                            _pageController.nextPage(
                                duration: const Duration(microseconds: 300),
                                curve: Curves.easeIn);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: LogoColor,
                                  borderRadius: BorderRadius.circular(50)),
                              height: 50,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.proceed.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: WhiteColor,
                                      fontFamily: "Gilroy Bold"),
                                ),
                              )),
                        )),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.012, //indicator set screen
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const loginpage()));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.skip.toUpperCase(),
                      style: TextStyle(
                          fontSize: 16,
                          color: Darkblue,
                          fontFamily: "Gilroy Bold"),
                    )),
                const SizedBox(height: 20)
              ],
            ),
          )
        ],
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

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    requestNotificationPermission();
    super.initState();
  }

  late ColorNotifier notifier;
  late bool guideMode = false;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                "assets/images/applogo.png",
                height: 170,
                width: 220,
              )
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              AppLocalizations.of(context)!.welcome,
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: "Gilroy Bold",
                  color: notifier.getwhiteblackcolor),
            ),
            const SizedBox(height: 10),
            Text(
                AppLocalizations.of(context)!.onboardingCreateAccount,
                style: TextStyle(
                    fontSize: 20,
                    color: notifier.getdarkgreycolor,
                    fontFamily: "Gilroy Medium"),
                textAlign: TextAlign.center),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const createScreen()));
              },
              // ignore: sort_child_properties_last
              child: Text(
                guideMode ? AppLocalizations.of(context)!.createGuideAccount.toUpperCase() : AppLocalizations.of(context)!.createAccount.toUpperCase(),
                style: TextStyle(
                    color: WhiteColor, fontSize: 16, fontFamily: "Gilroy Bold"),
              ),
              style: FilledButton.styleFrom(
                  backgroundColor: LogoColor,
                  fixedSize: const Size(400, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const loginscreen()));
              },
              // ignore: sort_child_properties_last
              child: Text(
                guideMode ? AppLocalizations.of(context)!.loginAsGuide.toUpperCase() :  AppLocalizations.of(context)!.login.toUpperCase(),
                style: TextStyle(
                    color: WhiteColor, fontSize: 16, fontFamily: "Gilroy Bold"),
              ),
              style: FilledButton.styleFrom(
                  backgroundColor: Darkblue,
                  fixedSize: const Size(400, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.065),
                    Text(AppLocalizations.of(context)!.toBeGuide,
                        style: TextStyle(
                            fontSize: 18,
                            color: notifier.getwhitelogocolor,
                            fontFamily: "Gilroy Bold")),
                  ],
                ),
                // ignore: sized_box_for_whitespace
                Container(
                  height: 60.0,
                  width: 80.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoSwitch(
                        thumbColor: notifier.getdarkwhitecolor,
                        trackColor: notifier.getbuttoncolor,
                        activeColor: notifier.getdarkbluecolor,
                        value: guideMode,
                        onChanged: (value) async {
                          setState(() {
                            guideMode = value;
                          });
                          final prefs =
                          await SharedPreferences.getInstance();
                          setState(() {
                            guideMode = value;
                            prefs.setBool("setGuideMode", value);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.doYouHaveTukTukCompany,
                style: TextStyle(
                    fontSize: 18,
                    color: notifier.getwhitelogocolor,
                    fontFamily: "Gilroy Bold")),
            InkWell(
              onTap: () {
                String url = 'https://business.gotuk.pt';
                openUrl(url, context);
              },
              child: Text(AppLocalizations.of(context)!.registerHere,
                  style: TextStyle(
                      fontSize: 16,
                      color: Darkblue,
                      fontFamily: "Gilroy Bold"))
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/email.png",
                  color: notifier.getwhiteblackcolor,
                  height: 18,
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    sendEmail("suporte@gotuk.pt", "", "");
                  },
                  child: Text("suporte@gotuk.pt",
                      style: TextStyle(
                          fontSize: 14,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Medium")),
                )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/whatsapp.png",
                  color: notifier.getwhiteblackcolor,
                  height: 18,
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    openWhatsApp("+351917773031");
                  },
                  child: Text("+351 917773031",
                      style: TextStyle(
                          fontSize: 14,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Medium")),
                )
              ],
            )
          ],
        ),
      )
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

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
  }

  void requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Permissões de notificações concedidas");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("Permissões provisórias concedidas");
    } else {
      print("Permissões de notificações negadas");
    }
  }
}

class Slide {
  String image;
  String heading;
  String subtext;

  Slide(this.image, this.heading, this.subtext);
}
