// ignore_for_file: file_names, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/appUser.dart';
import '../Domain/trip.dart';
import '../Providers/userProvider.dart';
import '../Utils/customwidget .dart';

class Chatting extends StatefulWidget {
  final Trip trip;
  final AppUser sendTo;

  const Chatting({super.key, required this.trip, required this.sendTo });

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  TextEditingController chatTextController = TextEditingController();

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  late UserProvider userProvider;
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatMessages = FirebaseFirestore.instance
        .collection('chat').doc(widget.trip.id)
        .collection('messages')
        .orderBy("date").snapshots();

    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.getblackwhitecolor,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          // ignore: sized_box_for_whitespace
          Container(
            height: 80,
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 0, right: 10),
              visualDensity: VisualDensity.standard,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: CircleAvatar(
                    backgroundColor: notifier.getdarkmodecolor,
                    child: BackButton(color: notifier.getwhiteblackcolor)),
              ),
              title: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            child: Image.asset(
                              "assets/images/avatar.png",
                              height: 50,
                              width: 60,
                            ),
                          ),
                          Positioned(
                              left: 41,
                              top: 0,
                              child: CircleAvatar(
                                backgroundColor: WhiteColor,
                                radius: 8,
                                child: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 6,
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(widget.sendTo.name!,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: notifier.getwhiteblackcolor,
                                  fontFamily: "Gilroy Bold")),
                          const SizedBox(height: 4),
                          Text("Online",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: notifier.getgreycolor,
                                  fontFamily: "Gilroy Medium")),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: CircleAvatar(
                  backgroundColor: notifier.getdarkmodecolor,
                  child: Icon(
                    Icons.more_vert,
                    color: notifier.getwhiteblackcolor,
                  ),
                ),
              ),
            ),
          ),
          guideTripLayout(context, notifier, widget.trip, false),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // Attach controller here
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder(
                      stream: chatMessages,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator(color: WhiteColor));
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data != null ? snapshot.data!.docs.length : 0,
                          itemBuilder: (BuildContext context,
                              int index) {
                            QueryDocumentSnapshot chatMessage = snapshot.data!.docs[index];
                            return message(text: chatMessage["text"],
                                timeText:  chatMessage["date"] != null ? DateFormat('HH:mm').format(chatMessage["date"].toDate()) : "",
                                from:  chatMessage["from"]);
                          },
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
          if(widget.trip.status != 'finished')
            Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
            child: TextField(
              controller: chatTextController,
              decoration: InputDecoration(
                hintText: "Write a reply",
                hintStyle: TextStyle(
                    fontFamily: "Gilroy Medium", color: notifier.getgreycolor),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CustomPopupMenu(
                    arrowSize: 15,
                    arrowColor: const Color(0XFF151B33),
                    // ignore: sort_child_properties_last
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/pin.png",
                        height: 25,
                        color: notifier.getgreycolor,
                      ),
                    ),
                    menuBuilder: () => ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        width: 50,
                        color: const Color(0XFF151B33),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Image.asset("assets/images/gallery.png",
                                    height: 30),
                              ),
                              Divider(
                                color: greyColor,
                                endIndent: 12,
                                indent: 12,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Image.asset("assets/images/location.png",
                                    height: 30),
                              ),
                              Divider(
                                color: greyColor,
                                endIndent: 12,
                                indent: 12,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Image.asset("assets/images/document.png",
                                    height: 30),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    pressType: PressType.singleClick,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(6),
                  child:
                    InkWell(
                      onTap: () {
                        if (chatTextController.text.isNotEmpty) {
                          setState(() {
                            widget.trip.sendChatMessage(chatTextController.text,  userProvider.user!, widget.sendTo).then((value) => {
                              chatTextController.clear()
                            });
                          });
                        }
                      },
                      child:
                        Icon(
                          Icons.send,
                          color: Darkblue)
                    ),
                ),
                border: const OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(50))),
                focusedBorder: OutlineInputBorder( borderSide: BorderSide(
                  color: LogoColor,
                ),
                    borderRadius: BorderRadius.circular(50)),
                enabledBorder: OutlineInputBorder( borderSide: BorderSide(
                      color: darkGrey,
                    ),
                    borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }

  message({text, timeText, from}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        if (from == FirebaseAuth.instance.currentUser!.uid)
          Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: notifier.getdarkbluecolor),
                width: MediaQuery.of(context).size.width * 0.70,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          text,
                          style: TextStyle(
                              fontSize: 14,
                              color: notifier.getdarkwhitecolor,
                              fontFamily: "Gilroy Medium"),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeText,
                        style: TextStyle(
                            color: lightGrey,
                            fontSize: 13,
                            fontFamily: "Gilroy Medium"),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      color: lightGrey),
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(text,
                            style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Gilroy Medium",
                            color: notifier.getwhiteblackcolor),
                          ),
                          const SizedBox(height: 3),
                          Text(timeText,
                            style: TextStyle(
                            color: darkGrey,
                            fontSize: 13,
                            fontFamily: "Gilroy Medium"),
                          )
                        ],
                      )
                    ),
                  ),
                ),
            ],
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
