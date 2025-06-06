// ignore_for_file: camel_case_types

import 'package:dm/CreatAccount/createScreen.dart';
import 'package:dm/Login&ExtraDesign/homepage.dart';
import 'package:dm/Utils/customwidget.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Domain/appUser.dart';
import '../Utils/Colors.dart';
import '../Providers/userProvider.dart';
import '../Utils/authentication.dart';
import '../Utils/util.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  late ColorNotifier notifier;
  late UserProvider userProvider;
  late bool guideMode = false;
  final phoneNumberController = TextEditingController();
  String countryCode = '351';
  bool _isLoading = false;

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getwhitegrey,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "",
              ActionIcon: null,
              bgcolor: notifier.getlogobgcolor,
              actioniconcolor: notifier.getblackwhitecolor,
              leadingiconcolor: notifier.getblackwhitecolor)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: notifier.getlogobgcolor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.welcomeGotuk}${guideMode ? " ${AppLocalizations.of(context)!.guide}" : ""}",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Gilroy Bold",
                          color: WhiteColor,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Text(AppLocalizations.of(context)!.pleaseLogin,
                          style: TextStyle(
                            fontSize: 16,
                            color: WhiteColor,
                            fontFamily: "Gilroy Medium",
                          )),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      Text(AppLocalizations.of(context)!.phoneNumber,
                        style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            fontSize: 16,
                            color: WhiteColor),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      IntlPhoneField(
                          decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.phoneNumber,
                              labelStyle: const TextStyle(fontSize: 16, color: Colors.white),
                              hintStyle: TextStyle(fontSize: 16, color: notifier.gettextfieldcolor, fontFamily: "Gilroy Medium"),
                              filled: true,
                              fillColor: WhiteColor,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: fieldColor,
                                  ),
                                  borderRadius: BorderRadius.circular(15))
                          ),
                          initialCountryCode: "PT",
                          languageCode: "pt_BR",
                          controller: phoneNumberController,
                          onCountryChanged: (country) {
                            countryCode = country.dialCode;
                          }
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: WhiteColor)) // Show spinner when loading
                      : AppButton(
                          bgColor: notifier.getlogowhitecolor,
                          textColor: notifier.getwhiteblackcolor,
                          buttontext: guideMode ? AppLocalizations.of(context)!.loginAsGuide.toUpperCase() : AppLocalizations.of(context)!.login.toUpperCase(),
                          onclick: signIn
                      ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.orLoginWith,
                          style: TextStyle(
                              fontSize: 15,
                              color: WhiteColor,
                              fontFamily: "Gilroy Medium"),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: notifier.getdarkmodecolor),
                          // margin: EdgeInsets.only(top: 12),
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: InkWell(
                            onTap: () async {
                              AppUser? user = await signInWithGoogle();
                              if(user != null) {
                                userProvider.setUser(user);
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                    builder: (context) => const homepage()),
                                        (route) => false);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(50)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.asset("assets/images/google.png",
                                        fit: BoxFit.fill),
                                    Text(
                                      "Google",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: "Gilroy Medium",
                                          color: notifier.getwhiteblackcolor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: notifier.getdarkmodecolor),
                          // margin: EdgeInsets.only(top: 12),
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: InkWell(
                            onTap: () async {
                              AppUser? user = await signInWithApple();
                              if(user != null) {
                                userProvider.setUser(user);
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                    builder: (context) => const homepage()),
                                        (route) => false);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(50)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.asset("assets/images/apple.png",
                                        fit: BoxFit.fill),
                                    Text(
                                      "Apple",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: "Gilroy Medium",
                                          color: notifier.getwhiteblackcolor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ]),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                child:
                  Column(
              children: [
                Text(AppLocalizations.of(context)!.withoutAccount,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: "Gilroy Medium",
                      color: LogoColor)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                AppButton(
                    buttontext: AppLocalizations.of(context)!.register,
                    onclick: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const createScreen()));
                    }),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                const SizedBox(height: 30),
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
            )
            )
          ])
      ),
    );
  }

  Future<void> signIn() async {
    if (phoneNumberController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      String phoneNumber = "+$countryCode${phoneNumberController.text}";
      try {
        await signInWithPhoneNumber(
            context, phoneNumber, (UserCredential? credential, Exception? e) async {
          if (credential != null) {
            await credentialsOk(credential);
          } else {
            await Sentry.captureException(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e != null ? e.toString() : "Login failed, please try again"),
                backgroundColor: RedColor
              ),
            );
          }
          setState(() { _isLoading = false; });
        });
      } catch(e) {
        await Sentry.captureException(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("$e"),
              duration: const Duration(seconds: 5)
          ),
        );
        setState(() { _isLoading = false; });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.phoneNumberRequired),
        ),
      );
    }
  }

  Future<void> credentialsOk(UserCredential credential) async {
    AppUser user = await getUserFirebaseInstance(
        guideMode, credential.user!);
    userProvider.setUser(user);
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (context) => const homepage()),
            (route) => false);
  }

  Future<AppUser?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return await getUserFirebaseInstance(guideMode, userCredential.user!);
  }

  Future<AppUser?> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    UserCredential userCredential = kIsWeb ?
      await FirebaseAuth.instance.signInWithPopup(appleProvider) :
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
    Sentry.captureMessage(userCredential.toString());
    return await getUserFirebaseInstance(guideMode, userCredential.user!);
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

  getUserInputCode() {

    return '123456';
  }
}
