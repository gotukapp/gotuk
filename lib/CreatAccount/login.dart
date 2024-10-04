// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/CreatAccount/createScreen.dart';
import 'package:dm/Login&ExtraDesign/homepage.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/CreatAccount/forgotpassword.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/userFirebase.dart';
import '../Utils/Colors.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  late ColorNotifire notifire;
  late bool isDriver = false;
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to GoTuk${isDriver ? " Driver" : ""}",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Gilroy Bold",
                          color: WhiteColor,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                      Text("Please login to your account",
                          style: TextStyle(
                            fontSize: 16,
                            color: WhiteColor,
                            fontFamily: "Gilroy Medium",
                          )),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      Text("Phone Number",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Gilroy Medium",
                              color: WhiteColor)),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      textfield(
                          fieldColor: notifire.getfieldcolor,
                          hintColor: notifire.gettextfieldcolor,
                          text: 'Enter your number',
                          suffix: null,
                          controller: phoneNumberController),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                      Text(
                        "Password",
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Gilroy Medium",
                            color: WhiteColor),
                      ),
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
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const forgotpassword()));
                          },
                          child: Text("Forgot Password?",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: WhiteColor,
                                  fontFamily: "Gilroy Medium")),
                        )),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  AppButton(
                      bgColor: notifire.getlogowhitecolor,
                      textColor: notifire.getwhiteblackcolor,
                      buttontext: "LOGIN",
                      onclick: () async {
                        bool loginOk = await signInWithPhoneAndPassword();
                        if(loginOk) {
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                              builder: (context) => const homepage()),
                                  (route) => false);
                        }
                      }),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Or login with",
                          style: TextStyle(
                              fontSize: 15,
                              color: WhiteColor,
                              fontFamily: "c"),
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
                              color: notifire.getdarkmodecolor),
                          // margin: EdgeInsets.only(top: 12),
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: InkWell(
                            onTap: () async {
                              bool loginOk = await signInWithGoogle();
                              if(loginOk) {
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                    builder: (context) => const homepage()),
                                        (route) => false);
                              }
                            },
                            child: ClipRRect(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
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
                                          color: notifire.getwhiteblackcolor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          // margin: EdgeInsets.only(top: 12),
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: InkWell(
                            onTap: () {},
                            child: ClipRRect(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                              child: Image.asset("assets/images/facebook.png",
                                  fit: BoxFit.fitWidth),
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
                Text("Don’t have an account?",
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: "Gilroy Medium",
                      color: LogoColor)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                AppButton(
                    buttontext: "REGISTER",
                    onclick: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const createScreen()));
                    }),
              ],
            )
            )
          ])
      ),
    );
  }

  Future<bool> signInWithPhoneAndPassword() async {
    String errorMessage = '';
    try {
      if (phoneNumberController.text.isNotEmpty && phoneNumberController.text.isNotEmpty) {
        UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${phoneNumberController.text}@gotuk.pt",
          password: passwordController.text,
        );

        await getUserFirebaseInstance(isDriver ? "guides" : "clients", credential);

        return true;
      } else {
        errorMessage = 'You must fill in the username and password.';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'invalid-email') {
        errorMessage = 'Invalid credentials.';
      } else {
        errorMessage = 'Unable to login.';
      }
    } on Exception {
      errorMessage = 'Unable to login.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
      ),
    );
    return false;
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (isDriver) {
        await getUserFirebaseInstance(isDriver ? "guides" : "clients", userCredential);
      }

      return true;
    } on Exception catch (e) {
      print('exception->$e');
    }

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

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDriver");
    isDriver = previousState ?? false;
  }

  Future<void> getUserFirebaseInstance(String collection, UserCredential credential) async {
    final ref = FirebaseFirestore.instance.collection(collection).doc(credential.user?.uid)
        .withConverter(
      fromFirestore: UserFirebase.fromFirestore,
      toFirestore: (UserFirebase user, _) => user.toFirestore(),
    );
    final docSnap = await ref.get();
    final user = docSnap.data();
    if (user == null) {
      UserFirebase user = UserFirebase(credential.user!.uid, credential.user!.displayName, credential.user?.email, credential.user?.phoneNumber);
      FirebaseFirestore.instance.collection(collection)
          .doc(credential.user?.uid)
          .set(user.toFirestore());
    }
  }
}
