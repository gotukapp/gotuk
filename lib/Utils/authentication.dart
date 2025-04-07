import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../CreatAccount/verifyAccount.dart';

Future<UserCredential?> signInWithPhoneNumber(BuildContext context, String phoneNumber, Function callback) async {
  UserCredential? userCredential;
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await Sentry.captureMessage("signInWithPhoneNumber: phoneNumber:$phoneNumber verificationCompleted $credential");
      userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      callback.call(userCredential);
    },
    verificationFailed: (FirebaseAuthException e) async {
      await Sentry.captureException(e, stackTrace: e.stackTrace);
      callback.call(null);
    },
    codeSent: (String verificationId, int? resendToken) async {
      String? smsCode = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const verifyAccount()));

      if (smsCode != null) {
        // Create a PhoneAuthCredential using the code and the verificationId
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        try {
          userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          callback.call(userCredential);
        } catch (e) {
          await Sentry.captureException(e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.invalidVerificationCode)),
          );
          callback.call(null);
        }
      } else {
        await Sentry.captureMessage("signInWithPhoneNumber: phoneNumber:$phoneNumber smsCode null verificationId:$verificationId");
        callback.call(null);
      }
    },
    codeAutoRetrievalTimeout: (String verificationId) async {
      await Sentry.captureMessage("signInWithPhoneNumber: phoneNumber:$phoneNumber codeAutoRetrievalTimeout verificationId:$verificationId");
    },
  );
  return userCredential;
}

