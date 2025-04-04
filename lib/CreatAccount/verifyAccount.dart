// ignore_for_file: camel_case_types, prefer_final_fields, unused_import, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/CreatAccount/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/dark_lightmode.dart';

class verifyAccount extends StatefulWidget {
  const verifyAccount({super.key});

  @override
  State<verifyAccount> createState() => _verifyAccountState();
}

class _verifyAccountState extends State<verifyAccount> {
  final codeController = TextEditingController();

  @override
  void initState() {
    startTimer();
    getdarkmodepreviousstate();
    super.initState();
  }

  formatedTime(timeInSecond) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute:$second";
  }

  void startTimer() {}
  late ColorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
        backgroundColor: notifier.getlogobgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(75),
            child: CustomAppbar(
                centertext: "",
                ActionIcon: null,
                bgcolor: notifier.getlogobgcolor,
                actioniconcolor: notifier.getwhiteblackcolor,
                leadingiconcolor: notifier.getwhiteblackcolor)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context)!.verifyYourAccount,
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Gilroy Bold",
                    color: WhiteColor),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(AppLocalizations.of(context)!.sendVerificationCode,
                  style: TextStyle(
                      fontSize: 16,
                      color: WhiteColor,
                      fontFamily: "Gilroy Medium")),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              Text(AppLocalizations.of(context)!.verifyYourCode,
                  style: TextStyle(
                      fontSize: 17,
                      fontFamily: "Gilroy Medium",
                      color: WhiteColor)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              textField(
                fieldColor: notifier.getdarkmodecolor,
                hintColor: notifier.getgreycolor,
                text: AppLocalizations.of(context)!.verificationCode,
                controller: codeController),
              SizedBox(
                height: MediaQuery.of(context).size.height *0.05,
              ),
              AppButton(
                bgColor: notifier.getblackwhitecolor,
                textColor: notifier.getwhitelogocolor,
                buttontext: AppLocalizations.of(context)!.verifyAccount.toUpperCase(),
                onclick: () => {
                  Navigator.pop(context, codeController.text)
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(AppLocalizations.of(context)!.didNotReceiveTheCode,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Gilroy Medium",
                        color: WhiteColor)),
                const SizedBox(
                  width: 6,
                ),
                InkWell(
                  onTap: () {

                  },
                  child: Text(AppLocalizations.of(context)!.resend,
                      style: TextStyle(
                          fontSize: 16,
                          color: greyColor,
                          fontFamily: "Gilroy Medium")),
                )
              ])
            ]),
          ),
        ));
  }

  bottomsheet() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: notifier.getbgcolor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return SizedBox(
            height: 600,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 30,
                      child: CircleAvatar(
                        radius: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Image.asset('assets/images/Illustration.png'),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 55,
                      top: -18,
                      child: Image.asset(
                        'assets/images/Success.png',
                        height: 160,
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.16,
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              "Account Created",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Gilroy Bold",
                                  color: notifier.getwhiteblackcolor),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: Text(
                              "Congratulations! Book your next tour.",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Gilroy Medium",
                                  color: notifier.getdarkgreycolor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const loginscreen()));
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.45,
                            left: 20,
                            right: 20),
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Darkblue,
                        ),
                        child: Center(
                            child: GestureDetector(
                                child: Text("Login",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: WhiteColor,
                                        fontFamily: "Gilroy Bold")))),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        });
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
