// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Providers/userProvider.dart';
import '../Utils/Colors.dart';


class SelectTukTuk extends StatefulWidget {
  const SelectTukTuk({super.key});

  @override
  State<SelectTukTuk> createState() => _SelectTukTukState();
}

class _SelectTukTukState extends State<SelectTukTuk> {
  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifier notifier;
  late UserProvider userProvider;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context);
    final tuktuksSnapshot = FirebaseFirestore.instance
        .collection('tuktuks')
        .where("organizationRef", isEqualTo: userProvider.user?.organizationRef)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: notifier.getblackwhitecolor,
        title: Text("Select TukTuk",
        style: TextStyle(color: notifier.getwhiteblackcolor,
        fontFamily: "Gilroy Bold"))),
      backgroundColor: notifier.getblackwhitecolor,
      body:  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: tuktuksSnapshot,
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if(!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: WhiteColor));
                }

                List<QueryDocumentSnapshot<Map<String, dynamic>>> tuktuks = snapshot.data!.docs;


                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: tuktuks.length,
                            itemBuilder: (BuildContext context,
                                int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                vertical: 10),
                                child: InkWell(
                                  onTap: () async {
                                    await userProvider.user!.associateTukTuk(tuktuks[index].reference);
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: notifier.getdarklightgreycolor),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                      child: Text(
                                            tuktuks[index].get("licensePlate"),
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: notifier.getwhiteblackcolor,
                                              fontFamily: "Gilroy Bold")
                                        ))
                                    )
                                )
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
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
