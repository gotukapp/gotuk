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
  final List languages;
  final bool multiple;
  final List<String> currentLanguages;

  const Language({super.key, required this.languages, this.multiple = false, this.currentLanguages = const []});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    selectedLanguages = widget.currentLanguages;
    super.initState();
  }

  late ColorNotifier notifier;
  late String language = Localizations.localeOf(context).toString();
  late List<String> selectedLanguages;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getbgcolor,
        leading: BackButton(
            color: notifier.getwhiteblackcolor,
            onPressed: () {
              // Return the selected values when back button is pressed
              Navigator.pop(context, selectedLanguages);
            }),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy bold"),
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
                      itemCount: widget.languages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              setState(() {
                                if (widget.multiple) {
                                  if (selectedLanguages.contains(widget.languages[index]["code"].toLowerCase())) {
                                    selectedLanguages.remove(widget.languages[index]["code"].toLowerCase());
                                  } else {
                                    selectedLanguages.add(widget.languages[index]["code"].toLowerCase());
                                  }
                                } else {
                                  language = widget.languages[index]["code"].toLowerCase();
                                  localeModel.set(Locale(appLanguages[index]["code"].toLowerCase()));
                                }
                              });
                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Container(
                                  height: 55,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: notifier.getdarkmodecolor),
                                  child: ListTile(
                                    leading: Image.asset(
                                      "assets/images/Flag_${widget.languages[index]["code"]}.png",
                                      height: 25,
                                    ),
                                    title: Text(getTranslation(widget.languages[index]["name"]),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: notifier.getwhiteblackcolor,
                                            fontFamily: "Gilroy Medium")),
                                    trailing:
                                      widget.multiple ?
                                        (selectedLanguages.contains(widget.languages[index]["code"].toLowerCase()) ? Icon(Icons.check, color: Darkblue) : const Text(''))
                                        : (language == widget.languages[index]["code"].toLowerCase() ? Icon(Icons.check, color: Darkblue) : const Text(''))
                                    ,
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
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previusstate;
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
