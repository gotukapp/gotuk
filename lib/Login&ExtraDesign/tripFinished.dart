import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Domain/trip.dart';
import '../Profile/rateTour.dart';
import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart'; // Import your rating screen

class TourFinishedScreen extends StatefulWidget {
  final Trip trip;
  const TourFinishedScreen(this.trip, {super.key});

  @override
  State<TourFinishedScreen> createState() => _TourFinishedScreenState();
}

class _TourFinishedScreenState extends State<TourFinishedScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RateTour(widget.trip)),
      );
    });
  }

  late ColorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getblackwhitecolor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.thumb_up_alt, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.tourFinishTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.tourFinishText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.redirecting),
              const SizedBox(height: 20),
              AppButton(
                  bgColor: notifier.getwhitelogocolor,
                  textColor: Colors.white,
                  buttontext: AppLocalizations.of(context)!.redirecting,
                  onclick: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RateTour(widget.trip)),
                    );
                  }
              )
            ],
          ),
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
}
