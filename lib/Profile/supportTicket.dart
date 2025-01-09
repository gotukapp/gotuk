import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final TextEditingController _messageController = TextEditingController();

  String? _selectedCategory;
  String? _selectedReason;
  bool _isLoading = false;
  late ColorNotifier notifier;

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Ticket ticket = Ticket(null, null,
            _selectedCategory!, _selectedReason!, _subjectController.text, _messageController.text);

        await ticket.submitTicket();

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Support ticket submitted successfully!'),
        ));

        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit ticket: $e'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        title: const Text('Support Ticket'),
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
                hint: const Text('Select Category',
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
                validator: (value) => value == null ? 'Please select a category' : null,
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
                      hint: Text('Select Reason',
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
                      validator: (value) => value == null ? 'Please select a reason' : null,
                    )
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Center(
                  child: AppButton(
                      bgColor: notifier.getwhitelogocolor,
                      textColor: notifier.getblackwhitecolor,
                      buttontext: "Create Ticket",
                      onclick: () async {
                        if (_selectedCategory != null && _selectedReason != null) {
                          _sendEmail();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("You have to select a Category and a Reason to create a ticket."),
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
    final String subject = Uri.encodeComponent(_selectedCategory!);
    final String body = Uri.encodeComponent("Category: ${_selectedCategory!}\nReason: ${_selectedReason!}\nMessage: ");

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
