// ignore_for_file: camel_case_types

import 'package:dm/Message/chating.dart';
import 'package:dm/Message/ShowMassage.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/tour.dart';

class message extends StatefulWidget {
  const message({super.key});

  @override
  State<message> createState() => _messageState();
}

class _messageState extends State<message> {
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
      backgroundColor: notifire.getbgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Message",
                  style: TextStyle(
                      fontSize: 18,
                      color: notifire.getwhiteblackcolor,
                      fontFamily: "Gilroy bold"),
                ),
                CircleAvatar(
                    radius: 22,
                    backgroundColor: notifire.getdarkmodecolor,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ShowMassage()));
                      },
                      child: Image.asset(
                        "assets/images/notification.png",
                        height: 25,
                        color: notifire.getwhiteblackcolor,
                      ),
                    ))
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              50,
                            ),
                            color: notifire.getdarkmodecolor),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search a tour',
                              hintStyle: TextStyle(
                                  color: notifire.getgreycolor,
                                  fontFamily: "Gilroy Medium"),
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Image.asset(
                                  "assets/images/search.png",
                                  height: 25,
                                  color: notifire.getgreycolor,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        )),
                    SizedBox(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: allReviews.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Chating()));
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: WhiteColor,
                                      backgroundImage: AssetImage(
                                          allReviews[index].img),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 0, right: 0),
                                    title: Text(
                                      allReviews[index].name,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: notifire.getwhiteblackcolor,
                                          fontFamily: "Gilroy Bold"),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      allReviews[index].message,
                                      style: TextStyle(
                                          color: notifire.getgreycolor,
                                          fontFamily: "Gilroy Medium"),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Column(
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03),
                                        Text(
                                          "7:12 Am",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  notifire.getwhiteblackcolor,
                                              fontFamily: "Gilroy Medium"),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01),
                                        CircleAvatar(
                                          backgroundColor: notifire.getredcolor,
                                          radius: 10,
                                          child: Text(
                                            "12",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color:
                                                    notifire.getdarkwhitecolor),
                                          ),
                                        )
                                      ],
                                    ),
                                    isThreeLine: false,
                                  )));
                        },
                      ),
                    ),
                  ],
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
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }
}
