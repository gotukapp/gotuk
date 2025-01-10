// ignore_for_file: file_names

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Providers/userProvider.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final nameController = TextEditingController();

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifier notifier;
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context);

    nameController.text = userProvider.user!.name != null ? userProvider.user!.name! : '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getbgcolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          AppLocalizations.of(context)!.myProfile,
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getbgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: 200,
                color: notifier.getbgcolor,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 25,
                      left: 30,
                      child: CircleAvatar(
                        radius: 68,
                        backgroundImage:
                            AssetImage("assets/images/avatar.png"),
                        // child: Image.asset("assets/images/person1.jpeg"),
                      ),
                    ),
                    Positioned(
                      top: 85,
                      // bottom: 20,
                      right: 20,
                      // left: 20,
                      child: CircleAvatar(
                        radius: 37,
                        backgroundColor: WhiteColor,
                        child: CircleAvatar(
                          radius: 35,
                          child: Image.asset(
                            'assets/images/camera.png',
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.fullName,
                    style: TextStyle(
                        fontSize: 16,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy Bold"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  textfield(
                      fieldColor: notifier.getdarkmodecolor,
                      hintColor: notifier.getgreycolor,
                      text: AppLocalizations.of(context)!.enterYourName,
                      controller: nameController,
                      suffix: null),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.email,
                    style: TextStyle(
                        fontSize: 16,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy Bold"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    userProvider.user!.email ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy"),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.phoneNumber,
                    style: TextStyle(
                        fontSize: 16,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy Bold"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    userProvider.user!.phone ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy"),
                  ),
                ],
              ),
              SizedBox(height: 40),
              AppButton(
                  buttontext: AppLocalizations.of(context)!.saveChanges,
                  onclick: () {
                     userProvider.user!.update(nameController.text);
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                         content: Text("Profile changes saved successfully!"),
                       ),
                     );
                  }),
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
    } else {
      notifier.setIsDark = previusstate;
    }
  }
}
