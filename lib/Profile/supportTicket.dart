import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Domain/ticket.dart';
import '../Domain/trip.dart';
import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';

class SupportTicket extends StatefulWidget {
  final Trip? trip;
  final String? category;
  final String? reason;

  const SupportTicket(this.trip, this.category, this.reason, {super.key});

  @override
  State<SupportTicket> createState() => _SupportTicketState();
}

class _SupportTicketState extends State<SupportTicket> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();

  String? _selectedCategory;
  String? _selectedReason;
  bool _isLoading = false;
  late ColorNotifier notifier;

  @override
  void initState() {
    _selectedCategory = widget.category;
    _selectedReason = widget.reason;

    getdarkmodepreviousstate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    _subjectController.text = (widget.trip != null ? widget.trip?.reservationId : "")!;
    return Scaffold(
      backgroundColor: notifier.getblackwhitecolor,
      appBar: AppBar(
        backgroundColor: notifier.getblackwhitecolor,
        title: Text(AppLocalizations.of(context)!.supportTicket),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Theme(
              data: Theme.of(context).copyWith(
                disabledColor: BlackColor, // Custom color for this specific DropdownButtonFormField
              ),
              child:
                 DropdownButtonFormField<String>(
                value: _selectedCategory,
                style: TextStyle(
                    color: BlackColor2,
                    fontSize: 16,
                    fontFamily: "Gilroy Bold"),
                hint: Text(AppLocalizations.of(context)!.selectCategory,
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Gilroy Bold")),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: LogoColor), // Color when not focused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: LogoColor, width: 2.0), // Color when focused
                  ),
                ),
                onChanged: widget.trip == null ? (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    _selectedReason = null; // Reset subcategory when category changes
                  });
                } : null,
                items: ticketReasons.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectCategory : null,
              )
              ),
              const SizedBox(height: 10),
              Theme(
                data: Theme.of(context).copyWith(
                  disabledColor: BlackColor, // Custom color for this specific DropdownButtonFormField
                ),
                child:
                  DropdownButtonFormField<String>(
                      value: _selectedReason,
                      style: TextStyle(
                        color: BlackColor,
                        fontSize: 16,
                        fontFamily: "Gilroy Bold"),
                      hint: Text(AppLocalizations.of(context)!.selectReason,
                          style: TextStyle(
                              color: lightBlack,
                              fontSize: 18,
                              fontFamily: "Gilroy Bold")),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: LogoColor), // Color when not focused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: LogoColor, width: 2.0), // Color when focused
                        ),
                      ),
                      onChanged: widget.trip == null ? (newValue) {
                        setState(() {
                          _selectedReason = newValue;
                        });
                      } : null,
                      items: _selectedCategory == null
                          ? []
                          : ticketReasons[_selectedCategory]!.map((reason) {
                        return DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        );
                      }).toList(),
                      validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectReason : null,
                    )
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Center(
                  child: AppButton(
                      bgColor: notifier.getwhitelogocolor,
                      textColor: notifier.getblackwhitecolor,
                      buttontext: AppLocalizations.of(context)!.createSupportTicket,
                      onclick: () async {
                        if (_selectedCategory != null && _selectedReason != null) {
                          _sendEmail();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.createTicketWarning),
                            ),
                          );
                        }

                      })
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendEmail() async {
    const String email = 'suporte@gotuk.pt';
    final String subject = Uri.encodeComponent("${_selectedCategory!} - ${_selectedReason!}");
    final String body = Uri.encodeComponent("");

    final Uri emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
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
