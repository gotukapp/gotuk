import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Login&ExtraDesign/notification.dart';
import '../Utils/Colors.dart';
import '../Utils/booking.dart';
import '../Utils/dark_lightmode.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifire notifire;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return SafeArea(
        child: Scaffold(
            backgroundColor: notifire.getblackwhitecolor,
            body: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                child:  SingleChildScrollView(
                    child:
                      Column(
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
                                    "Good tours with GoTuk",
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
                          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                          Text(
                            "Completed Tours",
                            style: TextStyle(
                                fontSize: 14,
                                color: LogoColor,
                                fontFamily: "Gilroy Medium"),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: notifire.getdarklightgreycolor),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child:  Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Transaction(text1: "2", text2: "Today"),
                                        Transaction(text1: "9", text2: "Last 7 days"),
                                        Transaction(text1: "26", text2: "Last 30 days"),
                                      ],
                                    ),
                                  ]
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                          Text(
                            "Booking Tours",
                            style: TextStyle(
                                fontSize: 14,
                                color: LogoColor,
                                fontFamily: "Gilroy Medium"),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: notifire.getdarklightgreycolor),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child:  Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Transaction(text1: "3", text2: "Today"),
                                        Transaction(text1: "6", text2: "This Week"),
                                        Transaction(text1: "10", text2: "This Month"),
                                      ],
                                    ),
                                  ]
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text("Current Tour",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: LogoColor,
                                  fontFamily: "Gilroy Bold")),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: notifire.getdarklightgreycolor),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('E, d MMM yyyy HH:mm').format(currentBook.date),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: notifire.getgreycolor)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          currentBook.tour.icon,
                                          height: 75,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(currentBook.tour.title.toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                    notifire.getwhiteblackcolor,
                                                    fontFamily: "Gilroy Bold")),
                                            const SizedBox(height: 6),
                                            Text("${currentBook.persons} Persons",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: notifire.getgreycolor,
                                                    fontFamily: "Gilroy Medium")),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    cupon(
                                      text1: "Total Price",
                                      text2: "${currentBook.price}€",
                                      buttonText: "Ongoing",
                                      onClick: () {
                                        // Navigator.of(context).push(MaterialPageRoute(
                                        //     builder: (context) => Favourite()));
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text("Today Bookings",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: LogoColor,
                                  fontFamily: "Gilroy Bold")),
                          const SizedBox(height: 8),
                          SizedBox(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: driverBookings.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: notifire.getdarklightgreycolor),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(DateFormat('E, d MMM yyyy HH:mm').format(driverBookings[index].date),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: notifire.getgreycolor)),
                                              Container(
                                                height: 40,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(50),
                                                    color: Colors.amber[50]),
                                                child: const Center(
                                                  child: Text(
                                                    "Booked",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Color(0xffFFBA55),
                                                        fontFamily: "Gilroy Bold"),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Image.asset(
                                                driverBookings[index].tour.icon,
                                                height: 75,
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(driverBookings[index].tour.title.toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                          notifire.getwhiteblackcolor,
                                                          fontFamily: "Gilroy Bold")),
                                                  const SizedBox(height: 6),
                                                  Text("${driverBookings[index].persons} Persons",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: notifire.getgreycolor,
                                                          fontFamily: "Gilroy Medium")),
                                                ],
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          cupon(
                                            text1: "Total Price",
                                            text2: "${driverBookings[index].price}€",
                                            buttonText: "Ready",
                                            onClick: () {
                                              // Navigator.of(context).push(MaterialPageRoute(
                                              //     builder: (context) => Favourite()));
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]
                    ),
                )
            )
        ));
  }

  Transaction({text1, text2}) {
    return Column(
      children: [
        Text(
          text2,
          style: TextStyle(
              fontSize: 14,
              color: notifire.getwhiteblackcolor,
              fontFamily: "Gilroy Medium"),
        ),
        const SizedBox(height: 1),
        Text(
          text1,
          style: TextStyle(
              fontSize: 18,
              color: LogoColor,
              fontFamily: "Gilroy Bold"),
        )
      ],
    );
  }

  cupon({text1, text2, buttonText, Function()? onClick}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text1,
                style: TextStyle(
                    fontSize: 15, color: greyColor, fontFamily: "Gilroy Medium")),
            const SizedBox(height: 4),
            Text(text2,
                style: TextStyle(
                    fontSize: 16, color: Darkblue, fontFamily: "Gilroy Bold")),
          ],
        ),
        if (buttonText.isNotEmpty)
          ...[InkWell(
            onTap: onClick,
            child: Container(
              height: 40,
              width: 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Darkblue),
              child: Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                      fontSize: 15, color: WhiteColor, fontFamily: "Gilroy Bold"),
                ),
              ),
            ),
          )],
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
