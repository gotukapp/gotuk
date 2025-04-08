// ignore_for_file: file_names, non_constant_identifier_names

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  bool promotions = false;
  bool bookings = true;
  bool payments = true;
  bool switchValue = false;
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getdarkscolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          AppLocalizations.of(context)!.notificationSettings,
          style: TextStyle(
              fontSize: 17,
              color: notifier.getwhiteblackcolor,
              fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getdarkscolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            NotificationSetting(
              title: AppLocalizations.of(context)!.promotions,
              subtitle: AppLocalizations.of(context)!.promotionsSubTitle,
              status: promotions,
              toggel: (bool? value1) {
                setState(() {
                  promotions = value1!;
                });
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            NotificationSetting(
              title: AppLocalizations.of(context)!.bookings,
              subtitle: AppLocalizations.of(context)!.bookingsSubTitle,
              status: bookings,
              toggel: (bool? value2) {
                setState(() {
                  bookings = value2!;
                });
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            NotificationSetting(
              title: AppLocalizations.of(context)!.invoiceAndPayment,
              subtitle: AppLocalizations.of(context)!.invoiceAndPaymentSubTitle,
              status: payments,
              toggel: (bool? value2) {
                setState(() {
                  payments = value2!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  NotificationSetting({title, subtitle, status, toggel}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontFamily: "Gilroy Bold"),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 14,
                      color: greyColor,
                      fontFamily: "Gilroy Medium"),
                ),
              ],
            ),
            // ignore: sized_box_for_whitespace
            Container(
              height: 41.0,
              width: 60.0,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSwitch(
                      value: status,
                      thumbColor: notifier.getdarkwhitecolor,
                      trackColor: notifier.getbuttoncolor,
                      activeColor: notifier.getdarkbluecolor,
                      onChanged: toggel),
                ),
              ),
            ),
          ],
        ),
      ],
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
