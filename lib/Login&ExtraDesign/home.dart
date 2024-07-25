// ignore_for_file: camel_case_types

import 'package:dm/Login&ExtraDesign/NearbyallHotel.dart';
import 'package:dm/Login&ExtraDesign/showAllTours.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:dm/Utils/tour.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout.dart';
import 'tourdetail.dart';
import 'notification.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  //  String dropdownvalue1 = "0";
  // var mexitems = ["0", "1", "2", "3", "4", "5"];
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifire notifire;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: notifire.getblackwhitecolor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Text(
                        "Hello, Joaquim! 👋",
                        style: TextStyle(
                            color: notifire.getwhiteblackcolor,
                            fontSize: 16,
                            fontFamily: "Gilroy Medium"),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.0001),
                      Text(
                        "Let’s find you a tour",
                        style: TextStyle(
                            fontSize: 16,
                            color: LogoColor,
                            fontFamily: "Gilroy Bold"),
                      ),
                    ],
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const notification()));
                      },
                      child: CircleAvatar(
                          backgroundColor: notifire.getdarkmodecolor,
                          child: Image.asset(
                            "assets/images/notification.png",
                            height: 25,
                            color: notifire.getwhiteblackcolor,
                          )))
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: 190,
                        decoration: BoxDecoration(
                            border: Border.all(color: LogoColor),
                            borderRadius: BorderRadius.circular(50),
                            color: WhiteColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(
                              "assets/images/location.png",
                              height: 24,
                              color: LogoColor,
                            ),
                            Text(
                              "Lisboa, PT",
                              style: TextStyle(
                                  color: BlackColor,
                                  fontFamily: "Gilroy Medium"),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: LogoColor,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (context) => const checkout(tourId: 1, goNow: true)));
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50), color: LogoColor),
                              child: Center(
                                child: Text(
                                  "Go Now",
                                  style: TextStyle(
                                      color: WhiteColor,
                                      fontSize: 18,
                                      fontFamily: "Gilroy Bold"),
                                ),
                              ),
                            ),
                          ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.025),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recommended",
                            style: TextStyle(
                                fontFamily: "Gilroy Bold",
                                color: notifire.getwhiteblackcolor),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const showAllTours(),
                              ));
                            },
                            child: Text(
                              "See All",
                              style: TextStyle(
                                  color: notifire.getdarkbluecolor,
                                  fontFamily: "Gilroy Medium"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.018),
                      // const SizedBox(height: 10),
                      SizedBox(
                          height: height/3.1,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tourList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          tourdetailpage(tourList[index].id)));
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  width: 240,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: notifire.getdarklightgreycolor),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child :
                                                CircleAvatar(
                                                  radius: 50.0,
                                                  child: ClipOval(
                                                      child: Image.asset(
                                                        tourList[index].icon
                                                            .toString(),
                                                        fit: BoxFit.cover,
                                                      )),
                                                ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                  "${tourList[index].priceLow}€ - ${tourList[index].priceHigh}€",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Darkblue,
                                                      fontFamily:
                                                      "Gilroy Bold"),
                                                  ),
                                               ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02),
                                        Text(
                                          tourList[index].title.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Gilroy Bold",
                                              color:
                                                  notifire.getwhiteblackcolor),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.0005),
                                        Text(
                                          tourList[index].address,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: notifire.getwhiteblackcolor,
                                              fontFamily: "Gilroy Medium",
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            tourDuration(
                                                image: "assets/images/timer.png",
                                                text: tourList[index].duration,
                                                radi: 0),
                                            tourReview(review: tourList[index].review)
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nearby Tour",
                            style: TextStyle(
                                fontFamily: "Gilroy Bold",
                                color: notifire.getwhiteblackcolor),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const NearbyallHotel()));
                            },
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: notifire.getdarkbluecolor,
                                fontFamily: "Gilroy Medium",
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: nearbyTours.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => tourdetailpage(nearbyTours[index].id)));
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: notifire.getdarklightgreycolor,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    height: 75,
                                    width: 75,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        nearbyTours[index].icon,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nearbyTours[index].title.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: notifire.getwhiteblackcolor,
                                            fontFamily: "Gilroy Bold"),
                                      ),
                                      // const SizedBox(height: 6),
                                      SizedBox(
                                          height: MediaQuery.of(context) .size .height *
                                              0.001),
                                      Text(
                                          nearbyTours[index].address,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: notifire.getgreycolor,
                                              fontFamily: "Gilroy Medium",
                                              overflow: TextOverflow.ellipsis),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context) .size .height *
                                              0.001),
                                      Text(
                                        "${nearbyTours[index].priceLow}€ - ${nearbyTours[index].priceHigh}€",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: LogoColor,
                                            fontFamily: "Gilroy Bold"),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: SizedBox()),
                                  tourReview(review: nearbyTours[index].review)
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  tourDuration({String? image, text, double? radi}) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          image!,
          height: 25,
          color: LogoColor,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
              color: notifire.getwhiteblackcolor, fontFamily: "Gilroy Medium"),
        )
      ],
    );
  }

  tourReview({double? review})   {
    return Row(
      children: [
        Image.asset(
          "assets/images/star.png",
          height: 20,
        ),
        const SizedBox(width: 2),
        Padding(
          padding: const EdgeInsets.only(
              top: 4, right: 20),
          child: Row(
            children: [
              Text(
                review.toString(),
                style: TextStyle(
                    fontSize: 16,
                    color: notifire
                        .getdarkbluecolor,
                    fontWeight:
                    FontWeight.bold),
              )
            ],
          ),
        )
      ],
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
}
