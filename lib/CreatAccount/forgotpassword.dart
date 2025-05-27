// ignore_for_file: camel_case_types

import 'package:dm/CreatAccount/newpassword.dart';
import 'package:dm/Utils/customwidget.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Colors.dart';

class forgotpassword extends StatefulWidget {
  const forgotpassword({super.key});

  @override
  State<forgotpassword> createState() => _forgotpasswordState();
}

class _forgotpasswordState extends State<forgotpassword> {
  late ColorNotifier notifier;
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Forgot Password",
              style: TextStyle(
                  fontSize: 24,
                  fontFamily: "Gilroy Bold",
                  color: WhiteColor),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.016),
            Text("We’ve send verification code to",
                style: TextStyle(fontSize: 14, color: WhiteColor)),
          ]),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Text("Phone Number",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy Medium",
                  color: WhiteColor)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          textField(
            fieldColor: notifier.getfieldcolor,
            hintColor: notifier.gettextfieldcolor,
            text: 'Enter your phone number',
            suffix: null,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          AppButton(
              bgColor: notifier.getlogowhitecolor,
              textColor: notifier.getwhiteblackcolor,
              buttontext: "Send Code",
              onclick: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const newpassword()));
              })
        ]),
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
