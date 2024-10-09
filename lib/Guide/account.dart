// ignore_for_file: file_names

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
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
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  String status;
  bool isExpanded;
}

Color validated = const Color(0xff66dd66);

List<Item> generateItems(int numberOfItems) {
  return [ Item(
      headerValue: 'Documento de Identificação',
      expandedValue: 'Documento de Identificação',
      status: 'not submitted'
    ),
    Item(
        headerValue: 'Certidão Registo Comercial',
        expandedValue: 'Certidão Registo Comercial',
        status: 'submitted'
    ),
    Item(
        headerValue: 'Licença RNAAT',
        expandedValue: 'Licença RNAAT',
        status: 'validated'
    ),
    Item(
        headerValue: 'Certificação de Formação',
        expandedValue: 'Certificação de Formação',
        status: 'not valid'
    ),
    Item(
        headerValue: 'Apólice de Seguro de Responsabilidade Civil',
        expandedValue: 'Apólice de Seguro de Responsabilidade Civil',
        status: 'not submitted'
    ),
    Item(
        headerValue: 'Apólice de seguro de Acidentes de trabalho',
        expandedValue: 'Apólice de seguro de Acidentes de trabalho',
        status: 'not submitted'
    ),
    Item(
        headerValue: 'Apólice de seguro Automóvel',
        expandedValue: 'Apólice de seguro Automóvel',
        status: 'not submitted'
    ),
    Item(
        headerValue: 'Apólice de Seguro de Acidentes Pessoais',
        expandedValue: 'Apólice de Seguro de Acidentes Pessoais',
        status: 'not submitted'
    )
  ];
}

class _AccountState extends State<account> {
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
          child: Container(
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
          body: identificationDocumentWidget(notifier, context),
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


  Widget identificationDocumentWidget(ColorNotifier notifier, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Identification Number",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            textfield(
                fieldColor: notifier.getdarkmodecolor,
                hintColor: notifier.getgreycolor,
                text: 'Enter your Identification Number',
                suffix: null),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              "Expiration Date",
              style: TextStyle(
                  fontSize: 16,
                  color: notifier.getwhiteblackcolor,
                  fontFamily: "Gilroy Bold"),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            textfield(
                fieldColor: notifier.getdarkmodecolor,
                hintColor: notifier.getgreycolor,
                text: 'Enter your Number',
                suffix: null),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            AppButton(
                bgColor: notifier.getlogobgcolor,
                textColor: WhiteColor,
                buttontext: "Attach Document",
                onclick: () async {

                })
          ],
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
