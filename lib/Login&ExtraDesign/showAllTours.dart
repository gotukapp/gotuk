// ignore_for_file: file_names

import 'package:dm/Login&ExtraDesign/tourDetail.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:dm/Domain/tour.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class showAllTours extends StatefulWidget {
  const showAllTours({super.key});

  @override
  State<showAllTours> createState() => _showAllToursState();
}

class _showAllToursState extends State<showAllTours> {
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
              centertext: "Recomended for you",
              ActionIcon: null,
              bgcolor: notifier.getbgcolor,
              actioniconcolor: notifier.getwhiteblackcolor,
              leadingiconcolor: notifier.getwhiteblackcolor,
              titlecolor: notifier.getwhiteblackcolor)),
      backgroundColor: notifier.getbgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: SizedBox(
            child: ListView.builder(
          itemCount: tourList.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TourDetail(tourList[index].id)));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                width: 280,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: notifier.getdarkmodecolor),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          // ignore: sized_box_for_whitespace
                          Container(
                            height: 118,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                tourList[index].img,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  height: 30,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: lightBlack),
                                  child: Center(
                                    child: Text(
                                      "${tourList[index].priceLow}€ - ${tourList[index].priceHigh}€",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: notifier.getdarkwhitecolor,
                                          fontFamily: "Gilroy Bold"),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Text(
                        tourList[index].title,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Gilroy Bold",
                            color: notifier.getwhiteblackcolor),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Text(
                        tourList[index].address,
                        style: TextStyle(
                            fontSize: 12,
                            color: notifier.getgreycolor,
                            fontFamily: "Gilroy Medium",
                            overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.001),
                      Divider(color: notifier.getgreycolor),
                      // SizedBox(
                      //     height: MediaQuery.of(context)
                      //             .size
                      //             .height *
                      //         0.01),
                    ],
                  ),
                ),
              ),
            );
          },
        )),
      ),
    );
  }

  hotelsystem({String? image, text, double? radi}) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 6),
        Image.asset(
          image!,
          height: 25,
          color: notifier.getdarkbluecolor,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
              color: notifier.getgreycolor, fontFamily: "Gilroy Medium"),
        ),
        const SizedBox(width: 16),
        CircleAvatar(
          radius: radi,
          backgroundColor: notifier.getgreycolor,
        )
      ],
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
