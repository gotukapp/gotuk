import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../CreatAccount/verifyAccount.dart';

Future<UserCredential?> signInWithPhoneNumber(BuildContext context, String phoneNumber, Function callback) async {
  UserCredential? userCredential;
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print("User signed in automatically with phone credentials.");
    },
    verificationFailed: (FirebaseAuthException e) async {
      await Sentry.captureException(e,stackTrace: e.stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message != null ? e.message! : ''),
        ),
      );
      callback.call(null);
      print("Phone number verification failed. Code: ${e.code}. Message: ${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) async {
      // Code has been sent to the phone number
      print("Verification code sent to $phoneNumber.");

      String smsCode = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const verifyAccount()));

      // Create a PhoneAuthCredential using the code and the verificationId
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print("User signed in with the provided verification code.");
      callback.call(userCredential);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      print("Auto retrieval timeout, verification ID: $verificationId");
    },
  );
  return userCredential;
}

