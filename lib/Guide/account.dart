// ignore_for_file: file_names

import 'package:collection/collection.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class account extends StatefulWidget {
  const account({super.key});

  @override
  State<account> createState() => _AccountState();
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    required this.status,
    required this.fields,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  String status;
  bool isExpanded;
  List<dynamic> fields;
}

Color validated = const Color(0xff66dd66);

List<Item> generateItems(int numberOfItems) {
  return [ Item(
      headerValue: 'Documento de Identificação',
      expandedValue: 'Documento de Identificação',
      status: 'not submitted',
      fields: [
        { "name": "Nº CC/Passaporte", "description": "Número do documento", "type": "String"},
        { "name": "Validade", "description": "Data de Validade", "type": "String"},
        { "name": "Carta de condução", "description": "Número do documento", "type": "String"},
        { "name": "Validade", "description": "Data de Validade", "type": "String"}
      ]
    ),
    Item(
        headerValue: 'Comprovativo de Actividade',
        expandedValue: 'Comprovativo de Actividade',
        status: 'submitted',
        fields: [
          { "name": "Declaração Abertura Atividade ", "description": "", "type": "String"},
        ]
    ),
    Item(
        headerValue: 'Licença RNAAT',
        expandedValue: 'Licença RNAAT',
        status: 'validated',
        fields: [
          { "name": "Nº Registo", "description": "", "type": "String"}
        ]
    ),
    Item(
        headerValue: 'Formação',
        expandedValue: 'Formação',
        status: 'not valid',
        fields: []
    ),
    Item(
        headerValue: 'Apólice de Seguro de Responsabilidade Civil',
        expandedValue: 'Apólice de Seguro de Responsabilidade Civil',
        status: 'not submitted',
        fields: [
          { "name": "Companhia de Seguros", "description": "Nome", "type": "String"},
          { "name": "Nº Apólice", "description": "Indique o Número", "type": "String"},
          { "name": "Validade", "description": "Data de Validade", "type": "String"}
        ]
    ),
    Item(
        headerValue: 'Apólice de seguro de Acidentes de trabalho',
        expandedValue: 'Apólice de seguro de Acidentes de trabalho',
        status: 'not submitted',
        fields: [
          { "name": "Companhia de Seguros", "description": "Nome", "type": "String"},
          { "name": "Nº Apólice", "description": "Indique o Número", "type": "String"},
          { "name": "Validade", "description": "Data de Validade", "type": "String"}
        ]
    ),
    Item(
        headerValue: 'Apólice de Seguro de Acidentes Pessoais',
        expandedValue: 'Apólice de Seguro de Acidentes Pessoais',
        status: 'not submitted',
        fields: [
          { "name": "Companhia de Seguros", "description": "Nome", "type": "String"},
          { "name": "Nº Apólice", "description": "Indique o Número", "type": "String"},
          { "name": "Validade", "description": "Data de Validade", "type": "String"}
        ]
    ),
    Item(
        headerValue: 'Dados do Veículo',
        expandedValue: 'Dados do Veículo',
        status: 'not submitted',
        fields: [
          { "name": "Matrícula", "description": "", "type": "String"},
          { "name": "Lugares", "description": "", "type": "String"},
          { "name": "Veículo Eléctrico", "description": "", "type": "Boolean"},
          { "name": "Companhia de Seguros", "description": "Nome", "type": "String"},
          { "name": "Nº Apólice", "description": "Indique o Número", "type": "String"},
          { "name": "Validade", "description": "Data de Validade", "type": "String"}
        ]
    )
  ];
}

class _AccountState extends State<account> {
  bool onlyElectricVehicles = false;

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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

                  })
            ]
          )
        ),
      ),
    );
  }

  final List<Item> _data = generateItems(8);

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
            return ListTile(
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
                  hintColor: notifier.getgreycolor,
                  text: item["description"],
                  suffix: null),
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
                      value: onlyElectricVehicles,
                      thumbColor: notifier.getdarkwhitecolor,
                      trackColor: notifier.getbuttoncolor,
                      activeColor: notifier.getdarkbluecolor,
                      onChanged: (value) {
                        setState(() {
                          onlyElectricVehicles = value;
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
    if (item.status == 'validated') {
      return validated;
    }

    return lightGrey;
  }
}
