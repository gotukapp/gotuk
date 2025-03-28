// ignore_for_file: use_key_in_widget_constructors

import 'package:dm/IntroScreen/onbording.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Providers/userProvider.dart';
import 'Domain/tour.dart';
import 'Utils/Colors.dart';
import 'Utils/LocaleModel.dart';
import 'Utils/dark_lightmode.dart';
import 'firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://cb0b9bfde90c6f924714674c28e39324@o4508120479039488.ingest.de.sentry.io/4508120483102800';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ColorNotifier()),
          ChangeNotifierProvider(create: (_) => UserProvider())
        ],
        child: BoardingScreen(),
      ),
    )
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
            home: FutureBuilder(
                future: Tour.fetchTours(),
                builder: (context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                        backgroundColor: WhiteColor,
                        body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/applogo.png",
                                    height: 170, width: 200),
                                const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 100),
                                    child: LinearProgressIndicator()
                                )
                              ],
                            )) // Loading indicator
                    );
                  } else {
                    return const onbording();
                  }

                }),
          )
      )
    );
  }
}
