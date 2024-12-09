// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Login&ExtraDesign/calendar.dart';
import 'package:dm/Login&ExtraDesign/homepage.dart';
import 'package:dm/Login&ExtraDesign/tripDetail.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Domain/trips.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../Domain/appUser.dart';
import '../Domain/tour.dart';
import '../Providers/userProvider.dart';
import '../Utils/notification.dart';

class checkout extends StatefulWidget {
  final String tourId;
  final bool goNow;

  const checkout({super.key,required this.tourId,required this.goNow});

  @override
  State<checkout> createState() => _checkoutState();
}

class _checkoutState extends State<checkout> {
  late ColorNotifier notifier;
  late UserProvider userProvider;

  bool masterCard = false;
  bool visa = false;
  bool withTaxNumber = false;
  bool onlyElectricVehicles = false;
  bool smallPriceSelected = true;
  bool guideFeaturesSaved = false;
  List checkedLanguages = List<Object>.generate(guideLanguages.length, (i) => { ...guideLanguages[i], "value": false });
  final taxNumberController = TextEditingController();
  String? pickupPointSelected;

  Color smallPriceColor = LogoColor;
  Color highPriceColor = greyColor;

  DateTime? selectedDate;
  int hourSliderValue = 9;
  int minutesSliderValue = 0;


  bool timeSaved = false;
  int? guidesAvailable;

  Tour? tour;
  List<Tour> tours = [];
  int carrosselDefaultPage = 0;

  DocumentReference? guideRef;

  Query<Map<String, dynamic>> guides = FirebaseFirestore.instance.collection("users")
      .where("accountValidated", isEqualTo: true);

  CollectionReference<Map<String, dynamic>> unavailability = FirebaseFirestore.instance.collection("unavailability");

  @override
  void initState() {
    guidesAvailable = 0;
    tour = tourList.firstWhere((tour) => tour.id == widget.tourId);
    getdarkmodepreviousstate();
    super.initState();
  }

  void changeButtonColor() {
    setState(() {
      smallPriceSelected = !smallPriceSelected;
      smallPriceColor = smallPriceSelected ? LogoColor : greyColor;
      highPriceColor = smallPriceSelected ? greyColor : LogoColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.goNow){
      tours.addAll(tourList);
      carrosselDefaultPage = tourList.indexOf(tour!);
    }

    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "Checkout${widget.goNow ? " - GoNow" : ""}" ,
              ActionIcon: Icons.more_vert,
              bgcolor: notifier.getbgcolor,
              actioniconcolor: notifier.getwhiteblackcolor,
              leadingiconcolor: notifier.getwhiteblackcolor,
              titlecolor: notifier.getwhiteblackcolor)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.goNow)
                ...[Text("The GoNow solution allows you to make a reservation for today",
                      style: TextStyle(
                          fontSize: 14,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold")),
                  const SizedBox(height: 10)
                ],
              if (widget.goNow)
                CarouselSlider(
                options: CarouselOptions(
                    height: 110.0,
                    initialPage: carrosselDefaultPage,
                    viewportFraction: 0.9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        pickupPointSelected = null;
                        tour = tourList[index%4];
                      });
                    }),
                items: tours.map((t) {
                  return Builder(
                    builder: (BuildContext context) {
                      return tourInfo(t);
                    },
                  );
                }).toList(),
              )
              else
                tourInfo(tour),
              if (!widget.goNow && selectedDate != null)
                Text("Guides available: $guidesAvailable",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Gilroy Medium",
                        color: notifier.getwhiteblackcolor)),
              Divider(
                color: notifier.getgreycolor,
                thickness: 2,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      changeButtonColor();
                      checkGuidesAvailability();
                    },
                    child: Container(
                      height: 50,
                      width: 125,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: smallPriceColor),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            Text("1-3 persons",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WhiteColor,
                                    fontFamily: "Gilroy Bold")),
                            Text("${tour?.priceLow}€",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WhiteColor,
                                    fontFamily: "Gilroy Bold"))
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      changeButtonColor();
                      checkGuidesAvailability();
                    },
                    child: Container(
                      height: 50,
                      width: 125,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: highPriceColor),
                      child: Center(
                        child: Column(
                            children: [
                              const SizedBox(height: 5),
                              Text("4-6 persons",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WhiteColor,
                                    fontFamily: "Gilroy Bold")),
                              Text("${tour?.priceHigh}€",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WhiteColor,
                                    fontFamily: "Gilroy Bold"))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.goNow)
                ...[const SizedBox(height: 10),
                  selectDetail(
                    heading: "Pickup Point",
                    image: "assets/images/location.png",
                    text: pickupPointSelected ?? "Select Pickup Point",
                    icon: Icons.keyboard_arrow_down,
                    onclick: () {
                      pickupPointBottomSheet(tour!.starPoints.map((value) => value["name"].toString()).toList());
                    },
                    notifier: notifier
                )],
              if (!widget.goNow)
                ...[ const SizedBox(height: 5),
                selectDetail(
                  heading: "Date",
                  image: "assets/images/calendar.png",
                  text: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : "Select Dates",
                  icon: Icons.keyboard_arrow_down,
                  onclick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Calendar(selectedDate: selectedDate,
                              minDate: DateTime.now().add(const Duration(days: 1)),
                              maxDate: DateTime.now().add(const Duration(days: 32))),
                    )).then((value) {
                      checkGuidesAvailability();
                      setState(() {
                        selectedDate = value; // you receive here
                      });
                    });
                  },
                  notifier: notifier
                )],
              const SizedBox(height: 10),
              selectDetail(
                  heading: "Time",
                  image: "assets/images/timer.png",
                  text: timeSaved
                      ? "$hourSliderValue:${minutesSliderValue == 0
                      ? "00"
                      : minutesSliderValue.toString()}"
                      : "Select Time",
                  icon: Icons.keyboard_arrow_down,
                  onclick: () {
                    if (selectedDate != null) {
                      timerBottomSheet();
                    }
                  },
                  notifier: notifier),
              const SizedBox(height: 10),
              selectDetail(
                  heading: "Guide Features",
                  image: "assets/images/guest.png",
                  text: guideFeaturesSaved ? getAllSelectedLanguages() : "Select Guide Features",
                  icon: Icons.keyboard_arrow_down,
                  onclick: () {
                    guideBottomSheet().then((value) {
                      setState(() => guideFeaturesSaved = value ?? false);
                      checkGuidesAvailability();
                    });
                  },
                  notifier: notifier),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Invoice with tax number",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Gilroy Bold",
                          color: notifier.getwhiteblackcolor),
                    ),
                    Theme(
                      data: ThemeData(
                          unselectedWidgetColor:
                          notifier.getdarkwhitecolor),
                      child: Checkbox(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        value: withTaxNumber,
                        onChanged: (value) {
                          setState(() {
                            withTaxNumber = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (withTaxNumber)
                ...[
                  textfield(
                    controller: taxNumberController,
                    fieldColor: notifier.getfieldcolor,
                    hintColor: notifier.gettextfieldcolor,
                    text: 'Tax number',
                    suffix: null),
                ],
              Divider(
                color: notifier.getgreycolor,
                thickness: 1,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payment Details",
                      style: TextStyle(
                          fontSize: 16,
                          color: LogoColor,
                          fontFamily: "Gilroy Bold")),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tour (Payment made to the guide)",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Gilroy Medium",
                            color: notifier.getwhiteblackcolor),
                      ),
                      Text(
                          "${tour?.getTourPrice(smallPriceSelected)}€",
                        style: TextStyle(
                            fontSize: 14,
                            color: notifier.getwhiteblackcolor,
                            fontFamily: "Gilroy Medium"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Booking Fee",
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Gilroy Medium",
                              color: notifier.getwhiteblackcolor)),
                      Text("${tour?.getFeePrice(smallPriceSelected)}€",
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Gilroy Medium",
                              color: notifier.getwhiteblackcolor)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total (EUR)",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Gilroy Bold",
                              color: notifier.getwhiteblackcolor)),
                      Text("${tour?.getTotalPrice(smallPriceSelected)}€",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Gilroy Bold",
                              color: notifier.getwhiteblackcolor)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  InkWell(
                    onTap: () => {
                      if (selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a date to proceed.'),
                          )
                        )
                      } else {
                        paymentModelBottomSheet(guideRef!)
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color:Darkblue),
                      child: Center(
                        child: Text("Select Payment",
                            style: TextStyle(
                                fontSize: 16,
                                color: WhiteColor,
                                fontFamily: "Gilroy Bold")),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkGuidesAvailability() {
    if(selectedDate != null) {
      String date = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final data = unavailability.doc(date);
      data.get().then((querySnapshot) {
        Set<String> guidesUnavailable = {};
        for(int i = 0; i < tour!.durationSlots; i++) {
          // Calculate total minutes from the starting point
          int totalMinutes = (hourSliderValue * 60) + minutesSliderValue + (i * 30);
          int newHour = totalMinutes ~/ 60; // Integer division to get hours
          int newMinutes = totalMinutes % 60; // Remainder to get minutes
          String hour = '${newHour.toString().padLeft(2, '0')}:${newMinutes.toString().padLeft(2, '0')}';
          final fieldData = querySnapshot.data()?[hour];
          if (fieldData != null && fieldData is List) {
            for (var doc in fieldData) {
              guidesUnavailable.add(doc);
            }
          }
        }
        filterGuides(guidesUnavailable.toList());
      });
    }
    else {
      filterGuides([]);
    }
  }

  void filterGuides(List<String> guidesUnavailable) {
    List<String?> currentSelectedLanguages = checkedLanguages.map((item) => item["value"] ? item["code"].toString().toLowerCase() : null)
        .where((item) => item != null)
        .toList();

    guides
        .where("tuktukElectric", whereIn: onlyElectricVehicles ? [true] : [true, false])
        .where("tuktukSeats", isGreaterThanOrEqualTo: smallPriceSelected ? 3 : 6)
        .where("language", arrayContainsAny: currentSelectedLanguages.isNotEmpty ? currentSelectedLanguages : checkedLanguages.map((item) => item["code"].toString().toLowerCase()).toList())
        .orderBy("rating", descending: true).get().then((querySnapshot) {
      setState(() {
        List<QueryDocumentSnapshot> filteredGuides = querySnapshot.docs.where((doc) {
          return !guidesUnavailable.contains(doc.id);
        }).toList();

        guideRef = filteredGuides.isNotEmpty ? filteredGuides[0].reference : null;
        guidesAvailable = filteredGuides.length;
      });
    });
  }

  Widget tourInfo(t) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: notifier.getdarkmodecolor,
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            height: 80,
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                tour!.icon,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.012),
              Text(
                t.name.toUpperCase(),
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Gilroy Bold",
                    color: notifier.getwhiteblackcolor),
              ),
              // const SizedBox(height: 6),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.006),
              Text(
                t.address,
                style: TextStyle(
                    fontSize: 14,
                    color: notifier.getwhiteblackcolor,
                    fontFamily: "Gilroy Medium"),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.001),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 150),
                      Image.asset(
                        "assets/images/star.png",
                        height: 20,
                      ),
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          children: [
                            Text(
                              tour!.review.toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: notifier.getdarkbluecolor,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }


  guideBottomSheet() {
    return showModalBottomSheet(
        backgroundColor: notifier.getbgcolor,
        isScrollControlled: true,
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Guide Features",
                          style: TextStyle(
                              fontFamily: "Gilroy Bold",
                              fontSize: 18,
                              color: notifier.getwhiteblackcolor),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.close,
                              color: notifier.getwhiteblackcolor,
                            ))
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01),
                    selectDetail(
                        heading: "Preferred language",
                        image: "assets/images/language.png",
                        text: guideFeaturesSaved ? getAllSelectedLanguages() : "Select Language",
                        icon: Icons.keyboard_arrow_right,
                        onclick: languagesBottomSheet,
                        notifier: notifier),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vehicle Type",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: notifier.getwhiteblackcolor,
                                  fontFamily: "Gilroy Bold"),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Only Electric vehicles (EV)",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: greyColor,
                                  fontFamily: "Gilroy Medium"),
                            ),
                          ],
                        ),
                        Container(
                          height: 42.0,
                          width: 60.0,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CupertinoSwitch(
                                value: onlyElectricVehicles,
                                thumbColor: notifier.getdarkwhitecolor,
                                trackColor: notifier.getbuttoncolor,
                                activeColor: notifier.getdarkbluecolor,
                                onChanged: (value) {
                                  setState(() {
                                    onlyElectricVehicles = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    AppButton(
                        buttontext: "Continue",
                        onclick: () {
                          Navigator.pop(context, true);
                        })
                  ],
                ),
              ),
            );
          });
        });
  }

  timerBottomSheet() {
    showModalBottomSheet(
        backgroundColor: notifier.getbgcolor,
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Hours",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: BlackColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                NumberPicker(
                                  value: hourSliderValue,
                                  minValue: 8,
                                  maxValue: 19,
                                  onChanged: (value) => setState(() => hourSliderValue = value),
                                )
                              ]
                            ),
                            Column(
                            children: [
                              Text(
                                "Minutes",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: BlackColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              NumberPicker(
                                value: minutesSliderValue,
                                minValue: 0,
                                maxValue: 30,
                                step: 30,
                                onChanged: (value) => setState(() => minutesSliderValue = value),
                              )
                            ])
                          ]),
                      const SizedBox(height: 20),
                      Row(
                        // left: 100,
                        children: [InkWell(
                          onTap: () {
                            checkGuidesAvailability();
                            Navigator.pop(context, true);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Darkblue,
                            ),
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.93,
                            child: Center(
                                child: Text(
                              "Continue",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: WhiteColor,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        )
                        ]
                      ),
                    ],
                  ),
                )
            );
          });
        }).then((value) => setState(() { timeSaved = value; }));
  }

  languagesBottomSheet() {
    return showModalBottomSheet(
        backgroundColor: notifier.getbgcolor,
        context: context,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 0, bottom: 80),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Preferred Languages",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Gilroy Bold",
                                      color: notifier.getwhiteblackcolor),
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: notifier.getwhiteblackcolor,
                                    ))
                              ],
                            ),
                            const SizedBox(height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: checkedLanguages.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    language(
                                      text: checkedLanguages[index]["name"],
                                      CheckValue: checkedLanguages[index]["value"],
                                      OnChange: (value) {
                                        setState(() {
                                          checkedLanguages[index]["value"] = value!;
                                        });
                                      },
                                    )
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 40),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context, true);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Darkblue,
                                ),
                                height: 60,
                                width: MediaQuery.of(context).size.width * 0.93,
                                child: Center(
                                    child: Text(
                                      "Continue",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: WhiteColor,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        }).then((value) => setState(() { guideFeaturesSaved = value; }));
  }

  pickupPointBottomSheet(List<String> pickupPoints) {
    int selectedIndex = pickupPointSelected != null ? pickupPoints.indexOf(pickupPointSelected!) : 0;
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 220.0,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                height: 150.0,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  children: List<Widget>.generate(pickupPoints.length, (int index) {
                    return Center(
                      child: Text(
                        pickupPoints[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: const Text('Confirm'),
                onPressed: () {
                  setState(() {
                    pickupPointSelected = pickupPoints[selectedIndex];
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  paymentModelBottomSheet(DocumentReference guideRef) {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: notifier.getbgcolor,
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (context) {
          return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Payment Method",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Gilroy Bold",
                                            color: notifier.getwhiteblackcolor),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Icon(
                                            Icons.close,
                                            color: notifier.getwhiteblackcolor,
                                          ))
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: notifier.getdarkmodecolor),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/images/mastercard.png",
                                            height: 25,
                                          ),
                                          const SizedBox(width: 25),
                                          Text(
                                            "Master Card",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Gilroy Bold",
                                                color: notifier.getwhiteblackcolor),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context).size.width /
                                                  2.82),
                                          Theme(
                                            data: ThemeData(
                                                unselectedWidgetColor:
                                                notifier.getdarkwhitecolor),
                                            child: Checkbox(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5)),
                                              value: masterCard,
                                              onChanged: (value) {
                                                setState(() {
                                                  masterCard = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.03),
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: notifier.getdarkmodecolor),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/images/Visa.png",
                                            height: 25,
                                          ),
                                          const SizedBox(width: 27),
                                          Text(
                                            "Visa",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Gilroy Bold",
                                                color: notifier.getwhiteblackcolor),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context).size.width /
                                                  1.98),
                                          Theme(
                                            data: ThemeData(
                                                unselectedWidgetColor:
                                                notifier.getdarkwhitecolor),
                                            child: Checkbox(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5)),
                                              value: visa,
                                              onChanged: (value) {
                                                setState(() {
                                                  visa = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.03),
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: notifier.getdarkmodecolor),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: notifier.getgreycolor),
                                          child: Center(
                                            child: CircleAvatar(
                                                backgroundColor:
                                                notifier.getdarkbluecolor,
                                                radius: 14,
                                                child: Image.asset(
                                                    "assets/images/add.png",
                                                    height: 25)),
                                          ),
                                        ),
                                        const SizedBox(width: 33),
                                        Text("Add Debit Card",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Gilroy Bold",
                                                color: notifier.getwhiteblackcolor)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.12),
                                  AppButton(
                                      buttontext: "Confirm and Pay",
                                      onclick: () async {
                                        bool resultOk = await bookTour();
                                        if (resultOk) {
                                          return bookingSuccessfully(guideRef);
                                        }
                                      })
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
        });
  }

  bookingSuccessfully(DocumentReference guideRef) {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: notifier.getbgcolor,
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.60,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 20,
                        child: CircleAvatar(
                          radius: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.asset(
                                'assets/images/BookingSuccessfull.png'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -28,
                        right: 50,
                        child: Image.asset(
                          'assets/images/Success.png',
                          height: 160,
                        ),
                      ),
                      Positioned(
                        bottom: 100,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "Booking Successfull",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: "Gilroy Bold",
                                    color: notifier.getwhiteblackcolor),
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: Text(
                                "Congratulations! Enjoy your trip!",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: notifier.getgreycolor,
                                    fontFamily: "Gilroy Medium"),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 300, left: 20, right: 20),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Darkblue,
                          ),
                          child: Center(
                              child: Text("Close",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: WhiteColor,
                                      fontFamily: "Gilroy Bold"))),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }


  // PaymentCard(
  //     {Function(bool?)? OnChage, String? image, CardName, bool? check}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           Image.asset(
  //             image!,
  //             height: 25,
  //           ),
  //           Text(
  //             CardName,
  //             style: TextStyle(fontSize: 15, fontFamily: "Gilroy Bold"),
  //           ),
  //         ],
  //       ),
  //       SizedBox(width: 25),

  //       // SizedBox(width: MediaQuery.of(context).size.width / 2.61),
  //       Row(
  //         children: [
  //           Checkbox(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(5)),
  //               value: check,
  //               activeColor: Darkblue,
  //               onChanged: OnChage!),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previusstate;
    }
  }


  language(
      {Function(bool?)? OnChange, bool? CheckValue, String? text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text!,
          style: TextStyle(
              fontSize: 15, color: greyColor, fontFamily: "Gilroy Medium"),
        ),
        const SizedBox(width: 25),
        SizedBox(
          height: 35,
          width: 35,
          child: Theme(
            data: ThemeData(unselectedWidgetColor: notifier.getwhiteblackcolor),
            child: Checkbox(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: notifier.getwhiteblackcolor)),
                value: CheckValue,
                onChanged: OnChange),
          ),
        ),
      ],
    );
  }

  getAllSelectedLanguages() {
    String selectedLanguages = "";
    for (var element in checkedLanguages) {
      if(element["value"]) {
        selectedLanguages =  element["code"] + (selectedLanguages.isNotEmpty ? " " : "") + selectedLanguages;
      }
    }
    return selectedLanguages;
  }

  Future<bool> bookTour() async {
    try {
      selectedIndex = 0;
      if (widget.goNow) {
        selectedDate = DateTime.now();
      }
      await Trip.addTrip(
          widget.goNow ? null : guideRef,
          tour!.id,
          selectedDate!.copyWith(
              hour: hourSliderValue, minute: minutesSliderValue, second: 0, millisecond: 0, microsecond: 0),
          smallPriceSelected ? 3 : 6,
          widget.goNow ? 'pending' : 'booked',
          getAllSelectedLanguages(),
          masterCard ? 'mastercard' : 'visa',
          '',
          withTaxNumber,
          taxNumberController.text,
          onlyElectricVehicles
          ).then((docRef) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TripDetail(docRef.id, false)),
            (Route<dynamic> route) => route.isFirst, // Keep only the homepage
          );
      });

      if (!widget.goNow) {
        await AppUser.updateTripUnavailability(guideRef!.id, tour!, selectedDate!, hourSliderValue, minutesSliderValue);
      }

      return true;
    } on Exception catch (_, e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return false;
    }
  }
}
