import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/trip.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';

class TripCancel extends StatefulWidget {
  final Trip trip;

  const TripCancel({Key? key, required this.trip}) : super(key: key);

  @override
  _TripCancelState createState() => _TripCancelState();
}

class _TripCancelState extends State<TripCancel> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isButtonEnabled = false;


  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getblackwhitecolor,
      appBar: AppBar(
          title: const Text("Cancel Tour"),
          backgroundColor: notifier.getblackwhitecolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            guideTripLayout(context, notifier, widget.trip, false), // Display tour info

            const SizedBox(height: 20),

            // Warning message
            const Text(
              "Canceling this tour will negatively impact your rating. "
                  "Please provide a valid reason for the cancellation.",
              softWrap: true,
              textAlign: TextAlign.justify,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy Medium",
                  color: Colors.red),
            ),

            const SizedBox(height: 20),

            // Reason input field
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: "Cancellation Reason",
                border: const OutlineInputBorder(),
                errorText: _isButtonEnabled ? null : "Reason is required",
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _isButtonEnabled = value.trim().isNotEmpty;
                });
              },
            ),

            const SizedBox(height: 40),


            InkWell(
              onTap: () {
                widget.trip.cancelTour(_reasonController.text);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50), color: greyColor),
                child: Center(
                  child: Text(
                    "CANCEL TOUR",
                    style: TextStyle(
                        color: WhiteColor,
                        fontSize: 18,
                        fontFamily: "Gilroy Bold"),
                  ),
                ),
              ),
            )
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
}
