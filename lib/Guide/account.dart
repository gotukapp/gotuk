// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Domain/appUser.dart';
import '../Login&ExtraDesign/calendar.dart';
import '../Profile/Language.dart';
import '../Providers/userProvider.dart';

class account extends StatefulWidget {
  const account({super.key});

  @override
  State<account> createState() => _AccountState();
}

class Item {
  Item({
    required this.itemName,
    required this.expandedValue,
    required this.headerValue,
    required this.status,
    required this.fields,
    this.isExpanded = false,
  });

  String itemName;
  String expandedValue;
  String headerValue;
  String status;
  bool isExpanded;
  List<dynamic> fields;
}

Color approved = const Color(0xff66dd66);

class _AccountState extends State<account> {

  bool _isLoading = true;
  String? _error;

  bool vehicleType = false;

  String personalDataStatus = '';
  List<String> language = [];
  List<bool> expandedData = [false, false, false, false];
  final identificationNumber = TextEditingController();
  final drivingLicenseNumber = TextEditingController();
  DateTime? identificationNumberExpirationDate;
  DateTime? drivingLicenseExpirationDate;

  String workAccidentInsuranceStatus = '';
  bool useWorkAccidentOrganizationInsurance = false;
  final insuranceWorkAccidentCompanyName = TextEditingController();
  final insuranceWorkAccidentPolicyNumber = TextEditingController();
  DateTime? insuranceWorkAccidentExpirationDate;

  final organizationCode = TextEditingController();
  String organizationName = '';
  String organizationStatus = '';

  String criminalRecordStatus = '';

  late UserProvider userProvider;
  late ColorNotifier notifier;

  @override
  void initState() {
    getdarkmodepreviousstate();
    _loadDocument();
    super.initState();
  }

  Future<void> _loadDocument() async {
    try {
      final queryPersonalData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('personalData')
          .orderBy('submitDate', descending: true) // Sort by 'datetime' in descending order
          .limit(1) // Limit to 1 document
          .get();

      final queryOrganizationData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('organizationData')
          .orderBy('submitDate', descending: true) // Sort by 'datetime' in descending order
          .limit(1) // Limit to 1 document
          .get();

      final queryWorkAccidentInsurance = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('workAccidentInsurance')
          .orderBy('submitDate', descending: true) // Sort by 'datetime' in descending order
          .limit(1) // Limit to 1 document
          .get();

      final queryCriminalRecord = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('criminalRecord')
          .orderBy('submitDate', descending: true) // Sort by 'datetime' in descending order
          .limit(1) // Limit to 1 document
          .get();


      setState(() {
        if (queryPersonalData.docs.isNotEmpty) {
          Map<String, dynamic>? personalData = queryPersonalData.docs.first.data();
          language = personalData["language"].whereType<String>().toList();
          identificationNumber.text = personalData["identificationNumber"];
          identificationNumberExpirationDate = personalData["identificationNumberExpirationDate"]?.toDate();
          drivingLicenseNumber.text = personalData["drivingLicenseNumber"];
          drivingLicenseExpirationDate = personalData["drivingLicenseExpirationDate"]?.toDate();
          personalDataStatus = personalData["status"];
        }

        if (queryWorkAccidentInsurance.docs.isNotEmpty) {
          Map<String,dynamic>? workAccidentInsurance = queryWorkAccidentInsurance.docs.first.data();
          insuranceWorkAccidentCompanyName.text = workAccidentInsurance["name"];
          insuranceWorkAccidentPolicyNumber.text = workAccidentInsurance["number"];
          insuranceWorkAccidentExpirationDate = workAccidentInsurance["expirationDate"]?.toDate();
          useWorkAccidentOrganizationInsurance = workAccidentInsurance["useOrganizationInsurance"] ?? false;
          workAccidentInsuranceStatus = workAccidentInsurance["status"];
        }

        if (queryOrganizationData.docs.isNotEmpty) {
          Map<String, dynamic>? organizationData = queryOrganizationData.docs.first.data();
          organizationCode.text = organizationData["code"];
          organizationName = organizationData["name"] ?? "";
          organizationStatus = organizationData["status"];
        }

        if (queryCriminalRecord.docs.isNotEmpty) {
          Map<String, dynamic>? criminalRecord = queryCriminalRecord.docs.first.data();
          criminalRecordStatus = criminalRecord["status"];
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  onLanguageClick() async {
    final selectedValues = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Language(languages: guideLanguages, multiple: true, currentLanguages: language,)));
    setState(() {
      language = selectedValues;
    });
  }

  String getSelectedLanguagesDescription() {
    return language.isEmpty ? "Selecionar línguas faladas" : language.map((s) => s.toUpperCase()).join(', ');
  }


  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getblackwhitecolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          "Account",
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getblackwhitecolor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
            : _error != null
              ? Center(child: Text(_error!)) // Show error message
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                      children: [
                        _buildPanel(),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                        AppButton(
                            bgColor: notifier.getlogobgcolor,
                            textColor: WhiteColor,
                            buttontext: "Submit Data",
                            onclick: () async {
                              AppUser user = userProvider.user!;
                              print(identificationNumberExpirationDate);
                              bool resultOk = await user.submitAccountData({
                                "language": language,
                                "identificationNumber": identificationNumber.text,
                                "identificationNumberExpirationDate": identificationNumberExpirationDate,
                                "drivingLicenseNumber": drivingLicenseNumber.text,
                                "drivingLicenseExpirationDate": drivingLicenseExpirationDate,
                                "insuranceWorkAccidentCompanyName": insuranceWorkAccidentCompanyName.text,
                                "insuranceWorkAccidentPolicyNumber": insuranceWorkAccidentPolicyNumber.text,
                                "insuranceWorkAccidentExpirationDate": insuranceWorkAccidentExpirationDate,
                                "useWorkAccidentOrganizationInsurance": useWorkAccidentOrganizationInsurance,
                                "organizationCode": organizationCode.text,
                                "updateOrganizationCode": true
                              });
                              if (resultOk) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Account information submitted successfully!"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Error submitting data!"),
                                  ),
                                );
                              }
                            })
                      ]
                  )
              ),
            )
    );
  }

  Widget _buildPanel() {

    final panels = [
      _personalDataPanel(0),
      _organizationDataPanel(1),
      _workAccidentInsurancePanel(2),
      _criminalRecordPanel(3)
    ];
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          expandedData[index] = isExpanded;
        });
      },
      children: panels,
    );
  }

  ExpansionPanel _personalDataPanel(index) {
    return ExpansionPanel(
      backgroundColor: getBackroundColorByStatus(personalDataStatus),
      headerBuilder: (BuildContext context, bool isExpanded) {
        return
          ListTile(
            title: Text(
              "Dados Pessoais",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
          );
      },
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Linguas Faladas",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            const SizedBox(height: 10),
            selectDetail(
                text: getSelectedLanguagesDescription(),
                onclick: () {
                  onLanguageClick();
                },
                notifier: notifier),
            const SizedBox(height: 20),
            Text("C.Cidadão / C.Residente / Passaporte",
              style: TextStyle(
                  fontSize: 15,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            const SizedBox(height: 10),
            textField(
                fieldColor: notifier.getdarkmodecolor,
                hintColor: notifier.getdarkgreycolor,
                controller: identificationNumber,
                text: "Número do documento",
                suffix: null),
            const SizedBox(height: 10),
            Text("Validade",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            const SizedBox(height: 10),
            selectDetail(
                text: identificationNumberExpirationDate != null ? DateFormat('dd/MM/yyyy').format(identificationNumberExpirationDate!) : "Seleccionar Data",
                icon: Icons.keyboard_arrow_down,
                onclick: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Calendar(selectedDate: identificationNumberExpirationDate),
                  )).then((value) {
                    setState(() {
                      identificationNumberExpirationDate = value;
                    });
                  });
                },
                notifier: notifier
            ),
            const SizedBox(height: 20),
            Text("Carta de condução",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            const SizedBox(height: 10),
            textField(
                fieldColor: notifier.getdarkmodecolor,
                hintColor: notifier.getdarkgreycolor,
                controller: drivingLicenseNumber,
                text: "Número do documento",
                suffix: null),
            const SizedBox(height: 10),
            Text("Validade",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            const SizedBox(height: 10),
            selectDetail(
                text: drivingLicenseExpirationDate != null ? DateFormat('dd/MM/yyyy').format(drivingLicenseExpirationDate!) : "Seleccionar Data",
                icon: Icons.keyboard_arrow_down,
                onclick: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Calendar(selectedDate: drivingLicenseExpirationDate),
                  )).then((value) {
                    setState(() {
                      drivingLicenseExpirationDate = value;
                    });
                  });
                },
                notifier: notifier
            ),
            const SizedBox(height: 25),
            AppButton(
                bgColor: notifier.getlogobgcolor,
                textColor: WhiteColor,
                buttontext: "Attach Document",
                onclick: () async {

                })
          ])
      ),
      isExpanded: expandedData[index],
    );
  }

  ExpansionPanel _organizationDataPanel(index) {
    return ExpansionPanel(
      backgroundColor: getBackroundColorByStatus(organizationStatus),
      headerBuilder: (BuildContext context, bool isExpanded) {
        return
          ListTile(
            title: Text(
              "Dados da Empresa",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
          );
      },
      body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Código",
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontFamily: "Gilroy Bold"),
                ),
                const SizedBox(height: 10),
                textField(
                    fieldColor: notifier.getdarkmodecolor,
                    hintColor: notifier.getdarkgreycolor,
                    controller: organizationCode,
                    text: "Código da Empresa",
                    suffix: null,
                    readOnly: organizationStatus == "approved"),
                const SizedBox(height: 10),
                Text("Nome",
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontFamily: "Gilroy Bold"),
                ),
                const SizedBox(height: 10),
                textField(
                    fieldColor: notifier.getdarkmodecolor,
                    hintColor: notifier.getdarkgreycolor,
                    text: organizationName,
                    suffix: null,
                    readOnly: true),
              ])
      ),
      isExpanded: expandedData[index],
    );
  }

  ExpansionPanel _workAccidentInsurancePanel(index) {
    return ExpansionPanel(
      backgroundColor: getBackroundColorByStatus(workAccidentInsuranceStatus),
      headerBuilder: (BuildContext context, bool isExpanded) {
        return
          ListTile(
            title: Text(
              'Apólice de Seguro de Acidentes de Trabalho',
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
          );
      },
      body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Está incluido na apólice da empresa",
                      style: TextStyle(
                          fontSize: 16,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold"),
                    ),
                    CupertinoSwitch(
                      value: useWorkAccidentOrganizationInsurance,
                      thumbColor: notifier.getdarkwhitecolor,
                      trackColor: notifier.getbuttoncolor,
                      activeColor: notifier.getdarkbluecolor,
                      onChanged: (value) {
                        setState(() {
                          useWorkAccidentOrganizationInsurance = value;
                        });
                      },
                    ),
                  ],
                ),
                if (useWorkAccidentOrganizationInsurance)
                  Text(
                    "Atenção - A sua conta apenas será validada se na apólice enviada pela empresa constar o seu nome",
                    style: TextStyle(
                        fontSize: 14,
                        color: notifier.getlogobgcolor,
                        fontFamily: "Gilroy Bold"),
                  ),
                if (!useWorkAccidentOrganizationInsurance)
                  ...[
                    const SizedBox(height: 10),
                    Text("Companhia de Seguros",
                      style: TextStyle(
                          fontSize: 16,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold"),
                    ),
                    const SizedBox(height: 10),
                    textField(
                        fieldColor: notifier.getdarkmodecolor,
                        hintColor: notifier.getdarkgreycolor,
                        controller: insuranceWorkAccidentCompanyName,
                        text: "Número do documento",
                        suffix: null),
                    const SizedBox(height: 10),
                    Text("Nº Apólice",
                      style: TextStyle(
                          fontSize: 16,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold"),
                    ),
                    const SizedBox(height: 10),
                    textField(
                        fieldColor: notifier.getdarkmodecolor,
                        hintColor: notifier.getdarkgreycolor,
                        controller: insuranceWorkAccidentPolicyNumber,
                        text: "Número do documento",
                        suffix: null),
                    const SizedBox(height: 10),
                    Text("Validade",
                      style: TextStyle(
                          fontSize: 16,
                          color: notifier.getwhiteblackcolor,
                          fontFamily: "Gilroy Bold"),
                    ),
                    const SizedBox(height: 10),
                    selectDetail(
                        text: insuranceWorkAccidentExpirationDate != null ? DateFormat('dd/MM/yyyy').format(insuranceWorkAccidentExpirationDate!) : "Seleccionar Data",
                        icon: Icons.keyboard_arrow_down,
                        onclick: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Calendar(selectedDate: insuranceWorkAccidentExpirationDate),
                          )).then((value) {
                            setState(() {
                              insuranceWorkAccidentExpirationDate = value;
                            });
                          });
                        },
                        notifier: notifier
                    ),
                    const SizedBox(height: 25),
                    AppButton(
                        bgColor: notifier.getlogobgcolor,
                        textColor: WhiteColor,
                        buttontext: "Attach Document",
                        onclick: () async {

                        })]
              ])
      ),
      isExpanded: expandedData[index],
    );
  }

  ExpansionPanel _criminalRecordPanel(index) {
    return ExpansionPanel(
      backgroundColor: getBackroundColorByStatus(criminalRecordStatus),
      headerBuilder: (BuildContext context, bool isExpanded) {
        return
          ListTile(
            title: Text(
              'Registo Criminal',
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
          );
      },
      body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppButton(
                    bgColor: notifier.getlogobgcolor,
                    textColor: WhiteColor,
                    buttontext: "Attach Document",
                    onclick: () async {

                    })
              ])
      ),
      isExpanded: expandedData[index],
    );
  }

  /*Future<void> uploadFile(String url, File file) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      // Upload successful
    } else {
      // Handle error
    }
  }*/


  Widget identificationDocumentWidget(ColorNotifier notifier, BuildContext context, List<dynamic> fields) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ ...fields.map((item) {
             return [const SizedBox(height: 10),
               Text(item["name"],
                style: TextStyle(
                    fontSize: 16,
                    color: notifier.getwhiteblackcolor,
                    fontFamily: "Gilroy Bold"),
              ),
              const SizedBox(height: 10),
              if (item["type"] == 'Array')
                selectDetail(
                    text: item["description"](),
                    onclick: () {
                      item["function"]();
                    },
                    notifier: notifier),
              if (item["type"] == 'List')
                 Wrap(
                   spacing: 10.0,
                   children: List<Widget>.generate(
                     item["values"].length,
                         (int index) {
                       return ChoiceChip(
                         backgroundColor: WhiteColor,
                         label: Text(item["values"][index],
                             style: TextStyle(fontSize: 16,
                             color: notifier.getdarkgreycolor,
                             fontFamily: "Gilroy Medium")),
                         selected: item["selectedIndex"] == index,
                         onSelected: (bool selected) {
                           setState(() {
                             item["selectedIndex"] = selected ? index : null;
                             item["field"] = item["values"][index];
                           });
                         },
                       );
                     },
                   ).toList(),
                 ),
              if (item["type"] == 'String')
                textField(
                  fieldColor: notifier.getdarkmodecolor,
                  hintColor: notifier.getdarkgreycolor,
                  controller: item["field"],
                  text: item["description"],
                  suffix: null,
                  formatter: item["formatter"]),
             if (item["type"] == 'Date')
               selectDetail(
                   text: item["field"] != null ? DateFormat('dd/MM/yyyy').format(item["field"]!) : "Seleccionar Data",
                   icon: Icons.keyboard_arrow_down,
                   onclick: () {
                     Navigator.of(context).push(MaterialPageRoute(
                       builder: (context) => Calendar(selectedDate: item["field"]),
                     )).then((value) {
                       setState(() {
                         print(value);
                         print(item["field"]);
                         identificationNumberExpirationDate = value;
                         print(item["field"]);
                         print(identificationNumberExpirationDate);
                       });
                     });
                   },
                   notifier: notifier
               ),
              if (item["type"] == 'Boolean')
                Row(
                  children: [
                    Text(
                      item["description"],
                      style: TextStyle(
                          fontSize: 13,
                          color: greyColor,
                          fontFamily: "Gilroy Medium"),
                    ),
                    CupertinoSwitch(
                      value: item["field"],
                      thumbColor: notifier.getdarkwhitecolor,
                      trackColor: notifier.getbuttoncolor,
                      activeColor: notifier.getdarkbluecolor,
                      onChanged: (value) {
                        setState(() {
                          item["field"] = value;
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 10)
             ];
            }).flattened,
            const SizedBox(height: 10),
            AppButton(
                bgColor: notifier.getlogobgcolor,
                textColor: WhiteColor,
                buttontext: "Attach Document",
                onclick: () async {

                })
          ]
        )
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

  getBackroundColorByStatus(String status) {
    if (status == 'approved') {
      return approved;
    }

    return lightGrey;
  }
}
