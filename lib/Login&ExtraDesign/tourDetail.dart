// ignore_for_file: prefer_final_fields, camel_case_types, sized_box_for_whitespace, avoid_print, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Login&ExtraDesign/checkout.dart';
import 'package:dm/Login&ExtraDesign/review.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Domain/tour.dart';
import 'fullMap.dart';

class TourDetail extends StatefulWidget {
  final String tourId;

  const TourDetail(this.tourId, {super.key});
  @override
  State<TourDetail> createState() => _TourDetailState();
}

class _TourDetailState extends State<TourDetail> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;
  Tour? tour;
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

  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    return shortestSide >= 600; // standard threshold for tablets
  }

  int _currentPage = 0;
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    tour = Tour.availableTours.firstWhere((tour) => tour.id == widget.tourId);
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    final Stream<QuerySnapshot<Map<String, dynamic>>> tourReviews = FirebaseFirestore.instance
        .collection('tours')
        .doc(tour?.id)
        .collection('reviews')
        .orderBy('rating').snapshots();

    return Scaffold(
      bottomNavigationBar: Container(
        color: notifier.getblackwhitecolor,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 40),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => checkout(tourId: tour!.id, fromHome: false)))
                  .then((value) => print('ok Navigat'));
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: LogoColor),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.goNow,
                  style: TextStyle(
                      color: WhiteColor,
                      fontSize: 18,
                      fontFamily: "Gilroy Bold"),
                ),
              ),
            ),
          )
        ),
      ),
      backgroundColor: notifier.getblackwhitecolor,
      body:
      CustomScrollView(slivers: <Widget>[
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: notifier.getlightblackcolor,
                    child: Image.asset(
                      "assets/images/share.png",
                      color: notifier.getdarkwhitecolor,
                      height: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      tour!.favorite = tour!.favorite == true ? false : true;
                    },
                    child: CircleAvatar(
                        radius: 22,
                        backgroundColor: tour!.favorite == true ? Colors.red : notifier.getlightblackcolor,
                        child: Image.asset(
                          "assets/images/heart.png",
                          color: notifier.getdarkwhitecolor,
                          height: 25,
                        ),
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
          expandedHeight: isTablet(context) ? 320 : 255,
          flexibleSpace: FlexibleSpaceBar(
            background: PageView(
              controller: _pageController,
              onPageChanged: _handlingOnPageChanged,
              physics: const BouncingScrollPhysics(),
              children: _buildSlides(tour!.images))
          ),
        ),
        SliverToBoxAdapter(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: tourReviews,
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              List<QueryDocumentSnapshot<Map<String, dynamic>>>? reviews = [];
              if (snapshot.hasData) {
                reviews = snapshot.data?.docs;
              }
              return Column(
                children: [
                  _buildDots(slides: tour!.images, index: _currentPage),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Stack(children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tour!.name.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: notifier.getwhiteblackcolor,
                                    fontFamily: "Gilroy Bold"),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset("assets/images/star.png", height: 18),
                                  const SizedBox(width: 1),
                                  Text(
                                    "4.2",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: notifier.getdarkbluecolor,
                                        fontFamily: "Gilroy Bold"),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "(${reviews?.length} ${AppLocalizations.of(context)!.reviews})",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: notifier.getwhiteblackcolor,
                                        fontFamily: "Gilroy Medium"),
                                  )
                                ],
                              )],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "assets/images/location.png",
                                    height: 20,
                                    width: 20,
                                    color: LogoColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    tour!.pickupPoint,
                                    style: TextStyle(
                                        color: notifier.getwhiteblackcolor,
                                        fontSize: 16,
                                        fontFamily: "Gilroy Medium"),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/profile.png",
                                height: 20,
                                width: 20,
                                color: LogoColor,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "1-4",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: notifier.getwhiteblackcolor,
                                              fontFamily: "Gilroy Medium"),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${tour!.lowPrice}€",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: notifier.getdarkbluecolor,
                                              fontFamily: "Gilroy Bold"),
                                        ),
                                        Text(
                                          " (${AppLocalizations.of(context)!.pricePerPerson} ${(tour!.lowPrice/3).toStringAsFixed(1)}€)",
                                          style: TextStyle(
                                              fontFamily: "Gilroy Medium",
                                              fontSize: 14,
                                              color: notifier.getwhiteblackcolor),
                                        )
                                      ]
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "5-6",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: notifier.getwhiteblackcolor,
                                            fontFamily: "Gilroy Medium"),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${tour!.highPrice}€",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: notifier.getdarkbluecolor,
                                            fontFamily: "Gilroy Bold"),
                                      ),
                                      Text(
                                        " (${AppLocalizations.of(context)!.pricePerPerson} ${(tour!.highPrice/6).toStringAsFixed(1)}€)",
                                        style: TextStyle(
                                            fontFamily: "Gilroy Medium",
                                            fontSize: 14,
                                            color: notifier.getwhiteblackcolor),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/timer.png",
                                height: 20,
                                width: 20,
                                color: LogoColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                tour!.durationDescription,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: notifier.getwhiteblackcolor,
                                    fontFamily: "Gilroy Medium"),
                              )
                            ],
                          ),
                          /*
                          const SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/map-location.png",
                                height: 20,
                                width: 20,
                                color: LogoColor,
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const FullMap(),
                                    ));
                                  },
                                  child: Text(
                                    "View Route Details",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: notifier.getdarkbluecolor,
                                        fontFamily: "Gilroy Medium"),
                                  )
                              )
                            ],
                          ),*/
                          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.reviews,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Gilroy Bold",
                                    color: notifier.getwhiteblackcolor),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => review(tour!, reviews!),
                                  ));
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.seeAll,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: notifier.getdarkbluecolor,
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
                              itemCount: reviews?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: WhiteColor,
                                          backgroundImage: const AssetImage(
                                              'assets/images/avatar.png'),
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
                                                      reviews?[index].get("name") ?? '',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: notifier
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
                                                              builder: (context) => review(tour!, reviews!)))
                                                          .then((value) =>
                                                              print('ok Navigat'));
                                                    },
                                                    child: Text(
                                                        reviews![index].get('rating').toString(),
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontFamily: "Gilroy Bold",
                                                            color: notifier
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
                                                reviews[index].get("comment"),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: notifier.getgreycolor,
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
                                      color: notifier.getgreycolor,
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
              );
          })
        )
      ]),
    );
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
