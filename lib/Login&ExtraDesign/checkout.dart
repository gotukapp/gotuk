// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, camel_case_types

import 'package:dm/Login&ExtraDesign/calendar.dart';
import 'package:dm/Login&ExtraDesign/homepage.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/booking.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../Utils/tour.dart';

class checkout extends StatefulWidget {
  final int tourId;
  final bool goNow;

  const checkout({super.key,required this.tourId,required this.goNow});

  @override
  State<checkout> createState() => _checkoutState();
}

class _checkoutState extends State<checkout> {
  bool isChecked = false;
  bool isChecked1 = false;
  bool withTaxNumber = false;
  bool vehicleTypeSwitchValue = false;
  bool smallPriceSelected = true;

  bool guideFeaturesSaved = false;
  List checkedLanguages = List<Object>.generate(languages.length, (i) => { ...languages[i], "value": false });

  Color smallPriceColor = LogoColor;
  Color highPriceColor = greyColor;

  DateTime? selectedDate;
  int hourSliderValue = DateTime.now().hour < 9 ? 9 : (DateTime.now().hour > 21 ? 21 : DateTime.now().hour);
  int minutesSliderValue = 0;


  bool timeSaved = false;

  Tour? tour;
  List tours = [];
  int carrosselDefaultPage = 0;

  @override
  void initState() {
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

  late ColorNotifire notifire;
  @override
  Widget build(BuildContext context) {
    setState(() {
      tour = tourList.firstWhere((tour) => tour.id == widget.tourId);
    });
    if(widget.goNow){
      tours.addAll(tourList);
      carrosselDefaultPage = tourList.indexOf(tour);
    }
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "Checkout",
              ActionIcon: Icons.more_vert,
              bgcolor: notifire.getbgcolor,
              actioniconcolor: notifire.getwhiteblackcolor,
              leadingiconcolor: notifire.getwhiteblackcolor,
              titlecolor: notifire.getwhiteblackcolor)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.goNow)
                CarouselSlider(
                options: CarouselOptions(
                    height: 110.0,
                    initialPage: carrosselDefaultPage,
                    viewportFraction: 0.9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        tour = tourList[index%5];
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
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () { changeButtonColor(); },
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
                    onTap: () { changeButtonColor();  },
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
              if (!widget.goNow)
                ...[const SizedBox(height: 15),
                selectdetail(
                  heding: "Date",
                  image: "assets/images/calendar.png",
                  text: selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : "Select Dates",
                  icon: Icons.keyboard_arrow_down,
                  onclick: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => calendar(),
                    )).then((value) {
                      setState(() {
                        selectedDate = value; // you receive here
                      });
                    });
                  },
                ),
                const SizedBox(height: 10),
                selectdetail(
                    heding: "Time",
                    image: "assets/images/timer.png",
                    text: timeSaved
                        ? "$hourSliderValue:${minutesSliderValue == 0
                        ? "00"
                        : minutesSliderValue.toString()}"
                        : "Select Time",
                    icon: Icons.keyboard_arrow_down,
                    onclick: timerBottomSheet)],
              if (widget.goNow)
                ...[const SizedBox(height: 10),
                  Text("Go Now",
                      style: TextStyle(
                          fontSize: 16,
                          color: notifire.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold")),
                  const SizedBox(height: 8),
                  Text(" ....  Explicação de como funciona ....",
                      style: TextStyle(
                          fontSize: 14,
                          color: notifire.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold")),
                ],
              const SizedBox(height: 10),
              selectdetail(
                  heding: "Guide Features",
                  image: "assets/images/guest.png",
                  text: guideFeaturesSaved ? getAllSelectedLanguages() : "Select Guide Features",
                  icon: Icons.keyboard_arrow_down,
                  onclick: guideBottomSheet),
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
                          color: notifire.getwhiteblackcolor),
                    ),
                    Theme(
                      data: ThemeData(
                          unselectedWidgetColor:
                          notifire.getdarkwhitecolor),
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
                      feildcolor: notifire.getfieldcolor,
                      hintcolor: notifire.gettextfieldcolor,
                      text: 'Tax number',
                      prefix: Image.asset("assets/images/call.png",
                          height: 20, color: notifire.getgreycolor),
                      suffix: null),
                ],
              Divider(
                color: notifire.getgreycolor,
                thickness: 1,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                            color: notifire.getwhiteblackcolor),
                      ),
                      Text(
                          "${tour?.getTourPrice(smallPriceSelected)}€",
                        style: TextStyle(
                            fontSize: 14,
                            color: notifire.getwhiteblackcolor,
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
                              color: notifire.getwhiteblackcolor)),
                      Text("${tour?.getFeePrice(smallPriceSelected)}€",
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Gilroy Medium",
                              color: notifire.getwhiteblackcolor)),
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
                              color: notifire.getwhiteblackcolor)),
                      Text("${tour?.getTotalPrice(smallPriceSelected)}€",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Gilroy Bold",
                              color: notifire.getwhiteblackcolor)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  InkWell(
                    onTap: paymentmodelbottomsheet,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tourInfo(t) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: notifire.getdarkmodecolor,
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: notifire.getdarkmodecolor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
              Image.asset(tour!.icon),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.012),
              Text(
                t.title,
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Gilroy Bold",
                    color: notifire.getwhiteblackcolor),
              ),
              // const SizedBox(height: 6),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.006),
              Text(
                t.address,
                style: TextStyle(
                    fontSize: 13,
                    color: notifire.getgreycolor,
                    fontFamily: "Gilroy Medium"),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 12,),
                      Image.asset(
                        "assets/images/star.png",
                        height: 20,
                      ),
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text(
                              "4.6",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: notifire.getdarkbluecolor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "(142 Reviews)",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: notifire.getgreycolor),
                            ),
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

  Widget selectdetail({heding, image, text, icon, onclick}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heding!,
            style: TextStyle(
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
                fontFamily: "Gilroy Bold")),
        const SizedBox(height: 8),
        InkWell(
          onTap: onclick,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: notifire.getdarkmodecolor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        image,
                        height: 25,
                        color: LogoColor,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        text,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Gilroy Medium",
                            color: notifire.getwhiteblackcolor),
                      ),
                    ],
                  ),
                  Icon(icon, color: notifire.getgreycolor)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  guideBottomSheet() {
    return showModalBottomSheet(
        backgroundColor: notifire.getbgcolor,
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
                              color: notifire.getwhiteblackcolor),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.close,
                              color: notifire.getwhiteblackcolor,
                            ))
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01),
                    selectdetail(
                        heding: "Preferred language",
                        image: "assets/images/Langauge.png",
                        text: guideFeaturesSaved ? getAllSelectedLanguages() : "Select Language",
                        icon: Icons.keyboard_arrow_right,
                        onclick: languagesbottomsheet),
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
                                  color: notifire.getwhiteblackcolor,
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
                                value: vehicleTypeSwitchValue,
                                thumbColor: notifire.getdarkwhitecolor,
                                trackColor: notifire.getbuttoncolor,
                                activeColor: notifire.getdarkbluecolor,
                                onChanged: (value) {
                                  setState(() {
                                    vehicleTypeSwitchValue = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
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
        }).then((value) => setState(() => guideFeaturesSaved = value));
  }

  timerBottomSheet() {
    showModalBottomSheet(
        backgroundColor: notifire.getbgcolor,
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Stack(
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
                                  maxValue: 21,
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
                                maxValue: 45,
                                step: 15,
                                onChanged: (value) => setState(() => minutesSliderValue = value),
                              )
                            ])
                          ]),
                      Positioned(
                        // left: 100,
                        top: MediaQuery.of(context).size.height / 3,
                        child: InkWell(
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
                        ),
                      ),
                    ],
                  ),
                )
            );
          });
        }).then((value) => setState(() { timeSaved = value; }));
  }

  languagesbottomsheet() {
    return showModalBottomSheet(
        backgroundColor: notifire.getbgcolor,
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
                                      color: notifire.getwhiteblackcolor),
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: notifire.getwhiteblackcolor,
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
                          ],
                        ),
                      ),
                      Positioned(
                        // left: 100,
                        top: MediaQuery.of(context).size.height / 2.33,
                        child: InkWell(
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
                        ),
                      ),
                    ],
                  ),
                );
              });
        }).then((value) => setState(() { guideFeaturesSaved = value; }));
  }

  paymentmodelbottomsheet() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: notifire.getbgcolor,
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
                                  color: notifire.getwhiteblackcolor),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  Icons.close,
                                  color: notifire.getwhiteblackcolor,
                                ))
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: notifire.getdarkmodecolor),
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
                                      color: notifire.getwhiteblackcolor),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        2.82),
                                Theme(
                                  data: ThemeData(
                                      unselectedWidgetColor:
                                          notifire.getdarkwhitecolor),
                                  child: Checkbox(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    value: isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isChecked = value!;
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
                              color: notifire.getdarkmodecolor),
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
                                      color: notifire.getwhiteblackcolor),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        1.98),
                                Theme(
                                  data: ThemeData(
                                      unselectedWidgetColor:
                                          notifire.getdarkwhitecolor),
                                  child: Checkbox(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    value: isChecked1,
                                    onChanged: (value) {
                                      setState(() {
                                        isChecked1 = value!;
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
                              color: notifire.getdarkmodecolor),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: notifire.getgreycolor),
                                child: Center(
                                  child: CircleAvatar(
                                      backgroundColor:
                                          notifire.getdarkbluecolor,
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
                                      color: notifire.getwhiteblackcolor)),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12),
                        AppButton(
                            buttontext: "Confirm and Pay",
                            onclick: BookingSuccessfull)
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  BookingSuccessfull() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: notifire.getbgcolor,
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
                                    color: notifire.getwhiteblackcolor),
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: Text(
                                "Congratulations! Please check in on the appropriate date. Enjoy your trip!",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: notifire.getgreycolor,
                                    fontFamily: "Gilroy Medium"),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          selectedIndex = 0;
                          Booking newBooking = new Booking(tour!, selectedDate!.copyWith(hour: hourSliderValue, minute: minutesSliderValue), smallPriceSelected ? 3 : 6, 0);
                          bookings.add(newBooking);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const homepage()));
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
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
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
            data: ThemeData(unselectedWidgetColor: notifire.getwhiteblackcolor),
            child: Checkbox(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: notifire.getwhiteblackcolor)),
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
      };
    }
    return selectedLanguages;
  }
}
