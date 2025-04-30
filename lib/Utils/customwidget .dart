// ignore_for_file: unnecessary_import, non_constant_identifier_names, file_names

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Login&ExtraDesign/tripDetail.dart';
import 'package:dm/Message/chatting.dart';
import 'package:dm/Providers/userProvider.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Domain/tour.dart';
import 'package:dm/Domain/trip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../Domain/appUser.dart';
import '../Login&ExtraDesign/tourDetail.dart';
import '../Profile/rateTour.dart';
import 'dark_lightmode.dart';

CustomAppbar(
    {centertext,
    ActionIcon,
    bgcolor,
    Color? actioniconcolor,
    Color? leadingiconcolor,
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
      leading: leadingiconcolor != null ? Padding(
          padding: const EdgeInsets.only(top: 25),
          child: BackButton(
            color: leadingiconcolor,
          )) : null,
      elevation: 0,
      backgroundColor: bgcolor);
}

textField({String? text, suffix, Color? hintColor, fieldColor, TextEditingController? controller, bool password = false, TextInputFormatter? formatter, bool readOnly = false}) {
  return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: fieldColor),
      child: TextField(
        readOnly: readOnly,
        obscureText: password,
        controller: controller,
        inputFormatters: formatter != null ? [formatter] : [],
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
                  fontSize: 16, color: LogoColor, fontFamily: "Gilroy Bold")),
        ],
      ),
      if (buttonText.isNotEmpty)
        ...[InkWell(
          onTap: onClick,
          child: Container(
            height: 40,
            width: 90,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50), color: LogoColor),
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
                tour.mainImage,
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
                tour.pickupPoint,
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
                      "${tour.lowPrice}€ - ${tour.highPrice}€",
                      style: TextStyle(
                          fontSize: 14,
                          color: Darkblue,
                          fontFamily: "Gilroy Bold"),
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.15),
                  tourReview(review: tour.rating)
                ],
              )
            ],
          )
        ],
      ),
    ),
  );
}

guideTripLayout(BuildContext context, ColorNotifier notifier, Trip trip, bool showActions) {
  return InkWell(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TripDetail(trip.id!)));
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(trip.reservationId!,
                      style: TextStyle(
                          fontSize: 15,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold")),
                  Text(DateFormat('E, d MMM yyyy HH:mm', AppLocalizations.of(context)!.locale)
                      .format(trip.date),
                      style: TextStyle(
                          fontSize: 15,
                          color: notifier.getwhiteblackcolor))
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
                        trip.tour.mainImage,
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
                        trip.tour.pickupPoint,
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
                            child:  Text("${trip.persons < 5 ? "1-4" : "5-6"} ${AppLocalizations.of(context)!.persons}",
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
              if (showActions)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.totalPrice,
                            style: TextStyle(
                                fontSize: 15, color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Medium")),
                        const SizedBox(height: 4),
                        Text("${trip.tour.getTourPrice(trip.persons < 5)}€",
                            style: TextStyle(
                                fontSize: 16, color: Darkblue, fontFamily: "Gilroy Bold")),
                      ],
                    ),
                    if (trip.status == "pending" || trip.showStartButton! || trip.showEndButton!)
                      InkWell(
                        onTap: () {
                          if (trip.status == "booked") {
                            showConfirmationMessage(context,
                                AppLocalizations.of(context)!.startTour,
                                AppLocalizations.of(context)!.startTourConfirmation,
                                () async => await trip.startTour(),
                                () {}, null, null);
                          } else if (trip.status == "started") {
                            showConfirmationMessage(context,
                                AppLocalizations.of(context)!.finishTour,
                                AppLocalizations.of(context)!.finishTourConfirmation,
                                    () async => await trip.finishTour(),
                                    () {}, null, null);
                          } else if (trip.status == "pending") {
                            showConfirmationAcceptTour(context, trip);
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

Widget tourInfo(BuildContext context, ColorNotifier notifier, Tour tour) {
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
              tour.mainImage,
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
              tour.name.toUpperCase(),
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy Bold",
                  color: notifier.getwhiteblackcolor),
            ),
            // const SizedBox(height: 6),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.006),
            Text(
              tour.pickupPoint,
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
                            tour.rating.toString(),
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
                            child: SizedBox(
                              height: 110,
                              width: 130,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                    trip.tour.mainImage,
                                    fit: BoxFit.fill
                                ),
                              ),
                            )
                        ),
                        Positioned(
                          left: 20,
                          width: 85,
                          height: 25,
                          child: Container(
                            height: 25,
                            width: 85,
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
                          Text(DateFormat('E, d MMM yyyy - HH:mm', AppLocalizations.of(context)!.locale).format(trip.date),
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
                      Text("${trip.persons} ${AppLocalizations.of(context)!.persons}",
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
                              Text(AppLocalizations.of(context)!.totalPrice,
                                  style: TextStyle(
                                      fontSize: 12, color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Medium")),
                              Text("${trip.price}€",
                                  style: TextStyle(
                                      fontSize: 14, color: Darkblue, fontFamily: "Gilroy Bold")),
                            ],
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                          if (trip.status == 'pending' ||
                              (trip.status == 'booked' && trip.allowStart() && (trip.clientIsReady == null || !trip.clientIsReady!)) ||
                              (trip.status == 'finished' && !trip.rateSubmitted))
                            InkWell(
                              onTap: () async {
                                try {
                                  if (trip.status == 'finished') {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => RateTour(trip)));
                                  } else if (trip.status == 'booked') {
                                    await setClientReady(context, trip);
                                  }
                                } on Exception catch (_, e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                height: 30,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50), color: LogoColor),
                                child: Center(
                                  child: Text(
                                    trip.status == 'pending' ? AppLocalizations.of(context)!.cancel.toUpperCase() :
                                      (trip.status == 'booked' ? AppLocalizations.of(context)!.letsGo.toUpperCase()
                                          : (trip.status == 'finished' ? AppLocalizations.of(context)!.rateTour.toUpperCase() : '')),
                                    style: TextStyle(
                                        fontSize: 12, color: WhiteColor, fontFamily: "Gilroy Bold"),
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

Future<void> setClientReady(BuildContext context, Trip trip) async {
  UserProvider userProvider = Provider.of<UserProvider>(context);
  final convertedDocRef = trip.guideRef!.withConverter<AppUser>(
    fromFirestore: AppUser.fromFirestore,
    toFirestore: (AppUser user, _) => user.toFirestore(),
  );
  DocumentSnapshot<AppUser> snapshot = await convertedDocRef.get();
  AppUser appUser = snapshot.data()!;
  if (context.mounted) {
    showConfirmationMessage(context,
        AppLocalizations.of(context)!.letsGo,
        AppLocalizations.of(context)!.sendGuideMessageConfirmation,
            () async {
              await trip.sendChatMessage("Hi, just to let you know that i'm already at the pickup location.", userProvider.user!, appUser);
              trip.setClientIsReady();
              if (context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Chatting(trip: trip, sendTo: snapshot.data()!)));
              }
            },
            () {}, AppLocalizations.of(context)!.yes, AppLocalizations.of(context)!.no);
  }
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
                      Text(DateFormat('E, d MMM yyyy HH:mm', AppLocalizations.of(context)!.locale)
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
                          Text("${trip.tour.getTourPrice(trip.persons < 5)}€",
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
                            trip.tour.mainImage,
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
                            trip.tour.pickupPoint,
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
                                child:  Text("${trip.persons < 5 ? "1-4" : "5-6"} ${AppLocalizations.of(context)!.persons}",
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
                        onTap: () async {
                          showConfirmationAcceptTour(context, trip);
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

showConfirmationAcceptTour(BuildContext context, Trip trip) {
  return showConfirmationMessage(context,
    "Accept Tour",
    "Are you sure you want to accept this tour?",
      () async {
        if (await AppUser.isGuideAvailable(trip)) {
          bool resultOk = await trip.acceptTour();
          if (resultOk) {
            await AppUser.updateUserUnavailability(FirebaseAuth.instance.currentUser!.uid, trip.tour, trip.date, trip.date.hour, trip.date.minute, false);
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            showTripAcceptResultMessage(context, resultOk);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: lightGrey,
                  content: Text("You are not available for this dates!",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Gilroy Medium",
                          color: LogoColor)
                  ),
                ));
          }
        }
      },
      () {}, "Yes", "No");
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

tourReview({num? review})   {
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

showConfirmationMessage(BuildContext context, String title, String description, Function()? onClickOk, Function()? onClickCancel, String? confirmText, String? cancelText) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        if (onClickCancel != null)
          TextButton(
            onPressed: () {
              onClickCancel.call();
              Navigator.pop(dialogContext, false);
            },
            child: Text(cancelText ?? "Cancel"),
          ),
        if (onClickOk != null)
          TextButton(
            onPressed: () {
              onClickOk.call();
              Navigator.pop(dialogContext, true);
            },
            child: Text(confirmText ?? "OK"),
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
              AppLocalizations.of(context)!.bookingAccepted,
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
          content: Text(AppLocalizations.of(context)!.bookingAlreadyAcceptedWarning,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Gilroy Medium",
                  color: LogoColor)
          ),
        ));
  }
}

Widget selectDetail({heading, image, text, icon, onclick, notifier}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (heading != null)
        ...[Text(heading!,
            style: TextStyle(
                fontSize: 16,
                color: notifier.getwhiteblackcolor,
                fontFamily: "Gilroy Bold")),
        const SizedBox(height: 8)],
      InkWell(
        onTap: onclick,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: notifier.getdarkmodecolor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (image != null)
                      ...[Image.asset(
                        image,
                        height: 25,
                        color: LogoColor,
                      ),
                      const SizedBox(width: 15)]
                    else
                      const SizedBox(width: 5),
                    Text(
                      text,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Gilroy Medium",
                          color: notifier.getdarkgreycolor),
                    ),
                  ],
                ),
                Icon(icon, color: notifier.getgreycolor)
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

List guideLanguages = [
  {
    "code": "EN",
    "name": "english"
  },
  {
    "code": "FR",
    "name": "french"
  },
  {
    "code": "DE",
    "name": "german"
  },
  {
    "code": "JP",
    "name": "japanese"
  },
  {
    "code": "PT",
    "name": "portuguese"
  },
  {
    "code": "ES",
    "name": "spanish"
  },
  {
    "code": "IT",
    "name": "italian"
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

