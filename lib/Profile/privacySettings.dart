import 'package:dm/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';

class PrivacySettings extends StatefulWidget {
  const PrivacySettings({super.key});

  @override
  _PrivacySettingsState createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _acceptedCookies = false;

  late ColorNotifier notifier;

  bool get _allAccepted =>
      _acceptedTerms && _acceptedPrivacy && _acceptedCookies;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: notifier.getbgcolor,
        title: Text(AppLocalizations.of(context)!.privacySettings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.termsAndConditions,
                  style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy Medium")),
              value: _acceptedTerms,
              activeColor: LogoColor,
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.dataProtectionPolicy,
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Gilroy Medium")),
              value: _acceptedPrivacy,
              activeColor: LogoColor,
              onChanged: (value) {
                setState(() {
                  _acceptedPrivacy = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.cookiesPolicy,
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Gilroy Medium")),
              value: _acceptedCookies,
              activeColor: LogoColor,
              onChanged: (value) {
                setState(() {
                  _acceptedCookies = value;
                });
              },
            ),
            const SizedBox(height: 30),
            AppButton(
                bgColor: notifier.getwhitelogocolor,
                textColor: notifier.getblackwhitecolor,
                buttontext: AppLocalizations.of(context)!.saveChanges,
                onclick: () {
                  if (_allAccepted) {

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.privacySettingsChangesSaved)
                        )
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.acceptAll),
                            backgroundColor: RedColor
                        )
                    );
                  }
                }
            )
          ],
        ),
      ),
    );
  }
}
