// ignore_for_file: camel_case_types

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/CreatAccount/login.dart';
import 'package:dm/CreatAccount/verifyaccount.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class createScreen extends StatefulWidget {
  const createScreen({super.key});

  @override
  State<createScreen> createState() => _createScreenState();
}

class _createScreenState extends State<createScreen> {
  bool isvisibal = false;
  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();
  }

  late ColorNotifire notifire;
  late bool isDriver;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "",
              ActionIcon: null,
              bgcolor: notifire.getlogobgcolor,
              actioniconcolor: notifire.getwhiteblackcolor,
              leadingiconcolor: notifire.getwhiteblackcolor)),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: notifire.getlogobgcolor,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDriver ? "GoTuk Driver" : "Welcome to GoTuk",
                          style: TextStyle(
                              fontSize: 22,
                              fontFamily: "Gilroy Bold",
                              color: WhiteColor),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text("Let’s create your account first",
                            style: TextStyle(
                                fontSize: 16,
                                color: WhiteColor,
                                fontFamily: "Gilroy Medium")),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        Text("Name",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Gilroy Medium",
                                color: WhiteColor)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textfield(
                            feildcolor: notifire.getfieldcolor,
                            hintcolor: notifire.gettextfieldcolor,
                            text: 'Enter your name',
                            suffix: null),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        Text("Email",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Gilroy Medium",
                                color: WhiteColor)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textfield(
                            feildcolor: notifire.getfieldcolor,
                            hintcolor: notifire.gettextfieldcolor,
                            text: 'Enter your email',
                            prefix: Image.asset(
                              "assets/images/email.png",
                              height: 25,
                              color: notifire.getgreycolor,
                            ),
                            suffix: null),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        Text(
                          "Phone Number",
                          style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              fontSize: 16,
                              color: WhiteColor),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textfield(
                            feildcolor: notifire.getfieldcolor,
                            hintcolor: notifire.gettextfieldcolor,
                            text: 'Enter your number',
                            prefix: Image.asset(
                              "assets/images/call.png",
                              height: 25,
                              color: notifire.getgreycolor,
                            ),
                            suffix: null),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        Text("Password",
                            style: TextStyle(
                                fontFamily: "Gilroy Medium",
                                fontSize: 16,
                                color: WhiteColor)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textfield(
                            feildcolor: notifire.getfieldcolor,
                            hintcolor: notifire.gettextfieldcolor,
                            text: 'Enter your password',
                            prefix: Image.asset(
                              "assets/images/password.png",
                              height: 25,
                              color: notifire.getgreycolor,
                            ),
                            suffix: InkWell(
                              onTap: () {},
                              child: Icon(
                                Icons.visibility_off,
                                color: notifire.getgreycolor,
                              ),
                            )),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        AppButton(
                          bgColor: notifire.getlogowhitecolor,
                          textColor: notifire.getwhiteblackcolor,
                          onclick: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const verifyaccount()));
                          },
                          buttontext: "AGREE & CONTINUE",
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                      ],
                    ),
                  )
                ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Column(
                children: [
                  Text("Have an account?",
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Gilroy Medium",
                          color: LogoColor)),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  AppButton(
                    onclick: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const loginscreen()));
                    },
                    buttontext: "LOGIN",
                  )
                ],
              )
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
