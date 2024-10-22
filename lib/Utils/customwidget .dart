// ignore_for_file: unnecessary_import, non_constant_identifier_names, file_names

import 'dart:ui';

import 'package:dm/Login&ExtraDesign/tripDetail.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Domain/tour.dart';
import 'package:dm/Domain/trips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Login&ExtraDesign/tourDetail.dart';
import 'dark_lightmode.dart';

CustomAppbar(
    {centertext,
    ActionIcon,
    bgcolor,
    Color? actioniconcolor,
    leadingiconcolor,
    titlecolor}) {
  return AppBar(
      actions: [
        Padding(
            padding: const EdgeInsets.only(top: 30, right: 18),
            child: Icon(
              ActionIcon,
              color: actioniconcolor,
            ))
      ],
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Text(
          centertext,
          style: TextStyle(color: titlecolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      leading: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: BackButton(
            color: leadingiconcolor,
          )),
      elevation: 0,
      backgroundColor: bgcolor);
}

textfield({String? text, suffix, Color? hintColor, fieldColor, TextEditingController? controller, bool password = false}) {
  return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: fieldColor),
      child: TextField(
        obscureText: password,
        controller: controller,
        decoration: InputDecoration(
          hintText: text,
          labelStyle: const TextStyle(fontSize: 16, color: Colors.white),
          hintStyle: TextStyle(fontSize: 16, color: hintColor, fontFamily: "Gilroy Medium"),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6),
            child: suffix,
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: fieldColor,
              ),
              borderRadius: BorderRadius.circular(15)),
        ),
      ));
}

AppButton({onclick, buttontext, Color? bgColor, Color? textColor}) {
  return InkWell(
    onTap: onclick,
    child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: bgColor ?? Darkblue),
        child: Center(
            child: Text(buttontext,
                style: TextStyle(
                    fontSize: 16,
                    color: textColor ?? WhiteColor,
                    fontFamily: "Gilroy Bold")))),
  );
}

cupon({text1, text1Color, text2, buttonText, Function()? onClick}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text1,
              style: TextStyle(
                  fontSize: 15, color: text1Color, fontFamily: "Gilroy Medium")),
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

AccountSetting(
    {IconData? icon,
    String? text,
    image,
    Color? TextColor,
    boxcolor,
    ImageColor,
    iconcolor,
    Function()? onclick}) {
  return InkWell(
    onTap: onclick,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 55,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: boxcolor),
      child: ListTile(
        leading: Image.asset(
          image,
          height: 25,
          color: ImageColor,
        ),
        title: Text(text!,
            style: TextStyle(
                fontSize: 15, color: TextColor, fontFamily: "Gilroy Bold")),
        trailing: Icon(icon, color: iconcolor),
      ),
    ),
  );
}

ProfileSetting(
    {IconData? icon,
      String? text,
      image,
      Color? TextColor,
      boxcolor,
      ImageColor,
      iconcolor,
      Function()? onclick}) {
  return Column(
    children: [
        InkWell(
        onTap: onclick,
        child: Container(
            height: 90,
            width:90,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: bgcolor),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  image,
                  height: 20,
                  color: LogoColor,
                )
            )
        ),
      ),
      Text(text!,
          style: TextStyle(
              fontSize: 14, color: BlackColor, fontFamily: "Gilroy Bold"))
    ],
  );
}

tourLayout(BuildContext context, ColorNotifier notifier, Tour tour) {
  return InkWell(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TourDetail(tour.id)));
    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: notifier.getdarklightgreycolor,
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
            height: 75,
            width: 75,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                tour.icon,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tour.name.toUpperCase(),
                style: TextStyle(
                    fontSize: 15,
                    color: notifier.getwhiteblackcolor,
                    fontFamily: "Gilroy Bold"),
              ),
              // const SizedBox(height: 6),
              SizedBox(
                  height: MediaQuery.of(context) .size .height *
                      0.001),
              Text(
                tour.address,
                style: TextStyle(
                    fontSize: 13,
                    color: notifier.getgreycolor,
                    fontFamily: "Gilroy Medium",
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(
                  height: MediaQuery.of(context) .size .height *
                      0.001),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.3,
                    child: Text(
                      "${tour.priceLow}€ - ${tour.priceHigh}€",
                      style: TextStyle(
                          fontSize: 14,
                          color: Darkblue,
                          fontFamily: "Gilroy Bold"),
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.15),
                  tourReview(review: tour.review)
                ],
              )
            ],
          )
        ],
      ),
    ),
  );
}

guideTripLayout(BuildContext context, ColorNotifier notifier, Trip trip) {
  return InkWell(
    onTap: () {

    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: notifier.getdarklightgreycolor,
      ),
      child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 8),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('E, d MMM yyyy HH:mm')
                .format(trip.date),
                style: TextStyle(
                    fontSize: 15,
                    color: notifier.getwhiteblackcolor)),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    height: 75,
                    width: 75,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        trip.tour.icon,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.tour.name.toUpperCase(),
                        style: TextStyle(
                            fontSize: 15,
                            color: notifier.getwhiteblackcolor,
                            fontFamily: "Gilroy Bold"),
                      ),
                      // const SizedBox(height: 6),
                      SizedBox(
                          height: MediaQuery.of(context) .size .height *
                              0.001),
                      Text(
                        trip.tour.address,
                        style: TextStyle(
                            fontSize: 13,
                            color: notifier.getwhiteblackcolor,
                            fontFamily: "Gilroy Medium",
                            overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context) .size .height *
                              0.001),
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width *
                                0.3,
                            child:  Text("${trip.persons == 3 ? "1-3" : "4-6"} Persons",
                              style: TextStyle(
                              fontSize: 15,
                              color: notifier.getwhiteblackcolor,
                              fontFamily: "Gilroy Medium")),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Price",
                        style: TextStyle(
                            fontSize: 15, color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Medium")),
                    const SizedBox(height: 4),
                    Text("${trip.tour.getTourPrice(trip.persons == 3)}€",
                        style: TextStyle(
                            fontSize: 16, color: Darkblue, fontFamily: "Gilroy Bold")),
                  ],
                ),
                InkWell(
                    onTap: () {
                      if (trip.status == "booked") {
                        showConfirmationMessage(context,
                            "Start Tour",
                            "Are you sure you want to start this tour?",
                            () => trip.startTour(),
                            () {});
                      } else if (trip.status == "started") {
                        showConfirmationMessage(context,
                            "Finish Tour",
                            "Are you sure you want to finish this tour?",
                                () => trip.finishTour(),
                                () {});
                      } else if (trip.status == "pending") {
                        showConfirmationMessage(context,
                            "Accept Tour",
                            "Are you sure you want to accept this tour?",
                                () async {
                                    bool result = await trip.acceptTour();
                                    if (context.mounted) {
                                      showTripAcceptResultMessage(context, result);
                                    }
                                },
                                () {});

                      }
                    },
                    child: Container(
                      height: 40,
                      width: 110,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50), color: trip.status == 'started' ? Darkblue : LogoColor),
                      child: Center(
                        child: Text(
                          getTripButtonAction(trip),
                          style: TextStyle(
                              fontSize: 15, color: WhiteColor, fontFamily: "Gilroy Bold"),
                        ),
                      ),
                    ),
                  )
              ],
            )
          ]
      )
      )
    ),
  );
}

clientTripLayout(BuildContext context, ColorNotifier notifier, Trip trip) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TripDetail(trip.id!)));
        },
        child: Container(
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifier.getdarklightgreycolor),
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
                                vertical: 10),
                            child: Container(
                              height: 110,
                              width: 130,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                    trip.tour.img,
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
                                AppLocalizations.of(context)!.tripStatus(trip.status).toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: trip.status == 'finished' ? BlackColor : (trip.status == 'pending' ? LogoColor : Darkblue) ,
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
                          Text(DateFormat('E, d MMM yyyy - HH:mm').format(trip.date),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: notifier.getwhiteblackcolor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(trip.tour.name.toUpperCase(),
                          style: TextStyle(
                              fontSize: 14,
                              color:
                              notifier.getwhiteblackcolor,
                              fontFamily: "Gilroy Bold")),
                      Text("${trip.persons} Persons",
                          style: TextStyle(
                              fontSize: 12,
                              color: notifier.getwhiteblackcolor,
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
                                      fontSize: 12, color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Medium")),
                              Text("${trip.price}€",
                                  style: TextStyle(
                                      fontSize: 14, color: Darkblue, fontFamily: "Gilroy Bold")),
                            ],
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.10),
                          if (trip.status == 'pending' ||
                              trip.status == 'booked' ||
                              trip.status == 'finished' )
                            InkWell(
                              onTap: () {
                              },
                              child: Container(
                                height: 25,
                                width: 70,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50), color: LogoColor),
                                child: Center(
                                  child: Text(
                                    trip.status == 'pending' ? AppLocalizations.of(context)!.cancel :
                                      (trip.status == 'booked' ? AppLocalizations.of(context)!.letsGo
                                          : (trip.status == 'finished' ? AppLocalizations.of(context)!.rateTour : '')),
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
    )
  );
}

newTripNotification(BuildContext context, ColorNotifier notifier, Trip trip) {
  return InkWell(
    onTap: () {

    },
    child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: notifier.getdarklightgreycolor,
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('E, d MMM yyyy HH:mm')
                          .format(trip.date),
                          style: TextStyle(
                              fontSize: 15,
                              color: notifier.getwhiteblackcolor,
                              fontFamily: "Gilroy Bold")),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Price",
                              style: TextStyle(
                                  fontSize: 15, color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Medium")),
                          const SizedBox(height: 4),
                          Text("${trip.tour.getTourPrice(trip.persons == 3)}€",
                              style: TextStyle(
                                  fontSize: 17, color: Darkblue, fontFamily: "Gilroy Bold")),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        height: 75,
                        width: 75,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            trip.tour.icon,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.tour.name.toUpperCase(),
                            style: TextStyle(
                                fontSize: 15,
                                color: notifier.getwhiteblackcolor,
                                fontFamily: "Gilroy Bold"),
                          ),
                          // const SizedBox(height: 6),
                          SizedBox(
                              height: MediaQuery.of(context) .size .height *
                                  0.001),
                          Text(
                            trip.tour.address,
                            style: TextStyle(
                                fontSize: 13,
                                color: notifier.getwhiteblackcolor,
                                fontFamily: "Gilroy Medium",
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context) .size .height *
                                  0.001),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    0.3,
                                child:  Text("${trip.persons == 3 ? "1-3" : "4-6"} Persons",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: notifier.getwhiteblackcolor,
                                        fontFamily: "Gilroy Medium")),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (trip.status == 'pending')
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showConfirmationMessage(context,
                            "Accept Tour",
                            "Are you sure you want to accept this tour?",
                              () async {
                                bool result = await trip.acceptTour();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  showTripAcceptResultMessage(context, result);
                                }
                              },
                              () {});
                        },
                        child: Container(
                          height: 40,
                          width: 180,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50), color: Darkblue),
                          child: Center(
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                  fontSize: 15, color: WhiteColor, fontFamily: "Gilroy Bold"),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ]
            )
        )
    ),
  );
}


String getTripButtonAction(Trip trip) {
  if (trip.status == 'started') {
    return "End Tour";
  }

  if (trip.status == 'booked') {
    return "Start Tour";
  }

  return "Accept Tour";
}

tourReview({double? review})   {
  return Row(
    children: [
      Image.asset(
        "assets/images/star.png",
        height: 20,
      ),
      const SizedBox(width: 2),
      Padding(
        padding: const EdgeInsets.only(
            top: 4, right: 20),
        child: Row(
          children: [
            Text(
              review.toString(),
              style: TextStyle(
                  fontSize: 16,
                  color: BlackColor,
                  fontWeight:
                  FontWeight.bold),
            )
          ],
        ),
      )
    ],
  );
}

showConfirmationMessage(BuildContext context, String title, String description, Function()? onClickOk, Function()? onClickCancel) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        if (onClickCancel != null)
          TextButton(
            onPressed: () {
              onClickCancel.call();
              Navigator.pop(context, 'Cancel');
            },
            child: const Text('Cancel'),
          ),
        if (onClickOk != null)
          TextButton(
            onPressed: () {
              onClickOk.call();
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
      ],
    ),
  );
}

showTripAcceptResultMessage(BuildContext context, bool result) {
  if (result) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: lightGrey,
          content: Text(
              "Tour booking accepted!",
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Gilroy Medium",
                  color: Darkblue)
          ),
        )
    );
  } else  {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: lightGrey,
          content: Text("This tour has already been accepted by another Guide!",
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Gilroy Medium",
                  color: LogoColor)
          ),
        ));
  }
}

List hotelList = [
  {
    "id": 1,
    "title": "Lisboa Old City",
    "duration": "1h30 - 2h",
    "img": "assets/images/eco-tuk-tours.jpg",
    "price": "26€",
    "priceLow": 115,
    "priceHigh": 148,
    "address": "Sé de Lisboa"
  },
  {
    "id": 2,
    "title": "Lisboa New City",
    "duration": "1h30",
    "img": "",
    "price": "32€",
    "priceLow": 110,
    "priceHigh": 135,
    "address": "Terreiro do Paço (Praça do Comércio)"
  },
  {
    "id": 3,
    "title": "Discoveries in Belém",
    "duration": "1h30 - 2h30",
    "img": "",
    "price": "34€",
    "priceLow": 140,
    "priceHigh": 180,
    "address": "Mosteiro dos Jerónimos"
  },
  {
    "id": 4,
    "title": "Cristo Rei",
    "duration": "1h30 - 2h30",
    "img": "",
    "price": "36€",
    "priceLow": 95,
    "priceHigh": 135,
    "address": "Lisboa"
  },
  {
    "id": 5,
    "title": "Three sight hills",
    "duration": "1h30 - 2h",
    "img": "",
    "price": "38€",
    "priceLow": 105,
    "priceHigh": 152,
    "address": "Parque Eduardo VII, Lisboa"
  },
  {
    "id": 6,
    "title": "Instant Book",
    "img": "",
    "price": "40€",
    "priceLow": 115,
    "priceHigh": 148,
    "address": "1, Voznesensky Avenue"
  }
];

List hotelList2 = [
  {
    "id": "1",
    "title": "Grand Park City Tuk Tuk",
    "img": "assets/images/eco-tuk-tours.jpg",
    "price": "26€/",
    "address": "155 Rajadamri Road, Bangkok 10330 Thailand",
    "Night": "Tour",
    "review": "4.9",
    "reviewCount": "(160 Reviews)"
  },
  {
    "id": "2",
    "title": "Lisbon Tuk Tuk",
    "img": "",
    "price": "28€/",
    "address": "",
    "Night": "Tour",
    "review": "4.8",
    "reviewCount": "(150 Reviews)"
  },
  {
    "id": "3",
    "title": "Cascais Tour",
    "img": "",
    "price": "30€/",
    "address": "",
    "Night": "Tour",
    "review": "4.7",
    "reviewCount": "(140 Reviews)"
  }
];

List notificationList = [
  {
    "img": "assets/images/person9.jpg",
    "title": "Kim Hayo Send You a Message",
    "subtitle":
    "Hi mariana, are you looking for Tuk Tuk in Lisbon?",
    "massagetime": "1:m Ago"
  },
  {
    "img": "assets/images/person8.jpg",
    "title": "John  Send You a Message",
    "subtitle":
    "The service is on point, and I really like the tour. Good job!",
    "massagetime": "2:m Ago"
  },
  {
    "img": "assets/images/person6.jpg",
    "title": "Alexander Send You a Message",
    "subtitle":
    "The hotels give me amazing view, I really like it!. All people must try this Tuk Tuk.",
    "massagetime": "3:m Ago"
  }
];

List languages = [
  {
    "code": "EN",
    "name": "English"
  },
  {
    "code": "FR",
    "name": "French"
  },
  {
    "code": "DE",
    "name": "German"
  },
  {
    "code": "EN",
    "name": "Japanese"
  },
  {
    "code": "PT",
    "name": "Portuguese"
  },
  {
    "code": "ES",
    "name": "Spanish"
  },
  {
    "code": "IT",
    "name": "Italian"
  }
];

List appLanguages = [
  {
    "code": "EN",
    "name": "english"
  },
  {
    "code": "PT",
    "name": "portuguese"
  }
];

