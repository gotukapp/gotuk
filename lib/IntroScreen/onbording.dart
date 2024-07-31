// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:dm/CreatAccount/login.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ignore: unused_import
import 'package:dm/IntroScreen/onbording.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CreatAccount/createScreen.dart';

class onbording extends StatefulWidget {
  const onbording({super.key});

  @override
  State<onbording> createState() => _onbordingState();
}

class _onbordingState extends State<onbording> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();

    Future.delayed(
        const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const BoardingPage()));
      },
   );
  }

  late ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: Center(
          child: Image.asset("assets/images/applogo.png",
              height: 170, width: 200)),
    );
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previousState;
    }
  }
}

class BoardingPage extends StatefulWidget {
  const BoardingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BoardingScreenState createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingPage> {
  // creating all the widget before making our home screen

  void initState() {
    getdarkmodepreviousstate();
    super.initState();
    _currentPage = 0;
    slides = [
      Slide("assets/images/onboarding1.jpg", "Tuk Tuk booking with GoTuk",
          "The best tours at the best prices"),
      Slide("assets/images/onboarding2.jpg", " Best tour experience",
          "Get the best deals on tuk tuk tours - Everyday!"),
      Slide("assets/images/onboarding3.jpg", "Signup on GoTuk",
          "Largest & most trusted Tuk Tuk App"),
    ];
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

  late ColorNotifire notifire;

  Widget _buildSlide(Slide slide) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: Column(
        children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.04), //upar thi jagiya mukeli che
          // ignore: sized_box_for_whitespace
          Container(
            height: MediaQuery.of(context).size.height / 2.2, //imagee size
            width: double.infinity,
            child: FittedBox(
            child:Image.asset(slide.image),
            fit: BoxFit.fill,
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
                  color: notifire.getwhiteblackcolor), //heding Text
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
                  color: notifire.getdarkgreycolor,
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
                                  "CONTINUE",
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
                      "SKIP",
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
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
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
    super.initState();
  }

  late ColorNotifire notifire;
  late bool isDriver = false;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.065),
                    Text("Driver mode",
                        style: TextStyle(
                            fontSize: 15,
                            color: notifire.getwhiteblackcolor,
                            fontFamily: "Gilroy Bold")),
                  ],
                ),
                // ignore: sized_box_for_whitespace
                Container(
                  height: 43.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoSwitch(
                        thumbColor: notifire.getdarkwhitecolor,
                        trackColor: notifire.getbuttoncolor,
                        activeColor: notifire.getdarkbluecolor,
                        value: isDriver,
                        onChanged: (value) async {
                          setState(() {
                            isDriver = value;
                          });
                          final prefs =
                          await SharedPreferences.getInstance();
                          setState(() {
                            isDriver = value;
                            prefs.setBool("setIsDriver", value);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 6.5),
            Center(
              child: Image.asset(
                "assets/images/applogo.png",
                height: 170,
                width: 220,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              "Welcome to GoTuk",
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: "Gilroy Bold",
                  color: notifire.getwhiteblackcolor),
            ),
            const SizedBox(height: 10),
            Text(
                "If you are new here, please create your account before booking a tour.",
                style: TextStyle(
                    fontSize: 20,
                    color: notifire.getdarkgreycolor,
                    fontFamily: "Gilroy Medium"),
                textAlign: TextAlign.center),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const createScreen()));
              },
              // ignore: sort_child_properties_last
              child: Text(
                isDriver ? 'CREATE DRIVER ACCOUNT' : 'CREATE ACCOUNT',
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
                isDriver ? 'LOGIN AS A DRIVER' :  'LOGIN',
                style: TextStyle(
                    color: WhiteColor, fontSize: 16, fontFamily: "Gilroy Bold"),
              ),
              style: FilledButton.styleFrom(
                  backgroundColor: Darkblue,
                  fixedSize: const Size(400, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
            )
          ],
        ),
      ),
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

class Slide {
  String image;
  String heading;
  String subtext;

  Slide(this.image, this.heading, this.subtext);
}
