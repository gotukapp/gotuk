// ignore_for_file: prefer_final_fields, camel_case_types, sized_box_for_whitespace, avoid_print, avoid_unnecessary_containers

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Guide/tripCancel.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Domain/appUser.dart';
import '../Domain/point.dart';
import '../Domain/ticket.dart';
import '../Domain/trip.dart';
import '../Message/chatting.dart';
import '../Profile/supportTicket.dart';
import '../Utils/customwidget.dart';
import '../Utils/util.dart';

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
  bool guideMode = false;
  late Trip trip;
  PageController _pageController = PageController();

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
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
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return StreamBuilder(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: CircularProgressIndicator(color: WhiteColor));
          }

          trip = snapshot.data!.data()!;
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
                  expandedHeight: MediaQuery.of(context).size.height * 0.32,
                  flexibleSpace: FlexibleSpaceBar(
                      background: PageView(
                          controller: _pageController,
                          onPageChanged: _handlingOnPageChanged,
                          physics: const BouncingScrollPhysics(),
                          children: _buildSlides(trip.tour.images))
                  ),
                ),
                SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildDots(slides: trip.tour.images, index: _currentPage),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Stack(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.tour.name.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: notifier.getwhiteblackcolor,
                                      fontFamily: "Gilroy Bold"),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (trip.status != 'pending')
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
                                              Text(AppLocalizations.of(context)!.reservationId,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: notifier.getwhiteblackcolor,
                                                    fontFamily: "Gilroy"),
                                              )
                                            ],
                                          ),
                                          Text(trip.reservationId != null ? trip.reservationId! : '',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: notifier.getwhiteblackcolor,
                                                fontFamily: "Gilroy Bold"),
                                          )
                                        ],
                                      ),
                                    if (trip.status == 'pending' && !guideMode)
                                      Expanded(
                                        child: Text(AppLocalizations.of(context)!.reservationOnHold,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: notifier.getwhiteblackcolor,
                                              fontFamily: "Gilroy Bold")))
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
                                        Text(AppLocalizations.of(context)!.pickupPoint,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: notifier.getwhiteblackcolor,
                                                  fontFamily: "Gilroy"),
                                            )
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () async {
                                          try {
                                            Point p = trip.tour.pickupPoints!.firstWhere((p) => p.name == (trip.pickupPoint ?? trip.tour.pickupPoint));
                                            openNavigationOptions(context, p.coordinates.latitude, p.coordinates.longitude);
                                          } catch (e) {
                                            await Sentry.captureException(e);
                                          }
                                        },
                                      child: Text(trip.pickupPoint ?? trip.tour.pickupPoint,
                                        style: TextStyle(
                                            color: notifier.getwhiteblackcolor,
                                            fontSize: 18,
                                            fontFamily: "Gilroy Medium"),
                                        )
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
                                        Text(AppLocalizations.of(context)!.reservationDate,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: notifier.getwhiteblackcolor,
                                              fontFamily: "Gilroy"),
                                        )
                                      ],
                                    ),
                                    Text(
                                      DateFormat('E, d MMM yyyy HH:mm', AppLocalizations.of(context)!.locale)
                                          .format(trip.date),
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: notifier.getwhiteblackcolor,
                                          fontFamily: "Gilroy Medium"),
                                    )
                                  ],
                                ),
                                Divider(
                                  height: 30,
                                  color: notifier.getgreycolor,
                                ),
                                if (!guideMode && trip.status == 'canceled')
                                  Center(
                                    child: Text(AppLocalizations.of(context)!.tripStatus(trip.status),
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: notifier.getlogobgcolor,
                                        fontFamily: "Gilroy Medium")
                                      ),
                                  ),
                                if (trip.guideRef != null && !guideMode
                                    && trip.status != 'canceled' && trip.status != 'pending')
                                  ...[StreamBuilder(
                                  stream: trip.guideRef?.withConverter(
                                    fromFirestore: AppUser.fromFirestore,
                                    toFirestore: (AppUser guide, _) => guide.toFirestore(),
                                  ).snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(child: CircularProgressIndicator(color: WhiteColor));
                                    }
                                    DocumentReference tuktukRef = snapshot.data?.get("tuktuk");
                                    AppUser? guide = snapshot.data?.data();
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                ImageFiltered(
                                                  imageFilter: ImageFilter.blur(sigmaX: trip.allowShowGuide() ? 0 : 4, sigmaY: trip.allowShowGuide() ? 0 : 4),
                                                  child: Container(child:
                                                  CircleAvatar(
                                                    backgroundColor: WhiteColor,
                                                    backgroundImage: const AssetImage('assets/images/avatar.png'),
                                                    radius: 25,
                                                  )
                                                  ),
                                                ),
                                                const SizedBox(width: 25),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    ImageFiltered(
                                                      imageFilter: ImageFilter.blur(sigmaX: trip.allowShowGuide() ? 0 : 4, sigmaY: trip.allowShowGuide() ? 0 : 4),
                                                      child: Container(child:
                                                      Text(guide!.name!,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: notifier
                                                                .getwhiteblackcolor,
                                                            fontFamily: "Gilroy Medium"),
                                                      )
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Image.asset("assets/images/star.png",
                                                            height: 20),
                                                        InkWell(
                                                            onTap: () {
                                                            },
                                                            child: Text(guide.rating.toString(),
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontFamily: "Gilroy Bold",
                                                                    color: notifier
                                                                        .getwhiteblackcolor)))
                                                      ],
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            if (trip.allowChat())
                                              InkWell(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                    builder: (context) => Chatting(trip: trip, sendTo: guide)));
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(50), color: WhiteColor),
                                                child: Center(
                                                    child: Image.asset(
                                                      "assets/images/message.png",
                                                      height: 40,
                                                      width: 40,
                                                      color: LogoColor,
                                                    )
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context).size.height * 0.03),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            StreamBuilder(
                                                stream: tuktukRef.snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Center(child: CircularProgressIndicator(color: WhiteColor));
                                                  }
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                            "assets/images/tuktuk.png",
                                                            height: 20,
                                                            width: 20,
                                                            color: LogoColor,
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(AppLocalizations.of(context)!.licensePlate,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: notifier.getwhiteblackcolor,
                                                                fontFamily: "Gilroy"),
                                                          )
                                                        ],
                                                      ),
                                                      ImageFiltered(
                                                        imageFilter: ImageFilter.blur(sigmaX: trip.allowShowGuide() ? 0 : 4, sigmaY: trip.allowShowGuide() ? 0 : 4),
                                                        child: Container(child:
                                                          Text(snapshot.data?.get("licensePlate"),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: notifier
                                                                    .getwhiteblackcolor,
                                                                fontFamily: "Gilroy Medium"),
                                                          )
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                }),
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
                                                    Text(AppLocalizations.of(context)!.remainingPayment,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: notifier.getwhiteblackcolor,
                                                          fontFamily: "Gilroy"),
                                                    )
                                                  ],
                                                ),
                                                Text("${trip.tour.getTourPrice(trip.persons < 5)}€",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Darkblue,
                                                      fontFamily: "Gilroy Medium"),
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                      ]
                                    );
                                  }),
                                    if(trip.status == 'booked')
                                      ...[
                                      Divider(
                                        height: 30,
                                        color: notifier.getgreycolor,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (trip.allowStart() && (trip.clientIsReady == null || !trip.clientIsReady!))
                                            InkWell(
                                            onTap: () async {
                                              await setClientReady(context, trip);
                                            },
                                            child: Container(
                                              height: 50,
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50), color: LogoColor),
                                              child: Center(
                                                child: Text(
                                                  AppLocalizations.of(context)!.letsGo.toUpperCase(),
                                                  style: TextStyle(
                                                      color: WhiteColor,
                                                      fontSize: 18,
                                                      fontFamily: "Gilroy Bold"),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                  builder: (context) => SupportTicket(trip, 'Reservation', ticketReasons['Reservation']?[0])));
                                            },
                                            child: Container(
                                              height: 50,
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50), color: greyColor),
                                              child: Center(
                                                child: Text(
                                                  AppLocalizations.of(context)!.reschedule.toUpperCase(),
                                                  style: TextStyle(
                                                      color: WhiteColor,
                                                      fontSize: 18,
                                                      fontFamily: "Gilroy Bold"),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ]
                                  ],
                                if (guideMode)
                                  StreamBuilder(
                                    stream: trip.clientRef?.withConverter(
                                      fromFirestore: AppUser.fromFirestore,
                                      toFirestore: (AppUser client, _) => client.toFirestore(),
                                    ).snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(child: CircularProgressIndicator(color: WhiteColor));
                                      }
                                      AppUser? client = snapshot.data?.data();
                                      return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (trip.status != 'pending')
                                              ...[
                                                Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor: WhiteColor,
                                                        backgroundImage: const AssetImage('assets/images/avatar.png'),
                                                        radius: 25,
                                                      ),
                                                      const SizedBox(width: 25),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(client!.name!,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: notifier
                                                                    .getwhiteblackcolor,
                                                                fontFamily: "Gilroy Medium"),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  if (trip.allowChat())
                                                    InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(MaterialPageRoute(
                                                          builder: (context) => Chatting(trip: trip, sendTo: client)));
                                                    },
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(50), color: WhiteColor),
                                                      child: Center(
                                                        child: Image.asset(
                                                          "assets/images/message.png",
                                                          height: 40,
                                                          width: 40,
                                                          color: LogoColor,
                                                        )
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context).size.height * 0.03)
                                              ],
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
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
                                                          Text("Payment to receive",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: notifier.getwhiteblackcolor,
                                                                fontFamily: "Gilroy"),
                                                          )
                                                        ],
                                                      ),
                                                      Text("${trip.tour.getTourPrice(trip.persons < 5)}€",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Darkblue,
                                                            fontFamily: "Gilroy Medium"),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                            "assets/images/language.png",
                                                            height: 20,
                                                            width: 20,
                                                            color: LogoColor,
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(AppLocalizations.of(context)!.preferredLanguage,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: notifier.getwhiteblackcolor,
                                                                fontFamily: "Gilroy"),
                                                          )
                                                        ],
                                                      ),
                                                      Text(trip.guideLang,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: notifier.getwhiteblackcolor,
                                                            fontFamily: "Gilroy Medium"),
                                                      )
                                                    ],
                                                  )
                                            ]),
                                            SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.03),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                            "assets/images/persons.png",
                                                            height: 20,
                                                            width: 20,
                                                            color: LogoColor,
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(AppLocalizations.of(context)!.persons,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: notifier.getwhiteblackcolor,
                                                                fontFamily: "Gilroy"),
                                                          )
                                                        ],
                                                      ),
                                                      Text(trip.persons < 5 ? "1-4" : "5-6",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: notifier.getwhiteblackcolor,
                                                            fontFamily: "Gilroy Medium"),
                                                      )
                                                    ],
                                                  )
                                                ]),
                                          ]
                                      );
                                    }),
                                if(guideMode && trip.status == 'pending')
                                  ...[
                                    Divider(
                                      height: 30,
                                      color: notifier.getgreycolor,
                                    ),
                                    InkWell(
                                    onTap: () {
                                      showConfirmationAcceptTour(context, trip);
                                    },
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50), color: notifier.getwhitelogocolor),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.acceptTour,
                                          style: TextStyle(
                                              color: notifier.getblackwhitecolor,
                                              fontSize: 18,
                                              fontFamily: "Gilroy Bold"),
                                        ),
                                      ),
                                    ),
                                  )],
                                if(guideMode && trip.status == 'booked' && trip.allowCancel())
                                  ...[
                                    Divider(
                                      height: 30,
                                      color: notifier.getgreycolor,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => TripCancel(trip: trip)));
                                      },
                                      child: Container(
                                        height: 50,
                                        margin: const EdgeInsets.only(bottom: 15),
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50), color: greyColor),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.cancelTour,
                                            style: TextStyle(
                                                color: WhiteColor,
                                                fontSize: 18,
                                                fontFamily: "Gilroy Bold"),
                                          ),
                                        ),
                                      ),
                                    )]
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
            fit: BoxFit.fill,
            child:Image.asset(image),
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

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
  }
}
