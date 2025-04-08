// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../Providers/userProvider.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool isLoading = false;

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.fromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  late ColorNotifier notifier;
  late UserProvider userProvider;
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context);

    ImageProvider imageProvider;

    if (_pickedImage != null) {
      imageProvider = FileImage(File(_pickedImage!.path));
    } else if (userProvider.user!.profilePhoto != null) {
      imageProvider =  NetworkImage(userProvider.user!.profilePhoto!);
    } else {
      imageProvider = const AssetImage("assets/images/avatar.png");
    }

    if (!isInitialized && userProvider.user != null) {
      nameController.text = userProvider.user!.name ?? '';
      isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: notifier.getbgcolor,
        leading: BackButton(color: notifier.getwhiteblackcolor),
        title: Text(
          AppLocalizations.of(context)!.myProfile,
          style: TextStyle(
              color: notifier.getwhiteblackcolor, fontFamily: "Gilroy Bold"),
        ),
      ),
      backgroundColor: notifier.getbgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: 200,
                color: notifier.getbgcolor,
                child: Stack(
                  children: [
                    Positioned(
                      top: 25,
                      left: 30,
                      child: CircleAvatar(
                        radius: 68,
                        backgroundImage: imageProvider,
                      ),
                    ),
                    Positioned(
                      top: 85,
                      // bottom: 20,
                      right: 20,
                      // left: 20,
                      child:
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child:  CircleAvatar(
                          radius: 37,
                          backgroundColor: WhiteColor,
                          child: CircleAvatar(
                            radius: 35,
                            child: Image.asset(
                              'assets/images/camera.png',
                              height: 40,
                            ),
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.fullName,
                    style: TextStyle(
                        fontSize: 16,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy Bold"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  textField(
                      fieldColor: notifier.getdarkmodecolor,
                      hintColor: notifier.getgreycolor,
                      text: AppLocalizations.of(context)!.enterYourName,
                      controller: nameController,
                      suffix: null),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.email,
                    style: TextStyle(
                        fontSize: 16,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy Bold"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    userProvider.user!.email ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy"),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.phoneNumber,
                    style: TextStyle(
                        fontSize: 16,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy Bold"),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    userProvider.user!.phone ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: notifier.getwhiteblackcolor,
                        fontFamily: "Gilroy"),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: WhiteColor)) // Show spinner when loading
                  : AppButton(
                  buttontext: AppLocalizations.of(context)!.saveChanges,
                  onclick: () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      if (_pickedImage != null) {
                        final fileName = _pickedImage!.name;
                        final storageRef = FirebaseStorage.instance.ref()
                            .child("uploads/users/${userProvider.user!.id}")
                            .child(fileName);
                        final uploadTask = await storageRef.putFile(File(_pickedImage!.path));
                        final downloadUrl = await uploadTask.ref.getDownloadURL();

                        await FirebaseFirestore.instance.collection('users')
                            .doc(userProvider.user!.id).update({
                          'profilePhoto': downloadUrl,
                          "name": nameController.text
                        });
                      } else {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(userProvider.user!.id)
                            .update({
                          "name": nameController.text
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(AppLocalizations.of(context)!.profileChangesSaved),
                        ));
                    } catch(e) {
                      await Sentry.captureException(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!.errorSubmittingData),
                      ));
                    }

                  setState(() {
                    isLoading = false;
                  });
                }),
            ],
          ),
        ),
      ),
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
