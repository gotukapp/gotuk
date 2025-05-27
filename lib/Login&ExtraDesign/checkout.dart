// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Login&ExtraDesign/calendar.dart';
import 'package:dm/Login&ExtraDesign/homepage.dart';
import 'package:dm/Login&ExtraDesign/tripDetail.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Domain/trip.dart';
import 'package:dm/Utils/customwidget.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Domain/appUser.dart';
import '../Domain/tour.dart';
import '../Domain/point.dart';
import '../Providers/userProvider.dart';
import '../Utils/stripe.dart';
import '../Utils/util.dart';

class checkout extends StatefulWidget {
  final String tourId;
  final bool fromHome;

  const checkout({super.key,required this.tourId, required this.fromHome});

  @override
  State<checkout> createState() => _checkoutState();
}

class _checkoutState extends State<checkout> {
  late ColorNotifier notifier;
  late UserProvider userProvider;

  bool goNow = false;
  bool masterCard = false;
  bool visa = false;
  bool withTaxNumber = false;
  bool onlyElectricVehicles = false;
  bool smallPriceSelected = true;
  bool guideFeaturesSaved = false;
  List checkedLanguages = List<Object>.generate(guideLanguages.length, (i) => { ...guideLanguages[i], "value": false });
  final taxNumberController = TextEditingController();
  String? selectedPickupPointName;
  bool executingPayment = false;

  Color smallPriceColor = LogoColor;
  Color highPriceColor = greyColor;

  DateTime? selectedDate;
  int hourSliderValue = 9;
  int minutesSliderValue = 0;
  int minimumHourSlider = 9;
  int maximumHourSlider = 19;
  DateTime minimumDate = DateTime.now();
  DateTime maximumDate = DateTime.now().add(const Duration(days: 32));

  bool timeSaved = false;
  int? guidesAvailable;

  Tour? tour;
  List<Tour> tours = [];
  int carrosselDefaultPage = 0;
  String? newTripId;

  DocumentReference? selectedGuideRef;

  Query<Map<String, dynamic>> guides = FirebaseFirestore.instance.collection("users")
      .where("accountValidated", isEqualTo: true);

  CollectionReference<Map<String, dynamic>> unavailability = FirebaseFirestore.instance.collection("unavailability");

  @override
  void initState() {
    guidesAvailable = 0;
    tour = Tour.availableTours.firstWhere((tour) => tour.id == widget.tourId);
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
    tours.addAll(Tour.availableTours);
    carrosselDefaultPage = Tour.availableTours.indexOf(tour!);

    if (DateTime.now().hour >= 19) {
      minimumDate = DateTime.now().add(const Duration(days: 1));
    }

    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: AppLocalizations.of(context)!.bookTour ,
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
              if (widget.fromHome)
                CarouselSlider(
                options: CarouselOptions(
                    height: 110.0,
                    initialPage: carrosselDefaultPage,
                    viewportFraction: 0.9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        selectedPickupPointName = null;
                        tour = Tour.availableTours[index%4];
                      });
                    }),
                items: tours.map((t) {
                  return Builder(
                    builder: (BuildContext context) {
                      return tourInfo(context, notifier, t);
                    },
                  );
                }).toList(),
              )
              else
                tourInfo(context, notifier, tour!),
              if (timeSaved)
                Text("${AppLocalizations.of(context)!.guidesAvailable} $guidesAvailable",
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Gilroy Bold",
                        color: LogoColor)),
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
                            Text("1-4 ${AppLocalizations.of(context)!.persons}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WhiteColor,
                                    fontFamily: "Gilroy Bold")),
                            Text("${tour?.lowPrice}€",
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
                              Text("5-6 ${AppLocalizations.of(context)!.persons}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: WhiteColor,
                                    fontFamily: "Gilroy Bold")),
                              Text("${tour?.highPrice}€",
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
              const SizedBox(height: 5),
              selectDetail(
                  heading: AppLocalizations.of(context)!.date,
                  image: "assets/images/calendar.png",
                  text: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : AppLocalizations.of(context)!.selectDate,
                  icon: Icons.keyboard_arrow_down,
                  onclick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Calendar(selectedDate: selectedDate,
                          minDate: minimumDate,
                          maxDate: maximumDate),
                    )).then((value) {
                      if (value != null) {
                        setState(() {
                          goNow = isGoNow(value);
                          selectedDate = value;
                        });
                      }
                    });
                  },
                  notifier: notifier
              ),
              const SizedBox(height: 10),
              selectDetail(
                  heading: AppLocalizations.of(context)!.time,
                  image: "assets/images/timer.png",
                  text: timeSaved
                      ? "$hourSliderValue:${minutesSliderValue == 0
                      ? "00"
                      : minutesSliderValue.toString()}"
                      : AppLocalizations.of(context)!.selectTime,
                  icon: Icons.keyboard_arrow_down,
                  onclick: () {
                    if (selectedDate != null) {
                      timerBottomSheet();
                    }
                  },
                  notifier: notifier),
              const SizedBox(height: 10),
              selectDetail(
                  heading: AppLocalizations.of(context)!.pickupPoint,
                  image: "assets/images/location.png",
                  text: selectedPickupPointName ?? AppLocalizations.of(context)!.selectPickupPoint,
                  icon: Icons.keyboard_arrow_down,
                  onclick: () {
                    pickupPointBottomSheet(tour!.pickupPoints!);
                  },
                  notifier: notifier
              ),
              const SizedBox(height: 10),
              selectDetail(
                  heading: AppLocalizations.of(context)!.guideFeatures,
                  image: "assets/images/guest.png",
                  text: guideFeaturesSaved ? getAllSelectedLanguages() : AppLocalizations.of(context)!.selectGuideFeatures,
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
                      AppLocalizations.of(context)!.invoiceWithTaxNumber,
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
                  textField(
                    controller: taxNumberController,
                    fieldColor: WhiteColor,
                    hintColor: notifier.getdarkgreycolor,
                    text: AppLocalizations.of(context)!.taxNumber,
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
                  Text(AppLocalizations.of(context)!.paymentDetails,
                      style: TextStyle(
                          fontSize: 16,
                          color: LogoColor,
                          fontFamily: "Gilroy Bold")),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.tourPrice,
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
                      Text(AppLocalizations.of(context)!.bookingPrice,
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
                      Text(AppLocalizations.of(context)!.totalPrice,
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
                    onTap: () {
                      if (!executingPayment) {
                        bool isOK = validateBookingParameters(context);
                        if (isOK) {
                          Query<Map<String, dynamic>> pendingTours = Trip
                              .getPendingTours();
                          pendingTours.get().then((result) async {
                            List<QueryDocumentSnapshot<
                                Map<String, dynamic>>> tours = result.docs;
                            DateTime tripDate = selectedDate!.copyWith(
                                hour: hourSliderValue,
                                minute: minutesSliderValue,
                                second: 0,
                                millisecond: 0,
                                microsecond: 0);
                            final docs = tours.where((d) {
                              Trip t = Trip.fromFirestore(d, null);
                              return t.date
                                  .difference(tripDate)
                                  .inMinutes
                                  .abs() <= 120;
                            });
                            if (docs.isNotEmpty) {
                              bool resultYes = await showConfirmationMessage(
                                  context,
                                  AppLocalizations.of(context)!.bookingTour,
                                  AppLocalizations.of(context)!.duplicatedTourWarning,
                                      () {}, () {},
                                  AppLocalizations.of(context)!.yes,
                                  AppLocalizations.of(context)!.no);
                              if (resultYes) {
                                paymentModelBottomSheet(selectedGuideRef!);
                              }
                            } else {
                              paymentModelBottomSheet(selectedGuideRef!);
                            }
                          });
                        }
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color:Darkblue),
                      child: Center(
                        child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (executingPayment)
                                ...[CircularProgressIndicator(color: WhiteColor),
                                  const SizedBox(width: 10),
                                ],
                              Text(AppLocalizations.of(context)!.proceedToPayment,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: WhiteColor,
                                      fontFamily: "Gilroy Bold"))
                            ],
                          ),
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
        .where("tuktukSeats", isGreaterThanOrEqualTo: smallPriceSelected ? 4 : 6)
        .where("language", arrayContainsAny: currentSelectedLanguages.isNotEmpty ? currentSelectedLanguages : checkedLanguages.map((item) => item["code"].toString().toLowerCase()).toList())
        .orderBy("tuktukSeats", descending: false)
        .orderBy("rating", descending: true).get().then((querySnapshot) {
      setState(() {
        List<QueryDocumentSnapshot> filteredGuides = querySnapshot.docs.where((doc) {
          return !guidesUnavailable.contains(doc.id);
        }).toList();

        selectedGuideRef = selectGuide(filteredGuides, smallPriceSelected ? 4 : 6);
        guidesAvailable = filteredGuides.length;

      });
    });
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
                          AppLocalizations.of(context)!.guideFeatures,
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
                        heading: AppLocalizations.of(context)!.preferredLanguage,
                        image: "assets/images/language.png",
                        text: guideFeaturesSaved ? getAllSelectedLanguages() : AppLocalizations.of(context)!.selectLanguages,
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
                              AppLocalizations.of(context)!.vehicleType,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: notifier.getwhiteblackcolor,
                                  fontFamily: "Gilroy Bold"),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context)!.onlyElectricVehicles,
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
                                //keep this with deprecated attribute
                                //Error: No named parameter with the name 'inactiveTrackColor'.
                                //inactiveTrackColor: notifier.getbuttoncolor
                                //We need to update CupertinoSwitch
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
                        buttontext: AppLocalizations.of(context)!.proceed,
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
    validateHoursRange();
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
                                Text(AppLocalizations.of(context)!.hours,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: BlackColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                NumberPicker(
                                  value: hourSliderValue,
                                  minValue: minimumHourSlider,
                                  maxValue: maximumHourSlider,
                                  onChanged: (value) => setState(() => hourSliderValue = value),
                                )
                              ]
                            ),
                            Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.minutes,
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
                                  AppLocalizations.of(context)!.proceed,
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
                                  AppLocalizations.of(context)!.preferredLanguage,
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
                                      text: AppLocalizations.of(context)!.countryLanguage(checkedLanguages[index]["name"]),
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
                                      AppLocalizations.of(context)!.proceed,
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

  pickupPointBottomSheet(List<Point> pickupPoints) {
    List<String> pickupPointsNames = pickupPoints.map((p) => p.name).toList();
    int selectedIndex = selectedPickupPointName != null ? pickupPointsNames.indexOf(selectedPickupPointName!) : 0;
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
                        pickupPointsNames[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text(AppLocalizations.of(context)!.confirm),
                onPressed: () {
                  setState(() {
                    selectedPickupPointName = pickupPointsNames[selectedIndex];
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

  paymentModelBottomSheet(DocumentReference guideRef) async {
    setState(() {
      executingPayment = true;
    });
    try {
      var paymentIntent = await createStripPayment(
        amount: (tour!.getFeePrice(smallPriceSelected) * 100).toInt(),
        currency: "eur"
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent,
          merchantDisplayName: "GoTuk",
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      bool resultOk = await bookTour(getPaymentIntentId(paymentIntent!));
      if (resultOk) {
        return bookingSuccessfully(guideRef);
      }
      setState(() {
        executingPayment = false;
      });
    } catch (error) {
      await Sentry.captureException(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() {
        executingPayment = false;
      });
    }
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
                                AppLocalizations.of(context)!.bookingConfirmation,
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
                                AppLocalizations.of(context)!.bookingCongratulations,
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => TripDetail(newTripId!)),
                                (Route<dynamic> route) => route.isFirst, // Keep only the homepage
                          );
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
                              child: Text(AppLocalizations.of(context)!.proceed,
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

  Future<bool> bookTour(paymentId) async {
    try {
      selectedIndex = 0;

      DateTime tripDate = selectedDate!.copyWith(
          hour: hourSliderValue, minute: minutesSliderValue, second: 0, millisecond: 0, microsecond: 0);

      DocumentReference docRef = await Trip.addTrip(
          goNow ? null : selectedGuideRef,
          tour!.id,
          tripDate,
          smallPriceSelected ? 4 : 6,
          goNow ? 'pending' : 'booked',
          getAllSelectedLanguages(),
          masterCard ? 'mastercard' : 'visa',
          '',
          withTaxNumber,
          taxNumberController.text,
          onlyElectricVehicles,
          goNow ? 'gonow' : 'booking',
          tour!.getFeePrice(smallPriceSelected),
          tour!.getTourPrice(smallPriceSelected),
          selectedPickupPointName!,
          paymentId);

      newTripId = docRef.id;

      if (!goNow) {
        await AppUser.updateUserUnavailability(selectedGuideRef!.id, tour!, selectedDate!, hourSliderValue, minutesSliderValue, false);
      }

      return true;
    } on Exception catch (_, e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return false;
    }
  }

  bool isGoNow(value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final inputDate = DateTime(value.year, value.month, value.day);

    if (inputDate == today && now.hour <= 19) {
      return true;
    } else if (inputDate == tomorrow && now.hour >= 19) {
      return true;
    }
    return false;
  }

  void validateHoursRange() {
    if (isGoNow(selectedDate) && DateTime.now().hour <= 19) {
      minimumHourSlider = DateTime.now().hour + 1;
    } else {
      minimumHourSlider = 9;
    }
    hourSliderValue = hourSliderValue < minimumHourSlider ? minimumHourSlider : hourSliderValue;
  }

  bool validateBookingParameters(BuildContext context) {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectDateWarning),
          )
      );
      return false;
    } else if (!timeSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectTimeWarning),
          )
      );
      return false;
    } else if (selectedPickupPointName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectPickupPointWarning),
          )
      );
      return false;
    } else if (selectedGuideRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noGuideAvailableWarning),
          )
      );
      return false;
    }
    return true;
  }

  getPaymentIntentId(String paymentIntent) {
    return paymentIntent.substring(0, paymentIntent.indexOf("_secret_"));
  }
}
