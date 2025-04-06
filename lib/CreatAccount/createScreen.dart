// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/CreatAccount/termsAndConditions.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/CreatAccount/login.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Domain/appUser.dart';
import '../Login&ExtraDesign/homepage.dart';
import '../Providers/userProvider.dart';
import '../Utils/authentication.dart';

class createScreen extends StatefulWidget {
  const createScreen({super.key});

  @override
  State<createScreen> createState() => _createScreenState();
}

class _createScreenState extends State<createScreen> {
  bool termsAndConditionsAccepted = false;
  bool dataProtectionPolicyAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    termsAndConditionsAccepted = false;
    dataProtectionPolicyAccepted = false;
    super.initState();
  }

  late UserProvider userProvider;
  late ColorNotifier notifier;
  late bool guideMode = false;
  bool showPassword = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  String countryCode = '351';

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "",
              ActionIcon: null,
              bgcolor: notifier.getlogobgcolor,
              actioniconcolor: notifier.getwhiteblackcolor,
              leadingiconcolor: WhiteColor)),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: notifier.getlogobgcolor,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guideMode ? AppLocalizations.of(context)!.gotukGuide : AppLocalizations.of(context)!.welcomeGotuk,
                          style: TextStyle(
                              fontSize: 22,
                              fontFamily: "Gilroy Bold",
                              color: WhiteColor),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(AppLocalizations.of(context)!.letsCreateYourAccount,
                            style: TextStyle(
                                fontSize: 16,
                                color: WhiteColor,
                                fontFamily: "Gilroy Medium")),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        Text(AppLocalizations.of(context)!.name,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Gilroy Medium",
                                color: WhiteColor)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textField(
                            fieldColor: notifier.getfieldcolor,
                            hintColor: notifier.gettextfieldcolor,
                            text: AppLocalizations.of(context)!.enterYourName,
                            suffix: null,
                            controller: nameController),
                        const SizedBox(height: 25),
                        Text(
                          AppLocalizations.of(context)!.phoneNumber,
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
                              fillColor: notifier.getfieldcolor,
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
                        Text(AppLocalizations.of(context)!.email,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Gilroy Medium",
                                color: WhiteColor)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textField(
                            fieldColor: notifier.getfieldcolor,
                            hintColor: notifier.gettextfieldcolor,
                            text: AppLocalizations.of(context)!.enterYourEmail,
                            controller: emailController,
                            suffix: null),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        TextButton(
                          onPressed: () async {
                            final bool accepted = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TermsAndConditions(title: AppLocalizations.of(context)!.dataProtectionPolicy, info: dataProtectionPolicy)),
                            );
                            setState(() {
                              dataProtectionPolicyAccepted = accepted;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.dataProtectionPolicy,
                                style: const TextStyle(fontSize: 16, color: Colors.white)),
                              Image.asset(dataProtectionPolicyAccepted ? "assets/images/square-check-regular.png" : "assets/images/square-regular.png",
                                height: 20,
                                color: Colors.white)]
                          )
                        ),
                        TextButton(
                          onPressed: () async {
                            final bool accepted = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TermsAndConditions(title: AppLocalizations.of(context)!.termsAndConditions, info: termsAndConditions)),
                            );
                            setState(() {
                              termsAndConditionsAccepted = accepted;
                            });
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.termsAndConditions,
                                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                                Image.asset(termsAndConditionsAccepted ? "assets/images/square-check-regular.png" : "assets/images/square-regular.png",
                                    height: 20,
                                    color: Colors.white)]
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        _isLoading
                            ? Center(child: CircularProgressIndicator(color: WhiteColor)) // Show spinner when loading
                            : AppButton(
                          bgColor: notifier.getlogowhitecolor,
                          textColor: notifier.getwhiteblackcolor,
                          onclick: () async {
                            if (phoneNumberController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.phoneNumberRequired),
                                ),
                              );
                            } else if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.nameRequired),
                                ),
                              );
                            } else if (!termsAndConditionsAccepted || !dataProtectionPolicyAccepted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.acceptDataProtectionPolicyAndTermsAndConditions),
                                ),
                              );
                            } else {
                              setState(() {
                                _isLoading = true;
                              });
                              await createUser();
                            }
                          },
                          buttontext: AppLocalizations.of(context)!.agreeAndContinue.toUpperCase(),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                      ],
                    ),
                  )
                ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25, top: 8, bottom: 30),
                  child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.haveAnAccount,
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
                    buttontext: AppLocalizations.of(context)!.login.toUpperCase(),
                  )
                ],
              )
              ),
            ],
          ),
      ),
    );
  }

  Future<void> createUser() async {
    try {
      String phoneNumber = "+$countryCode${phoneNumberController.text}";
      await signInWithPhoneNumber(context, phoneNumber, (UserCredential? credential) async {
        if (credential != null) {
          try {
            FirebaseFirestore.instance
                .collection("users")
                .doc(credential.user?.uid)
                .set({
              "email": emailController.text,
              "name": nameController.text,
              "phone": phoneNumber,
              "accountValidated": false,
              "accountAccepted": false,
              "languages": null,
              "rating": 3
            });

            await credentialsOk(credential);

            await accountCreated();

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const homepage()),
                  (route) => false,
            );
          } catch(e) {
            await Sentry.captureException(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.unableToCreateAccount),
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unableToCreateAccount),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unableToCreateAccount),
        ),
      );
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unableToCreateAccount),
        ),
      );
    }
  }

  Future<void> credentialsOk(UserCredential credential) async {
    AppUser user = await getUserFirebaseInstance(
        guideMode, credential.user!);
    userProvider.setUser(user);
    user.setFirebaseToken();
  }

  accountCreated() {
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
                              AppLocalizations.of(context)!.accountCreated,
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
                              AppLocalizations.of(context)!.accountCreatesSuccessfully,
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
                        Navigator.pop(context, true);
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
                          color: notifier.getwhitelogocolor,
                        ),
                        child: Center(
                            child: GestureDetector(
                                child: Text(AppLocalizations.of(context)!.onboardingContinue,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: notifier.getblackwhitecolor,
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
  }
}
