// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Providers/userProvider.dart';
import '../Utils/Colors.dart';
import '../Utils/customwidget.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      fetchData();
    });
  }

  late ColorNotifier notifier;
  late UserProvider userProvider;
  List<DocumentReference>? assignedTuktuks;
  bool processing = false;
  bool loading = true;

  Future<void> fetchData() async {
    try {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var tuktukActivityDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(userProvider.user?.organizationRef?.id)
          .collection('tuktukActivity')
          .doc(date)
          .get();

      setState(() {
        assignedTuktuks = List<DocumentReference>.from(
            tuktukActivityDoc.data()?['tuktuks'] ?? []
        );
        loading = false;
      });
    } catch (e) {
      await Sentry.captureException(e);
      setState(() {
        loading = false;
      });
    }
  }

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
        title: Text(AppLocalizations.of(context)!.selectTuk,
        style: TextStyle(color: notifier.getwhiteblackcolor,
        fontFamily: "Gilroy Bold"))),
      backgroundColor: notifier.getblackwhitecolor,
      body:  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: tuktuksSnapshot,
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: WhiteColor));
            }
                List<QueryDocumentSnapshot<
                    Map<String, dynamic>>> tuktuks = snapshot.data!.docs;

                final availableTuktuks = assignedTuktuks != null ? tuktuks.where((tuktuk) {
                  return !assignedTuktuks!.any((assignedRef) =>
                  assignedRef.id == tuktuk.reference.id);
                }).toList() : tuktuks;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child:
                    processing ?
                     Center(child: CircularProgressIndicator(color: LogoColor))
                    : (availableTuktuks.isNotEmpty ?
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: availableTuktuks.length,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: InkWell(
                                        onTap: () async {
                                          try {
                                            final navigator = Navigator.of(context);
                                            final messenger = ScaffoldMessenger.of(context);
                                            final localization = AppLocalizations.of(context);

                                            bool resultYes = await showConfirmationMessage( context,
                                              AppLocalizations.of(context)!.selectTuk,
                                              AppLocalizations.of(context)!.selectTukConfirmation(availableTuktuks[index].get("licensePlate")),
                                              () {}, () {},
                                              AppLocalizations.of(context)!.yes,
                                              AppLocalizations.of(context)!.no);

                                            if (resultYes) {
                                              setState(() {
                                                processing = true;
                                              });
                                              bool ok = await userProvider.user!.associateTukTuk(availableTuktuks[index].reference);
                                              if (ok) {
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                      content: Text(localization!.tukSelectedSuccessfully),
                                                  ),
                                                );
                                                navigator.pop();
                                              } else {
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                      content: Text(localization!.tukSelectedByAnotherGuide),
                                                      backgroundColor: RedColor
                                                  ),
                                                );
                                              }
                                              setState(() {
                                                processing = false;
                                              });
                                            }
                                          } catch (e) {
                                            await Sentry.captureException(e);
                                            print(e.toString());
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(e.toString()),
                                                  backgroundColor: RedColor
                                              ),
                                            );
                                            setState(() {
                                              processing = false;
                                            });
                                          }
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius
                                                    .circular(15),
                                                color: notifier
                                                    .getdarklightgreycolor),
                                            child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                    availableTuktuks[index].get(
                                                        "licensePlate"),
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: notifier
                                                            .getwhiteblackcolor,
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
                        )
                      : Column(
                          children: [
                            Text(AppLocalizations.of(context)!.noTuksAvailable,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: LogoColor,
                                    fontFamily: "Gilroy Medium")),
                            const SizedBox(height: 20),
                            InkWell(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius
                                            .circular(15),
                                        color: notifier
                                            .getwhitelogocolor),
                                    child: Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            vertical: 10),
                                        child: Text(
                                            AppLocalizations.of(context)!.back,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: notifier
                                                    .getblackwhitecolor,
                                                fontFamily: "Gilroy Bold")
                                        ))
                                )
                            )
                          ]
                      ))
                );

          })
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
