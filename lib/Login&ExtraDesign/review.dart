// ignore_for_file: camel_case_types, avoid_print

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/tour.dart';

class review extends StatefulWidget {
  final Tour tour;

  const review(this.tour, {super.key});

  @override
  State<review> createState() => _reviewState();
}

class _reviewState extends State<review> {
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
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "Reviews",
              ActionIcon: Icons.more_vert,
              bgcolor: notifier.getblackwhitecolor)),
      backgroundColor: notifier.getblackwhitecolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            children: [
              tourLayout(context, notifier, widget.tour),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.tour.reviews.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: WhiteColor,
                            backgroundImage:
                                AssetImage(widget.tour.reviews[index].img),
                            radius: 25,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      child: Text(
                                        widget.tour.reviews[index].name,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: "Gilroy Bold"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.10),
                                  Image.asset("assets/images/star.png",
                                      height: 20),
                                  Text(
                                      widget.tour.reviews[index].score.toString(),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.007),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text(
                                  widget.tour.reviews[index].message,
                                  style:
                                      TextStyle(fontSize: 14, color: greyColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        color: greyColor,
                      )
                    ],
                  );
                },
              ),
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
