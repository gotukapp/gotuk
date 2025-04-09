import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../CreatAccount/verifyAccount.dart';

Future<void> signInWithPhoneNumber(BuildContext context, String phoneNumber, Function callback) {
  UserCredential? userCredential;
  return FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await Sentry.captureMessage("signInWithPhoneNumber: phoneNumber:$phoneNumber verificationCompleted $credential");
      userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      callback.call(userCredential, null);
    },
    verificationFailed: (FirebaseAuthException e) async {
      callback.call(null, e);
    },
    codeSent: (String verificationId, int? resendToken) async {
      try {
        String smsCode = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const verifyAccount()));

        // Create a PhoneAuthCredential using the code and the verificationId
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        callback.call(userCredential, null);
      } catch (e) {
        callback.call(null, e);
      }
    },
    codeAutoRetrievalTimeout: (String verificationId) async {
      await Sentry.captureMessage("signInWithPhoneNumber: phoneNumber:$phoneNumber codeAutoRetrievalTimeout verificationId:$verificationId");
    },
  );
}

