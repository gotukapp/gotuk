// ignore_for_file: unnecessary_import, non_constant_identifier_names, file_names

import 'dart:ui';

import 'package:dm/Utils/Colors.dart';
import 'package:flutter/material.dart';

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

textfield({String? text, prefix, suffix, Color? hintcolor, feildcolor}) {
  return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: feildcolor),
      child: TextField(
        decoration: InputDecoration(
          hintText: text,
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: hintcolor, fontFamily: "Gilroy Medium"),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: prefix,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6),
            child: suffix,
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: greyColor,
              ),
              borderRadius: BorderRadius.circular(15)),
        ),
      ));
}

AppButton({onclick, buttontext}) {
  return InkWell(
    onTap: onclick,
    child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: Darkblue),
        child: Center(
            child: Text(buttontext,
                style: TextStyle(
                    fontSize: 16,
                    color: WhiteColor,
                    fontFamily: "Gilroy Bold")))),
  );
}

cupon({text1, text2, buttontext, Function()? onClick}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text1,
              style: TextStyle(
                  fontSize: 15, color: greyColor, fontFamily: "Gilroy Medium")),
          const SizedBox(height: 4),
          Text(text2,
              style: TextStyle(
                  fontSize: 16, color: Darkblue, fontFamily: "Gilroy Bold")),
        ],
      ),
      InkWell(
        onTap: onClick,
        child: Container(
          height: 40,
          width: 90,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: Darkblue),
          child: Center(
            child: Text(
              buttontext,
              style: TextStyle(
                  fontSize: 15, color: WhiteColor, fontFamily: "Gilroy Bold"),
            ),
          ),
        ),
      ),
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

List hotelList3 = [
  {"price": "44€"},
  {"price": "42€"},
  {"price": "40€"},
  {"price": "38€"},
  {"price": "40€"},
  {"price": "34€"},
  {"price": "32€"},
  {"price": "30€"},
  {"price": "46€"},
  {"price": "44€"},
];

List hotelList4 = [
  {
    "id": "1",
    "title": "John kennedy",
    "img": "assets/images/person.jpg",
    "price": "26€/Tour",
    "massage": "Tuk Tuk is the best tour in the city",
    "review": "4.8",
  },
  {
    "id": "2",
    "title": "Alexander",
    "img": "assets/images/person1.jpeg",
    "price": "28€/Tour",
    "massage": "Thank you for booking our tour",
    "review": "4.6",
  },
  {
    "id": "3",
    "title": "Emanuel",
    "img": "assets/images/person2.jpg",
    "price": "30€/Tour",
    "massage": "50% discount on first booking",
    "review": "4.5",
  },
  {
    "id": "4",
    "title": "Jamison",
    "img": "assets/images/person12.jpg",
    "price": "32€/Tour",
    "massage": "You will have more fun in this tour than any other",
    "review": "4.4",
  },
  {
    "id": "5",
    "title": "Quentin",
    "img": "assets/images/person5.jpg",
    "price": "34€/Tour",
    "massage": "Excelent Tuk Tuk tour",
    "review": "4.3",
  },
  {
    "id": "6",
    "title": "Albert",
    "img": "assets/images/person6.jpg",
    "price": "36€/Tour",
    "massage": "Excelent Tuk Tuk tour",
    "review": "4.6",
  },
  {
    "id": "7",
    "title": "Lawrence",
    "img": "assets/images/person7.jpg",
    "price": "38€/Tour",
    "massage": "Excelent Tuk Tuk tour",
    "review": "4.7",
  },
  {
    "id": "8",
    "title": "Alessandro",
    "img": "assets/images/person8.jpg",
    "price": "40€/Tour",
    "massage": "Amazing Tuk Tuk tour",
    "review": "4.1",
  },
  {
    "id": "9",
    "title": "Harrison",
    "img": "assets/images/person9.jpg",
    "price": "42€/Tour",
    "massage": "Money back if you don't enjoy our tour",
    "review": "4.0",
  },
  {
    "id": "10",
    "title": "Maverick",
    "img": "assets/images/person13.jpg",
    "price": "44€/Tour",
    "massage": "50% discount on first booking",
    "review": "3.9",
  },
];

List hotelList5 = [
  {
    "title": "Kim Hayo Send You a Message",
    "subtitle":
        "Hi mariana, are you looking for Tuk Tuk in Lisbon?",
    "massagetime": "1:m Ago"
  },
  {
    "title": "John  Send You a Message",
    "subtitle":
        "The service is on point, and I really like the tour. Good job!",
    "massagetime": "2:m Ago"
  },
  {
    "title": "Alexander Send You a Message",
    "subtitle":
        "The hotels give me amazing view, I really like it!. All people must try this Tuk Tuk.",
    "massagetime": "3:m Ago"
  },
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

