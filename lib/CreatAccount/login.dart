// ignore_for_file: camel_case_types

import 'package:dm/CreatAccount/createScreen.dart';
import 'package:dm/Login&ExtraDesign/homepage.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/CreatAccount/forgotpassword.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/appUser.dart';
import '../Utils/Colors.dart';
import '../Providers/userProvider.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  late ColorNotifier notifier;
  late bool guideMode = false;
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
    final userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getwhitegrey,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "",
              ActionIcon: null,
              bgcolor: notifier.getlogobgcolor,
              actioniconcolor: notifier.getwhiteblackcolor,
              leadingiconcolor: notifier.getwhiteblackcolor)),
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
                        "Welcome to GoTuk${guideMode ? " Guide" : ""}",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Gilroy Bold",
                          color: WhiteColor,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Text("Please login to your account",
                          style: TextStyle(
                            fontSize: 16,
                            color: WhiteColor,
                            fontFamily: "Gilroy Medium",
                          )),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      Text("Phone Number",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Gilroy Medium",
                              color: WhiteColor)),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      textfield(
                          fieldColor: notifier.getfieldcolor,
                          hintColor: notifier.gettextfieldcolor,
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      textfield(
                          password: !showPassword,
                          fieldColor: notifier.getfieldcolor,
                          hintColor: notifier.gettextfieldcolor,
                          text: 'Enter your password',
                          suffix: InkWell(
                            onTap: () {
                              setState(() { showPassword = !showPassword; });
                            },
                            child: Icon(
                              Icons.visibility_off,
                              color: notifier.getgreycolor,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  AppButton(
                      bgColor: notifier.getlogowhitecolor,
                      textColor: notifier.getwhiteblackcolor,
                      buttontext: guideMode ? "LOGIN AS A GUIDE" : "LOGIN",
                      onclick: () async {
                        //await signInWithPhone(phoneNumberController.text);
                        AppUser? user = await signInWithEmailAndPassword();
                        if(user != null) {
                          userProvider.setUser(user);
                          user.setFirebaseToken();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                              builder: (context) => homepage()),
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
                                    builder: (context) => homepage()),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          // margin: EdgeInsets.only(top: 12),
                          height: 45,
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.065),
                        Text("I want to be a Guide",
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
              ],
            )
            )
          ])
      ),
    );
  }

  Future<AppUser?> signInWithEmailAndPassword() async {
    String errorMessage = '';
    try {
      if (phoneNumberController.text.isNotEmpty && phoneNumberController.text.isNotEmpty) {
        String userName = phoneNumberController.text.contains('@') ? phoneNumberController.text : "${phoneNumberController.text}@gotuk.pt";

        UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userName,
          password: passwordController.text,
        );

        return await getUserFirebaseInstance(guideMode, credential.user!);
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
    return null;
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically signs in when verification is completed
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.${e.code}${e.message}');
        } else {
          print('${e.code}${e.message}');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        // The code has been sent to the user, prompt for input
        String smsCode = await getUserInputCode(); // Assume a function that prompts user for code

        // Create a PhoneAuthCredential with the code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        // Sign the user in with the credential
        await auth.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out
      },
    );
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return await getUserFirebaseInstance(guideMode, userCredential.user!);
    } on Exception catch (e) {
      print('exception->$e');
    }

    return null;
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
