// ignore_for_file: use_key_in_widget_constructors

import 'package:dm/IntroScreen/onbording.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'Utils/LocaleModel.dart';
import 'Utils/dark_lightmode.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifire()),
      ],
      child: BoardingScreen(),
    ),
  );
}

class BoardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LocaleModel(),
        child: Consumer<LocaleModel>(
        builder: (context, localeModel, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const onbording(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          locale: localeModel.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('pt')
          ],
        )
      )
    );
  }
}
