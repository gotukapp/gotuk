// ignore_for_file: camel_case_types, avoid_print

import 'package:dm/Providers/userProvider.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/trip.dart';
import '../Utils/Colors.dart';

class RateTour extends StatefulWidget {
  final Trip trip;

  const RateTour(this.trip, {super.key});

  @override
  State<RateTour> createState() => _RateTourState();
}

class _RateTourState extends State<RateTour> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late UserProvider userProvider;
  late ColorNotifier notifier;


  double _ratingTour = 3.0;
  double _ratingGuide = 3.0;
  final TextEditingController _commentTourController = TextEditingController();
  final TextEditingController _commentGuideController = TextEditingController();

  Future<void> submitRating() async {
    // Handle the rating submission here (e.g., save it to a database or send to an API)
    final commentTour = _commentTourController.text;
    final commentGuide = _commentGuideController.text;

    await widget.trip.submitReview(_ratingTour, commentTour, _ratingGuide, commentGuide, userProvider.user!.name);

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: lightGrey,
          content: Text("Thank you for rating the tour!",
          style: TextStyle(
              fontSize: 14,
              fontFamily: "Gilroy Medium",
              color: Darkblue))
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getblackwhitecolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text("Rate Your Tour",
            style: TextStyle(color: notifier.getwhiteblackcolor,
                fontFamily: "Gilroy Bold")),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How was your tour?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            RatingBar.builder(
              initialRating: _ratingTour,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _ratingTour = rating;
                });
              },
            ),
            const SizedBox(height: 15),
            // Comments text field
            TextField(
              controller: _commentTourController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Leave a comment",
                hintText: "Tell us about your experience...",
              ),
            ),
            const SizedBox(height: 20),
            const Text("How was your Guide?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            RatingBar.builder(
              initialRating: _ratingGuide,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _ratingGuide = rating;
                });
              },
            ),
            const SizedBox(height: 15),
            // Comments text field
            TextField(
              controller: _commentGuideController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Leave a comment)",
                hintText: "Tell us about your experience...",
              ),
            ),
            const SizedBox(height: 50),
            // Submit button
            Center(
            child: AppButton(
                bgColor: notifier.getwhitelogocolor,
                textColor: notifier.getblackwhitecolor,
                buttontext: "Submit",
                onclick: () async {
                  submitRating();
                })
            ),
          ],
        ),
      )
      )
    );
  }

  @override
  void dispose() {
    _commentTourController.dispose();
    _commentGuideController.dispose();
    super.dispose();
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
