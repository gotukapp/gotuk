// ignore_for_file: file_names

// ignore: unused_import
import 'package:dm/Profile/Favourite.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/trips.dart';


class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifire notifire;
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifire.getblackwhitecolor,
        leading: BackButton(color: notifire.getwhiteblackcolor),
        title: Text(
          "Transaction History",
          style: TextStyle(
              color: notifire.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifire.getblackwhitecolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pending Tours (${Trip.pendingTrips.length})",
                  style: TextStyle(
                      fontSize: 16,
                      color: LogoColor,
                      fontFamily: "Gilroy Bold")),
              const SizedBox(height: 1),
              SizedBox(
                height: Trip.pendingTrips.isEmpty ? 0 : 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: Trip.pendingTrips.length,
                  itemBuilder: (BuildContext context, int index) {
                    return getBookingLayout(Trip.pendingTrips[index], "WAITING", "CANCEL");
                  },
                )
              ),
              const SizedBox(height: 15),
              Text("My Tours (${Trip.waitingTrips.length})",
                  style: TextStyle(
                      fontSize: 16,
                      color: LogoColor,
                      fontFamily: "Gilroy Bold")),
              const SizedBox(height: 1),
              SizedBox(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: Trip.waitingTrips.length,
                  itemBuilder: (BuildContext context, int index) {
                    return getBookingLayout(Trip.waitingTrips[index], "BOOKED", "LET'S GO");
                  },
                ),
              ),
              const SizedBox(height: 15),
              Text("Past Tours (${Trip.finishedTrips.length})",
                  style: TextStyle(
                      fontSize: 16,
                      color: LogoColor,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 1),
              SizedBox(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: Trip.finishedTrips.length,
                  itemBuilder: (BuildContext context, int index) {
                    return getBookingLayout(Trip.finishedTrips[index], "FINISHED", "RATE TOUR");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getBookingLayout(Trip booking, String status, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getdarklightgreycolor),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5),
                          child: Container(
                            height: 110,
                            width: 130,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                booking.tour.img,
                                fit: BoxFit.fill
                              ),
                            ),
                          )
                        ),
                        Positioned(
                          left: 30,
                          width: 70,
                          height: 25,
                          child: Container(
                            height: 25,
                            width: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: WhiteColor),
                            child: Center(
                              child: Text(
                                status,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Darkblue,
                                    fontFamily: "Gilroy Bold"),
                              ),
                            ),
                          ),
                        ),
                      ]
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(DateFormat('E, d MMM yyyy - HH:mm').format(booking.date),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: notifire.getwhiteblackcolor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(booking.tour.title.toUpperCase(),
                          style: TextStyle(
                              fontSize: 14,
                              color:
                              notifire.getwhiteblackcolor,
                              fontFamily: "Gilroy Bold")),
                      Text("${booking.persons} Persons",
                          style: TextStyle(
                              fontSize: 12,
                              color: notifire.getwhiteblackcolor,
                              fontFamily: "Gilroy Medium")),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("Total Price",
                                  style: TextStyle(
                                      fontSize: 12, color: notifire.getwhiteblackcolor, fontFamily: "Gilroy Medium")),
                              Text("${booking.price}€",
                                  style: TextStyle(
                                      fontSize: 14, color: Darkblue, fontFamily: "Gilroy Bold")),
                            ],
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                          InkWell(
                            onTap: () {
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => Favourite()));
                            },
                            child: Container(
                              height: 25,
                              width: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50), color: LogoColor),
                              child: Center(
                                child: Text(
                                  action,
                                  style: TextStyle(
                                      fontSize: 10, color: WhiteColor, fontFamily: "Gilroy Bold"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ]
              )
        ),
      ),
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
