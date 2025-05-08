// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field

import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Calendar extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime? maxDate;
  final DateTime? minDate;

  const Calendar({super.key, this.selectedDate, this.minDate, this.maxDate});

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  DateTime? _selectedDate ;
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
      } else if(args.value != null) {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  void initState() {
    _selectedDate = widget.selectedDate;
    getdarkmodepreviousstate();
    super.initState();
  }

  late ColorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: notifier.getbgcolor,
                  leading: BackButton(
                      color: notifier.getwhiteblackcolor,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  title: Text(
                    AppLocalizations.of(context)!.calendar,
                    style: TextStyle(
                        color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
                  ),
                )),
            backgroundColor: notifier.getbgcolor,
            // ignore: sized_box_for_whitespace
            bottomNavigationBar: Container(
              height: 80,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: InkWell(
                        onTap: () {
                          Navigator.pop(context, _selectedDate);
                        },
                    enableFeedback: true,
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Darkblue,
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.proceed,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: WhiteColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
              ),
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
                        minDate: widget.minDate,
                        maxDate: widget.maxDate,
                        rangeTextStyle: TextStyle(color: WhiteColor),
                        view: DateRangePickerView.month,
                        toggleDaySelection: true,
                        endRangeSelectionColor: Darkblue,
                        startRangeSelectionColor: Darkblue,
                        monthCellStyle: DateRangePickerMonthCellStyle(
                            blackoutDateTextStyle: TextStyle(color: Darkblue)),
                        backgroundColor: notifier.getbgcolor,
                        onSelectionChanged: _onSelectionChanged,
                        selectionMode: DateRangePickerSelectionMode.single,
                        initialSelectedDate: _selectedDate,
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
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previusstate;
    }
  }
}
