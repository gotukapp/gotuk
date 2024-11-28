// import 'package:dm/hoteldetailage.dart';
// ignore_for_file: unused_field, library_private_types_in_public_api, camel_case_types

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Profile/profile.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:dm/Domain/trips.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Domain/appUser.dart';
import '../Providers/userProvider.dart';
import '../Guide/dashboard.dart';
import 'home.dart';
import '../Message/message.dart';

int selectedIndex = 0;

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  late int _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;
  bool guideMode = false;
  StreamSubscription<QuerySnapshot<Object?>>? listener;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playNotificationSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/notification.mp3'), // Caminho do som
      );
    } catch (e) {
      print("Erro ao reproduzir som: $e");
    }
  }

  @override
  void initState() {
    getdarkmodepreviousstate();
    getAppModeState();
    initializeNotifications();
    super.initState();
  }

  late ColorNotifier notifier;
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    final pageOption = [
      const home(),
      const message(),
      const profile(),
    ];

    final driverPageOption = guideMode ? [
      Dashboard(guide: userProvider.user!),
      const message(),
      const profile(),
    ] : [];

    return
        // WillPopScope(
        // // onWillPop: _handleWillPop,
        // child:
        Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: notifier.getwhiteblackcolor,
        backgroundColor: notifier.getbgcolor,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Gilroy Bold', fontWeight: FontWeight.bold),
        fixedColor: notifier.getwhiteblackcolor,
        unselectedLabelStyle: const TextStyle(fontFamily: 'Gilroy Medium'),
        currentIndex: selectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/homeicon.png",
                  color: selectedIndex == 0 ? Darkblue : greyColor,
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/message.png",
                  color: selectedIndex == 1 ? Darkblue : greyColor,
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Message'),
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/profile.png",
                color: selectedIndex == 2 ? Darkblue : greyColor,
                height: MediaQuery.of(context).size.height / 35),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {});
          selectedIndex = index;
        },
      ),
      body: guideMode ? driverPageOption[selectedIndex] : pageOption[selectedIndex],
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

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;

    if (guideMode) {
      AppUser guide = userProvider.user!;
      if (guide.accountValidated) {
        addFirebaseTripsListen();
      }
    }
  }

  @override
  void dispose() {
    print("dispose homepage");
    if (listener != null) {
      listener?.cancel();
    }
    selectedIndex = 0;
    super.dispose();
  }

  void addFirebaseTripsListen() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
    FirebaseFirestore.instance.collection('trips').snapshots();

    bool isFirstTime = true;
    listener = usersStream.listen((onData) {
      if (!isFirstTime) {
        for (var change in onData.docChanges) {
          if (change.type == DocumentChangeType.added) {
            Trip t = Trip.fromFirestore(change.doc, null);
            if (t.status == 'pending' ||
                (t.status == 'booked' && t.guideRef?.id == FirebaseAuth.instance.currentUser?.uid)) {
              int duration = t.status == 'booked' ? 10 : 60;
              playNotificationSound();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: duration),
                  content: newTripNotification(context, notifier, t),
                ),
              );
            }
          }
        }
      }
      isFirstTime = false;
    });
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Ícone padrão

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Método para exibir a notificação com som do dispositivo
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // Sons padrão ativados
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true, // Sons padrão ativados
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    print("show notification");
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
