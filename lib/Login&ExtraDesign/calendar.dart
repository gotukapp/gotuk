// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class calendar extends StatefulWidget {
  @override
  calendarState createState() => calendarState();
}

class calendarState extends State<calendar> {
  DateTime? _selectedDate;
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  /// The method for [DateRangePickerSelectionChanged] callback, which will be
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      DateTime? now = DateTime.now(); //lets say Jul 25 10:35:90
      var currentDate = DateTime(now.year, now.month,  now.day - 1);

      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime && args.value.compareTo(currentDate) > 0) {
        _selectedDate = args.value;
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: CustomAppbar(
                    centertext: "Calendar",
                    ActionIcon: Icons.more_vert,
                    bgcolor: notifire.getbgcolor,
                    actioniconcolor: notifire.getwhiteblackcolor,
                    leadingiconcolor: notifire.getwhiteblackcolor,
                    titlecolor: notifire.getwhiteblackcolor)),
            backgroundColor: notifire.getbgcolor,
            // ignore: sized_box_for_whitespace
            bottomNavigationBar: Container(
              height: 80,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, _selectedDate);
                        },
                        child: Container(
                          height: 70,
                          width: MediaQuery.of(context).size.width * 0.95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Darkblue,
                          ),
                          child: Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: WhiteColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Stack(
                    children: <Widget>[
                      const Positioned(
                        height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                      SfDateRangePicker(
                        rangeTextStyle: TextStyle(color: WhiteColor),
                        toggleDaySelection: true,
                        endRangeSelectionColor: Darkblue,
                        startRangeSelectionColor: Darkblue,
                        monthCellStyle: DateRangePickerMonthCellStyle(
                            blackoutDateTextStyle: TextStyle(color: Darkblue)),
                        backgroundColor: notifire.getbgcolor,
                        onSelectionChanged: _onSelectionChanged,
                        selectionMode: DateRangePickerSelectionMode.single,
                        initialSelectedRange: PickerDateRange(
                            DateTime.now().subtract(const Duration(days: 4)),
                            DateTime.now().add(const Duration(days: 3))),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 2.22),
                ],
              ),
            )));
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }
}
