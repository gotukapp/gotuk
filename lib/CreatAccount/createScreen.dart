// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/CreatAccount/login.dart';
import 'package:dm/CreatAccount/verifyaccount.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late bool guideMode = false;
  bool showPassword = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

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
                          guideMode ? "GoTuk Guide" : "Welcome to GoTuk",
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
                            fieldColor: notifire.getfieldcolor,
                            hintColor: notifire.gettextfieldcolor,
                            text: 'Enter your name',
                            suffix: null,
                            controller: nameController),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        Text("Email",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Gilroy Medium",
                                color: WhiteColor)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textfield(
                            fieldColor: notifire.getfieldcolor,
                            hintColor: notifire.gettextfieldcolor,
                            text: 'Enter your email',
                            controller: emailController,
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
                            fieldColor: notifire.getfieldcolor,
                            hintColor: notifire.gettextfieldcolor,
                            text: 'Enter your number',
                            suffix: null,
                            controller: phoneNumberController),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        Text("Password",
                            style: TextStyle(
                                fontFamily: "Gilroy Medium",
                                fontSize: 16,
                                color: WhiteColor)),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        textfield(
                            password: !showPassword,
                            fieldColor: notifire.getfieldcolor,
                            hintColor: notifire.gettextfieldcolor,
                            text: 'Enter your password',
                            suffix: InkWell(
                              onTap: () {
                                setState(() { showPassword = !showPassword; });
                              },
                              child: Icon(
                                Icons.visibility_off,
                                color: notifire.getgreycolor,
                              ),
                            ),
                            controller: passwordController),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        AppButton(
                          bgColor: notifire.getlogowhitecolor,
                          textColor: notifire.getwhiteblackcolor,
                          onclick: () async {
                            bool userCreated = await createUser();
                            if (userCreated) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const verifyaccount()));
                            }
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

  Future<bool> createUser() async {
    String errorMessage = '';
    try {
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "${phoneNumberController.text}@gotuk.pt",
        password: passwordController.text,
      );
      FirebaseAuth.instance.currentUser?.updateDisplayName(nameController.text);

      FirebaseFirestore.instance
          .collection(guideMode ? 'guides' : 'clients')
          .doc(credential.user?.uid)
          .set({
        "email": emailController.text,
        "name": nameController.text,
        "phone": phoneNumberController.text
      });

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email provided is invalid.';
      } else {
        errorMessage = 'Unable to create user.';
      }
    } on Exception {
      errorMessage = 'Unable to create user.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
      ),
    );
    return false;
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
