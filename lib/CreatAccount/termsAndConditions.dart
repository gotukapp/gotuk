import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';

class TermsAndConditions extends StatelessWidget {
  final String title;
  final List<Map<String, String>> info;

  const TermsAndConditions({super.key, required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    ColorNotifier notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: info.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info[index]["title"]!,
                            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            info[index]["text"]!,
                            style: const TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    })
            ),
            const SizedBox(height: 30),
            AppButton(
              bgColor: notifier.getwhitelogocolor,
              textColor: notifier.getlogowhitecolor,
              onclick: () {
                Navigator.pop(context, true);
              },
              buttontext: "Accept",
            ),
            const SizedBox(height: 30)
          ],
        ),
      ),
    );
  }
}
