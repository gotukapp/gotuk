// ignore_for_file: prefer_final_fields, camel_case_types, sized_box_for_whitespace, avoid_print, avoid_unnecessary_containers

import 'package:dm/Login&ExtraDesign/checkout.dart';
import 'package:dm/Login&ExtraDesign/review.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../Utils/tour.dart';

class tourdetailpage extends StatefulWidget {
  final int tourId;

  const tourdetailpage(this.tourId, {super.key});
  @override
  State<tourdetailpage> createState() => _tourdetailpageState();
}

class _tourdetailpageState extends State<tourdetailpage> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;
  Tour? tour;

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(38.7071, -9.13549),
    zoom: 8.0,
  );
  MapLibreMapController? mapController;

  void _onMapChanged() {
    setState(() {
    });
  }

  @override
  void dispose() {
    mapController?.removeListener(_onMapChanged);
    super.dispose();
  }

  void onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    mapController!.addListener(_onMapChanged);
  }

  late ColorNotifire notifire;
  @override
  Widget build(BuildContext context) {
    tour = tourList.firstWhere((tour) => tour.id == widget.tourId);
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final maplibreMap = MapLibreMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      onMapClick: (point, latLng) async {
        debugPrint(
            "Map click: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
      },
      onUserLocationUpdated: (location) {
        debugPrint(
            "new location: ${location.position}, alt.: ${location.altitude}, bearing: ${location.bearing}, speed: ${location.speed}, horiz. accuracy: ${location.horizontalAccuracy}, vert. accuracy: ${location.verticalAccuracy}");
      },
    );

    debugPrint(
        "mapController  ${mapController}");

    mapController?.addLine(
      LineOptions(
        draggable: false,
        lineColor: "#ff0000",
        lineWidth: 7.0,
        lineOpacity: 1,
        geometry: tour!.coords.map((c) => LatLng(c["lat"], c["lng"])).toList()
      ),
    );


    return Scaffold(
      bottomNavigationBar: Container(
        color: notifire.getblackwhitecolor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (context) => checkout(tourId: tour!.id, goNow: false)))
                      .then((value) => print('ok Navigat'));
                },
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50), color: LogoColor),
                  child: Center(
                    child: Text(
                      "Book Tour",
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
                          builder: (context) => checkout(tourId: tour!.id, goNow: true)))
                      .then((value) => print('ok Navigat'));
                },
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.4,
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
              )
            ],
          ),
        ),
      ),
      backgroundColor: notifire.getblackwhitecolor,
      body:
      CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          elevation: 0,
          backgroundColor: notifire.getblackwhitecolor,
          leading: Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: CircleAvatar(
              backgroundColor: notifire.getlightblackcolor,
              child: BackButton(
                color: notifire.getdarkwhitecolor,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: notifire.getlightblackcolor,
                    child: Image.asset(
                      "assets/images/share.png",
                      color: notifire.getdarkwhitecolor,
                      height: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: notifire.getlightblackcolor,
                    child: Image.asset(
                      "assets/images/heart.png",
                      color: notifire.getdarkwhitecolor,
                      height: 25,
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ],
          pinned: _pinned,
          snap: _snap,
          floating: _floating,
          expandedHeight: 250,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              tour!.img,
              height: 300,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
        ),
        SliverToBoxAdapter(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Stack(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour!.title.toUpperCase(),
                      style: TextStyle(
                          fontSize: 18,
                          color: notifire.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold"),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/images/location.png",
                              height: 20,
                              color: LogoColor,
                            ),
                            Text(
                              tour!.address,
                              style: TextStyle(
                                  color: notifire.getwhiteblackcolor,
                                  fontSize: 14,
                                  fontFamily: "Gilroy Medium"),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset("assets/images/star.png", height: 18),
                            Text(
                              "4.2",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: notifire.getdarkbluecolor,
                                  fontFamily: "Gilroy Bold"),
                            ),
                            Text(
                              "(84 Reviews)",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: notifire.getwhiteblackcolor,
                                  fontFamily: "Gilroy Medium"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/user.png",
                          height: 20,
                          color: LogoColor,
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Row(
                                children: [
                                  Text(
                                    "1-3",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                        fontFamily: "Gilroy Bold"),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${tour!.priceLow}€",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: notifire.getdarkbluecolor,
                                        fontFamily: "Gilroy Bold"),
                                  ),
                                  Text(
                                    " (Price per person ${(tour!.priceLow/3).toStringAsFixed(1)}€)",
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        fontSize: 14,
                                        color: notifire.getwhiteblackcolor),
                                  )
                                ]
                            ),
                            Row(
                              children: [
                                Text(
                                  "4-6",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: notifire.getwhiteblackcolor,
                                      fontFamily: "Gilroy Bold"),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${tour!.priceHigh}€",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: notifire.getdarkbluecolor,
                                      fontFamily: "Gilroy Bold"),
                                ),
                                Text(
                                  " (Price per person ${(tour!.priceHigh/6).toStringAsFixed(1)}€)",
                                  style: TextStyle(
                                      fontFamily: "Gilroy Medium",
                                      fontSize: 14,
                                      color: notifire.getwhiteblackcolor),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/timer.png",
                          height: 20,
                          color: LogoColor,
                        ),
                        SizedBox(width: 20),
                        Text(
                          tour!.duration,
                          style: TextStyle(
                              fontSize: 18,
                              color: notifire.getwhiteblackcolor,
                              fontFamily: "Gilroy Bold"),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Container(
                        height: 300.0,
                        child: maplibreMap
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Card(
                      color: notifire.getdarkmodecolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                "View Details",
                                style: TextStyle(
                                    color: notifire.getdarkbluecolor,
                                    fontFamily: "Gilroy Medium"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reviews",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Gilroy Bold",
                              color: notifire.getwhiteblackcolor),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const review(),
                            ));
                          },
                          child: Text(
                            "See All",
                            style: TextStyle(
                                fontSize: 15,
                                color: notifire.getdarkbluecolor,
                                fontFamily: "Gilroy Medium"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.035),
                    Container(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: 10,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: WhiteColor,
                                    backgroundImage: AssetImage(
                                        hotelList4[index]["img"].toString()),
                                    radius: 25,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.54,
                                              child: Text(
                                                hotelList4[index]["title"]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: notifire
                                                        .getwhiteblackcolor,
                                                    fontFamily: "Gilroy Bold"),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.10),
                                          Image.asset("assets/images/star.png",
                                              height: 20),
                                          InkWell(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                        builder: (context) =>
                                                            const review()))
                                                    .then((value) =>
                                                        print('ok Navigat'));
                                              },
                                              child: Text(
                                                  hotelList4[index]["review"]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: "Gilroy Bold",
                                                      color: notifire
                                                          .getwhiteblackcolor)))
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.007),
                                      SizedBox(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.70,
                                        child: Text(
                                          hotelList4[index]["massage"]
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: notifire.getgreycolor,
                                              fontFamily: "Gilroy Medium"),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                color: notifire.getgreycolor,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ]),
            )
          ],
        )),
      ]),
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
