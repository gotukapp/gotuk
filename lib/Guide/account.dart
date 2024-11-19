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
  final identificationNumber = TextEditingController();
  final drivingLicenseNumber = TextEditingController();
  final licenseRNAATNumber = TextEditingController();
  DateTime? identificationNumberExpirationDate;
  DateTime? drivingLicenseExpirationDate;

  final insuranceCompanyName = TextEditingController();
  final insurancePolicyNumber = TextEditingController();
  DateTime? insuranceExpirationDate;

  final insuranceWorkAccidentCompanyName = TextEditingController();
  final insuranceWorkAccidentPolicyNumber = TextEditingController();
  DateTime? insuranceWorkAccidentExpirationDate;

  final insurancePersonalAccidentCompanyName = TextEditingController();
  final insurancePersonalAccidentPolicyNumber = TextEditingController();
  DateTime? insurancePersonalAccidentExpirationDate;

  final vehicleLicensePlate = TextEditingController();
  final vehicleSeatsNumber = TextEditingController();
  final vehicleInsuranceCompanyName = TextEditingController();
  final vehicleInsurancePolicyNumber = TextEditingController();
  DateTime? vehicleInsuranceExpirationDate;
  late List<Item> _data;

  late UserProvider userProvider;
  late ColorNotifier notifier;

  @override
  void initState() {
    getdarkmodepreviousstate();
    _data = generateItems(8);
    _loadDocument();
    super.initState();
  }

  List<Item> generateItems(int numberOfItems) {
    return [ Item(
        itemName: 'identificationDocuments',
        headerValue: 'Documento de Identificação',
        expandedValue: 'Documento de Identificação',
        status: 'not approved',
        fields: [
          { "name": "Nº CC/Passaporte", "description": "Número do documento", "type": "String", "fieldName":"identificationNumber", "field": identificationNumber },
          { "name": "Validade", "description": "Data de Validade", "type": "Date", "fieldName":"identificationNumberExpirationDate", "field": identificationNumberExpirationDate},
          { "name": "Carta de condução", "description": "Número do documento", "type": "String", "fieldName":"drivingLicenseNumber", "field": drivingLicenseNumber },
          { "name": "Validade", "description": "Data de Validade", "type": "Date", "fieldName":"drivingLicenseExpirationDate", "field": drivingLicenseExpirationDate }
        ]
    ),
      Item(
          itemName: 'activity',
          headerValue: 'Comprovativo de Actividade',
          expandedValue: 'Comprovativo de Actividade',
          status: 'not approved',
          fields: [
            { "name": "Declaração Abertura Atividade", "description": "", "type": "String"},
          ]
      ),
      Item(
          itemName: 'licenseRNAAT',
          headerValue: 'Licença RNAAT',
          expandedValue: 'Licença RNAAT',
          status: 'not approved',
          fields: [
            { "name": "Nº Registo", "description": "", "type": "String", "fieldName": "licenseRNAATNumber", "field": licenseRNAATNumber }
          ]
      ),
      Item(
          itemName: 'training',
          headerValue: 'Formação',
          expandedValue: 'Formação',
          status: 'not approved',
          fields: []
      ),
      Item(
          itemName: 'civilLiabilityInsurancePolicy',
          headerValue: 'Apólice de Seguro de Responsabilidade Civil',
          expandedValue: 'Apólice de Seguro de Responsabilidade Civil',
          status: 'not approved',
          fields: [
            { "name": "Companhia de Seguros", "description": "Nome", "type": "String", "fieldName": "insuranceCompanyName", "field": insuranceCompanyName },
            { "name": "Nº Apólice", "description": "Indique o Número", "type": "String", "fieldName": "insurancePolicyNumber", "field": insurancePolicyNumber },
            { "name": "Data de Validade", "description": "Data de Validade", "type": "Date", "fieldName": "insuranceExpirationDate", "field": insuranceExpirationDate }
          ]
      ),
      Item(
          itemName: 'workAccidentInsurancePolicy',
          headerValue: 'Apólice de seguro de Acidentes de trabalho',
          expandedValue: 'Apólice de seguro de Acidentes de trabalho',
          status: 'not approved',
          fields: [
            { "name": "Companhia de Seguros", "description": "Nome", "type": "String", "fieldName": "insuranceWorkAccidentCompanyName", "field": insuranceWorkAccidentCompanyName},
            { "name": "Nº Apólice", "description": "Indique o Número", "type": "String", "fieldName": "insuranceWorkAccidentPolicyNumber", "field": insuranceWorkAccidentPolicyNumber},
            { "name": "Data de Validade", "description": "Data de Validade", "type": "Date", "fieldName": "insuranceWorkAccidentExpirationDate", "field": insuranceWorkAccidentExpirationDate }
          ]
      ),
      Item(
          itemName: 'personalAccidentInsurancePolicy',
          headerValue: 'Apólice de Seguro de Acidentes Pessoais',
          expandedValue: 'Apólice de Seguro de Acidentes Pessoais',
          status: 'not approved',
          fields: [
            { "name": "Companhia de Seguros", "description": "Nome", "type": "String", "fieldName": "insurancePersonalAccidentCompanyName", "field": insurancePersonalAccidentCompanyName},
            { "name": "Nº Apólice", "description": "Indique o Número", "type": "String", "fieldName": "insurancePersonalAccidentPolicyNumber", "field": insurancePersonalAccidentPolicyNumber},
            { "name": "Data de Validade", "description": "Data de Validade", "type": "Date", "fieldName": "insurancePersonalAccidentExpirationDate", "field": insurancePersonalAccidentExpirationDate }
          ]
      ),
      Item(
          itemName: 'vehicleData',
          headerValue: 'Dados do Veículo',
          expandedValue: 'Dados do Veículo',
          status: 'not approved',
          fields: [
            { "name": "Matrícula", "description": "", "type": "String", "fieldName": "vehicleLicensePlate", "field": vehicleLicensePlate },
            { "name": "Lugares", "description": "", "type": "String", "fieldName": "vehicleSeatsNumber", "field": vehicleSeatsNumber },
            { "name": "Veículo Eléctrico", "description": "", "type": "Boolean", "fieldName": "vehicleType", "field": vehicleType },
            { "name": "Companhia de Seguros", "description": "Nome", "type": "String", "fieldName": "vehicleInsuranceCompanyName", "field": vehicleInsuranceCompanyName },
            { "name": "Nº Apólice", "description": "Indique o Número", "type": "String", "fieldName": "vehicleInsurancePolicyNumber", "field": vehicleInsurancePolicyNumber },
            { "name": "Data de Validade", "description": "Data de Validade", "type": "Date", "fieldName": "vehicleInsuranceExpirationDate", "field": vehicleInsuranceExpirationDate }
          ]
      )
    ];
  }

  Future<void> _loadDocument() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('documents')
          .orderBy('submitDate', descending: true) // Sort by 'datetime' in descending order
          .limit(1) // Limit to 1 document
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          Map<String, dynamic>? data = querySnapshot.docs.first.data();
          for(Item item in _data) {
            item.status = data.containsKey(item.itemName) ? data[item.itemName] : "not approved";
            for(dynamic field in item.fields) {
              if (data.containsKey(field["fieldName"])) {
                if (field["type"] == 'String') {
                  field["field"].text = data[field["fieldName"]];
                } else if (field["type"] == 'Date') {
                  field["field"] = data[field["fieldName"]].toDate();
                } else {
                  field["field"] = data[field["fieldName"]];
                }
              }
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
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
                              user.submitAccountData(_data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Account information submitted successfully!"),
                                ),
                              );
                              Navigator.of(context).pop();
                            })
                      ]
                  )
              ),
            )
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          backgroundColor: getBackroundColorByStatus(item),
          headerBuilder: (BuildContext context, bool isExpanded) {
            return
              ListTile(
                title: Text(
                  item.headerValue,
                  style: TextStyle(
                      fontSize: 16,
                      color: notifier.getwhiteblackcolor,
                      fontFamily: "Gilroy Bold"),
                ),
              );
          },
          body: identificationDocumentWidget(notifier, context, item.fields),
          isExpanded: item.isExpanded,
        );
      }).toList(),
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
              if (item["type"] == 'String')
                textfield(
                  fieldColor: notifier.getdarkmodecolor,
                  hintColor: notifier.getdarkgreycolor,
                  controller: item["field"],
                  text: item["description"],
                  suffix: null),
             if (item["type"] == 'Date')
               selectDetail(
                   text: item["field"] != null ? DateFormat('dd/MM/yyyy').format(item["field"]!) : "Seleccionar Data",
                   icon: Icons.keyboard_arrow_down,
                   onclick: () {
                     Navigator.of(context).push(MaterialPageRoute(
                       builder: (context) => Calendar(selectedDate: item["field"]),
                     )).then((value) {
                       setState(() {
                         item["field"] = value; // you receive here
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

  getBackroundColorByStatus(Item item) {
    if (item.status == 'approved') {
      return approved;
    }

    return lightGrey;
  }
}
