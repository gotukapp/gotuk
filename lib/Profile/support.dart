// ignore_for_file: file_names

import 'package:dm/Profile/supportTicket.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/Colors.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    super.initState();
  }
  bool guideMode = false;

  String urlClientsFAQEN = "https://firebasestorage.googleapis.com/v0/b/app-gotuk.appspot.com/o/documents%2FFAQs_Clients_EN.pdf?alt=media&token=c2625188-325b-4981-b75b-3f6daa134841";
  String urlClientsFAQPT = "https://firebasestorage.googleapis.com/v0/b/app-gotuk.appspot.com/o/documents%2FFAQs_Clients_PT.pdf?alt=media&token=3218300b-b1e6-4de3-8c90-4f0a244ee8fc";
  String urlGuidesFAQEN = "https://firebasestorage.googleapis.com/v0/b/app-gotuk.appspot.com/o/documents%2FFAQs_Guides_EN.pdf?alt=media&token=a273357e-8efb-4239-aac6-68e54bf31189";
  String urlGuidesFAQPT = "https://firebasestorage.googleapis.com/v0/b/app-gotuk.appspot.com/o/documents%2FFAQs_Guides_PT.pdf?alt=media&token=c60e21fb-f11a-4aa9-b7ad-160fd98c27a7";
  String urlInternalRegulationsEN = "https://firebasestorage.googleapis.com/v0/b/app-gotuk.appspot.com/o/documents%2FInternalRegulations_EN.pdf?alt=media&token=16b0d841-03fd-401c-89f4-63ba55ffdce4";
  String urlInternalRegulationsPT = "https://firebasestorage.googleapis.com/v0/b/app-gotuk.appspot.com/o/documents%2FInternalRegulations_PT.pdf?alt=media&token=7f599b9f-a394-416a-bd6e-dd16db990db6";


  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getbgcolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          AppLocalizations.of(context)!.support,
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getbgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Locale currentLocale = Localizations.localeOf(context);
                  String url = guideMode ? (currentLocale.languageCode == "en" ? urlGuidesFAQEN : urlGuidesFAQPT)
                      : (currentLocale.languageCode == "en" ? urlClientsFAQEN : urlClientsFAQPT);
                  openUrl(url, context);
                },
                child: Text("FAQs",
                      style: TextStyle(
                          fontSize: 18,
                          color: notifier.getwhitelogocolor,
                          fontFamily: "Gilroy Medium"))
              ),
              Divider(
                height: 30,
                color: notifier.getgreycolor,
              ),
              if (guideMode)
                ...[InkWell(
                    onTap: () async {
                      Locale currentLocale = Localizations.localeOf(context);
                      String url = currentLocale.languageCode == "en" ? urlInternalRegulationsEN : urlInternalRegulationsPT;
                      openUrl(url, context);
                    },
                    child: Text(AppLocalizations.of(context)!.regulations,
                        style: TextStyle(
                            fontSize: 18,
                            color: notifier.getwhitelogocolor,
                            fontFamily: "Gilroy Medium"))
                ),
                    Divider(
                      height: 30,
                      color: notifier.getgreycolor,
                    )],
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (context) => const SupportTicket(null, null, null)));
                },
                child: Text(AppLocalizations.of(context)!.supportTicket,
                    style: TextStyle(
                        fontSize: 18,
                        color: notifier.getwhitelogocolor,
                        fontFamily: "Gilroy Medium")),
              ),
              Divider(
                height: 30,
                color: notifier.getgreycolor,
              ),
              Text(AppLocalizations.of(context)!.contacts,
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.getwhitelogocolor,
                      fontFamily: "Gilroy Medium")),
            ],
          )
        ),
      ),
    );
  }

  Future<void> openUrl(String url, BuildContext context) async {
    final pdfUrl = Uri.parse(url);
    if (await canLaunchUrl(pdfUrl)) {
      await launchUrl(pdfUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text("Could not open PDF with client FAQs."),
            backgroundColor: RedColor
        ),
      );
    }
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
}
