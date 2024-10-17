// ignore_for_file: prefer_final_fields, camel_case_types, sized_box_for_whitespace, avoid_print, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Login&ExtraDesign/review.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/appUser.dart';
import '../Domain/trips.dart';

class TripDetail extends StatefulWidget {
  final String tripId;

  const TripDetail(this.tripId, {super.key});
  @override
  State<TripDetail> createState() => _TripDetailState();
}

class _TripDetailState extends State<TripDetail> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;
  Trip? trip;
  PageController _pageController = PageController();

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  List<Widget> _buildSlides(List<String> slides) {
    return slides.map(_buildSlide).toList();
  }

  void _handlingOnPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  int _currentPage = 0;
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection("trips").doc(widget.tripId)
        .withConverter(
      fromFirestore: Trip.fromFirestore,
      toFirestore: (Trip trip, _) => trip.toFirestore(),
    );

    final dbUsers = FirebaseFirestore.instance.collection("users");


    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return StreamBuilder(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("Loading");
          }
          trip = snapshot.data?.data();
          return Scaffold(
              backgroundColor: notifier.getblackwhitecolor,
              body: CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: notifier.getblackwhitecolor,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: CircleAvatar(
                      backgroundColor: notifier.getlightblackcolor,
                      child: BackButton(
                        color: notifier.getdarkwhitecolor,
                      ),
                    ),
                  ),
                  pinned: _pinned,
                  snap: _snap,
                  floating: _floating,
                  expandedHeight: 220,
                  flexibleSpace: FlexibleSpaceBar(
                      background: PageView(
                          controller: _pageController,
                          onPageChanged: _handlingOnPageChanged,
                          physics: const BouncingScrollPhysics(),
                          children: _buildSlides(trip!.tour.images))
                  ),
                ),
                SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildDots(slides: trip!.tour.images, index: _currentPage),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Stack(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip!.tour.title.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: notifier.getwhiteblackcolor,
                                      fontFamily: "Gilroy Bold"),
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          "assets/images/reservation-id.png",
                                          height: 20,
                                          width: 20,
                                          color: LogoColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text("Reservation Id",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: notifier.getwhiteblackcolor,
                                              fontFamily: "Gilroy"),
                                        )
                                      ],
                                    ),
                                    Text(trip!.reservationId != null ? trip!.reservationId! : '',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: notifier.getwhiteblackcolor,
                                          fontFamily: "Gilroy Bold"),
                                    )
                                  ],
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.03),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          "assets/images/location.png",
                                          height: 20,
                                          width: 20,
                                          color: LogoColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text("Pickup point",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: notifier.getwhiteblackcolor,
                                              fontFamily: "Gilroy"),
                                        )
                                      ],
                                    ),
                                    Text(
                                      trip!.tour.address,
                                      style: TextStyle(
                                          color: notifier.getwhiteblackcolor,
                                          fontSize: 18,
                                          fontFamily: "Gilroy Medium"),
                                    )
                                  ],
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.03),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/timer.png",
                                          height: 20,
                                          width: 20,
                                          color: LogoColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text("Reservation Date",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: notifier.getwhiteblackcolor,
                                              fontFamily: "Gilroy"),
                                        )
                                      ],
                                    ),
                                    Text(
                                      DateFormat('E, d MMM yyyy HH:mm')
                                          .format(trip!.date),
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: notifier.getwhiteblackcolor,
                                          fontFamily: "Gilroy Medium"),
                                    )
                                  ],
                                ),
                                Divider(
                                  height: 50,
                                  color: notifier.getgreycolor,
                                ),
                                if (trip?.guideRef != null)
                                  StreamBuilder(
                                  stream: trip?.guideRef?.withConverter(
                                    fromFirestore: AppUser.fromFirestore,
                                    toFirestore: (AppUser guide, _) => guide.toFirestore(),
                                  ).snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text("Loading");
                                    }
                                    AppUser? guide = snapshot.data?.data();
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/guide-card.png",
                                                      height: 20,
                                                      width: 20,
                                                      color: LogoColor,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text("Guide",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: notifier.getwhiteblackcolor,
                                                          fontFamily: "Gilroy"),
                                                    )
                                                  ],
                                                ),
                                                Text(guide!.name!,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: notifier
                                                          .getwhiteblackcolor,
                                                      fontFamily: "Gilroy Medium"),
                                                ),
                                                Row(
                                                  children: [
                                                    Image.asset("assets/images/star.png",
                                                        height: 20),
                                                    InkWell(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(MaterialPageRoute(
                                                              builder: (context) => review(trip!.tour)));
                                                        },
                                                        child: Text(
                                                            trip!.tour.reviews[0].score.toString(),
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontFamily: "Gilroy Bold",
                                                                color: notifier
                                                                    .getwhiteblackcolor)))
                                                  ],
                                                )
                                              ],
                                            ),
                                            CircleAvatar(
                                              backgroundColor: WhiteColor,
                                              backgroundImage: AssetImage(
                                                  trip!.tour.reviews[0].img),
                                              radius: 25,
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context).size.height * 0.03),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  "assets/images/credit-card.png",
                                                  height: 20,
                                                  width: 20,
                                                  color: LogoColor,
                                                ),
                                                const SizedBox(width: 5),
                                                Text("Payment to Guide",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: notifier.getwhiteblackcolor,
                                                      fontFamily: "Gilroy"),
                                                )
                                              ],
                                            ),
                                            Text("${trip?.tour.getTourPrice(trip?.persons == 3)}€",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Darkblue,
                                                  fontFamily: "Gilroy Medium"),
                                            )
                                          ],
                                        )
                                      ]
                                    );
                                })
                              ],
                            ),
                          ]),
                        )
                      ],
                    )),
              ]),
            );
        });
  }

  Widget _buildSlide(String image) {
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 3,
          width: double.infinity,
          child: FittedBox(
            child:Image.asset(image),
            fit: BoxFit.fill,
          ),
        )
      ],
    );
  }

  Widget _buildDots({
    List<String>? slides,
    int? index,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for(int i=0;i<slides!.length;i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // borderRadius: const BorderRadius.all(
              //   Radius.circular(50),
              // ),
              // color: Color(0xFF000000),
              color: _currentPage == i ? Darkblue : greyColor,
            ),
            margin: const EdgeInsets.only(right: 8),
            curve: Curves.easeIn,
            width: _currentPage == i ? 12 : 8,
            height: _currentPage == i ? 12 : 8,
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
