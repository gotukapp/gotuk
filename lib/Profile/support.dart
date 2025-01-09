// ignore_for_file: file_names

import 'package:dm/Profile/supportTicket.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/customwidget .dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
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
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getbgcolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          "Support",
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getbgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            children: [
              Text("FAQ",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.getwhitelogocolor,
                      fontFamily: "Gilroy Medium")),
              Divider(
                height: 30,
                color: notifier.getgreycolor,
              ),
              Text("Support Ticket",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.getwhitelogocolor,
                      fontFamily: "Gilroy Medium")),
              const SizedBox(height: 25),
              AppButton(
                  bgColor: notifier.getwhitelogocolor,
                  textColor: notifier.getblackwhitecolor,
                  buttontext: "Create Support Ticket",
                  onclick: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                        builder: (context) => const SupportTicket(null, null, null)));
                  }),
              Divider(
                height: 30,
                color: notifier.getgreycolor,
              ),
              Text("Contactos",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.getwhitelogocolor,
                      fontFamily: "Gilroy Medium")),
            ],
          )
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
