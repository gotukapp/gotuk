// ignore_for_file: file_names

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/LocaleModel.dart';
import '../Utils/customwidget .dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifire notifire;
  late String language = Localizations.localeOf(context).toString();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifire.getbgcolor,
        leading: BackButton(color: notifire.getwhiteblackcolor),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: TextStyle(
              color: notifire.getwhiteblackcolor, fontFamily: "Gilroy bold"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            SizedBox(
              child:
                Consumer<LocaleModel>(
                builder: (context, localeModel, child) =>
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: appLanguages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              setState(() {
                                language = appLanguages[index]["code"].toLowerCase();
                                localeModel.set(Locale(appLanguages[index]["code"].toLowerCase()));
                              });
                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: notifire.getdarkmodecolor),
                                  child: ListTile(
                                    leading: Image.asset(
                                      "assets/images/Flag_${appLanguages[index]["code"]}.png",
                                      height: 25,
                                    ),
                                    title: Text(getTranslation(appLanguages[index]["name"]),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: notifire.getwhiteblackcolor,
                                            fontFamily: "Gilroy Medium")),
                                    trailing: language == appLanguages[index]["code"].toLowerCase() ? Icon(Icons.check, color: Darkblue) : const Text(''),
                                  ),
                                ))
                        );
                      },
                    ),
                )
            ),
          ],
        ),
      ),
    );
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

  getTranslation(String name) {
    switch (name) {
      case 'english':
        return AppLocalizations.of(context)!.english;
      case 'portuguese':
        return AppLocalizations.of(context)!.portuguese;
      default:
        return name;
    }
  }
}
