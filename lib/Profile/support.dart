// ignore_for_file: file_names

import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late ColorNotifire notifire;
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifire.getbgcolor,
        leading: BackButton(color: notifire.getwhiteblackcolor),
        title: Text(
          "Support",
          style: TextStyle(
              color: notifire.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifire.getbgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            children: [
              Text("FAQ",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifire.getwhitelogocolor,
                      fontFamily: "Gilroy Medium")),
              const SizedBox(height: 10),
              Text("Formulário de Contacto",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifire.getwhitelogocolor,
                      fontFamily: "Gilroy Medium")),
              const SizedBox(height: 10),
              Text("Contactos",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifire.getwhitelogocolor,
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
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }
}
