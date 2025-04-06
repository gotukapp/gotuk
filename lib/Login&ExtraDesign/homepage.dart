// import 'package:dm/hoteldetailage.dart';
// ignore_for_file: unused_field, library_private_types_in_public_api, camel_case_types

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dm/Guide/selectTukTuk.dart';
import 'package:dm/Login&ExtraDesign/tripDetail.dart';
import 'package:dm/Login&ExtraDesign/tripFinished.dart';
import 'package:dm/Profile/profile.dart';
import 'package:dm/Utils/Colors.dart';
import 'package:dm/Utils/customwidget%20.dart';
import 'package:dm/Utils/dark_lightmode.dart';
import 'package:dm/Domain/trip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Domain/appUser.dart';
import '../Domain/tour.dart';
import '../Message/chatting.dart';
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
  StreamSubscription<QuerySnapshot<Object?>>? tourListener;
  StreamSubscription<QuerySnapshot<Object?>>? listener;
  StreamSubscription<QuerySnapshot<Object?>>? appNotificationslistener;
  StreamSubscription<DocumentSnapshot<Object?>>? userListener;

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
    addUserListen();
    addTourListen();
    addTripsListen();
    addAppNotificationsListen();
    initializeNotifications();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });

    super.initState();
  }

  Future<void> _handleNotificationClick(RemoteMessage message) async {
    final data = message.data;
    final tripId = data['tripId'];
    final type = data['type'];

    if (tripId != null && type != null) {
      final ref = FirebaseFirestore.instance.collection("trips").doc(tripId)
          .withConverter(
        fromFirestore: Trip.fromFirestore,
        toFirestore: (Trip trip, _) => trip.toFirestore(),
      );
      DocumentSnapshot<Trip> tripSnapshot = await ref.get();
      Trip trip = tripSnapshot.data()!;
      DocumentSnapshot<AppUser>? snapshot;
      if (guideMode) {
        final convertedDocRef = trip.clientRef!.withConverter<AppUser>(
          fromFirestore: AppUser.fromFirestore,
          toFirestore: (AppUser user, _) => user.toFirestore(),
        );
        snapshot = await convertedDocRef.get();
      } else {
        final convertedDocRef = trip.guideRef!.withConverter<AppUser>(
          fromFirestore: AppUser.fromFirestore,
          toFirestore: (AppUser user, _) => user.toFirestore(),
        );
        snapshot = await convertedDocRef.get();
      }
      AppUser appUser = snapshot.data()!;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Chatting(trip: trip, sendTo: appUser)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TripDetail(tripId)));
    }
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
      const Dashboard(),
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
              label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/message.png",
                  color: selectedIndex == 1 ? Darkblue : greyColor,
                  height: MediaQuery.of(context).size.height / 35),
              label: AppLocalizations.of(context)!.messages),
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/profile.png",
                color: selectedIndex == 2 ? Darkblue : greyColor,
                height: MediaQuery.of(context).size.height / 35),
            label: AppLocalizations.of(context)!.profile,
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

  @override
  void dispose() {
    print("dispose homepage");
    if (listener != null) {
      listener?.cancel();
    }
    if (tourListener != null) {
      tourListener?.cancel();
    }
    if (appNotificationslistener != null) {
      appNotificationslistener?.cancel();
    }
    if (userListener != null) {
      userListener?.cancel();
    }
    selectedIndex = 0;
    super.dispose();
  }

  void addTripsListen() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
    FirebaseFirestore.instance.collection('trips').snapshots();

    bool isFirstTime = true;
    listener = usersStream.listen((onData) async {
      final prefs = await SharedPreferences.getInstance();
      bool guideMode = prefs.getBool("setGuideMode") ?? false;

      for (var change in onData.docChanges) {
        if (change.type == DocumentChangeType.added) {
          if (guideMode && !isFirstTime) {
            AppUser guide = userProvider.user!;
            if (guide.accountValidated) {
              Trip t = Trip.fromFirestore(change.doc, null);
              if ((t.status == 'pending' && await checkGuideRequirements(t) &&
                  await AppUser.isGuideAvailable(t))
                  || (t.status == 'booked' && t.guideRef?.id ==
                      FirebaseAuth.instance.currentUser?.uid)) {
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
        } else if (change.type == DocumentChangeType.modified) {
          if (!guideMode && change.doc.get("status") == 'finished') {
            Trip t = Trip.fromFirestore(change.doc, null);
            if (t.clientRef?.id == FirebaseAuth.instance.currentUser?.uid && !t.rateSubmitted) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TourFinishedScreen(t)));
            }
          }
        }
      }

      isFirstTime = false;
    });
  }

  void addAppNotificationsListen() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
    FirebaseFirestore.instance.collection('notifications').snapshots();

    bool isFirstTime = true;
    appNotificationslistener = usersStream.listen((onData) async {
      if (!isFirstTime) {
        for (var change in onData.docChanges) {
        if (change.type == DocumentChangeType.added) {
            if (change.doc.get("userRef").id == FirebaseAuth.instance.currentUser!.uid) {
              playNotificationSound();
            }
          }
        }
      }
      isFirstTime = false;
    });
  }

  void addTourListen() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
    FirebaseFirestore.instance.collection('tours').snapshots();

    tourListener = usersStream.listen((onData) async {
      for (var change in onData.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          Tour updatedTour = Tour.fromFirestore(change.doc, null);
          Tour? tour = Tour.availableTours.firstWhereOrNull((t) =>
          t.id == change.doc.id);
          if (tour != null) {
            Tour.availableTours.remove(tour);
            Tour.availableTours.add(updatedTour);
          }
        }
      }
    });
  }

  void addUserListen() {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> usersStream =
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots();

    userListener = usersStream.listen((docSnapshot) async {
      if (docSnapshot.exists) {
        if (docSnapshot.data()!.containsKey('needSelectTukTuk') && docSnapshot.get("needSelectTukTuk")) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SelectTukTuk()));
        }
      }
    });
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Ícone padrão

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<bool> checkGuideRequirements(Trip t) async {
    AppUser user = userProvider.user!;
    DocumentSnapshot otherUserData = await FirebaseFirestore.instance.collection("users")
        .doc(user.id).get();


    List<String> requiredLanguages = t.guideLang.split(" ");
    if (requiredLanguages.isNotEmpty && user.languages != null) {
      bool hasRequiredLanguage = requiredLanguages.any((lang) =>
          user.languages!.contains(lang));
      if (!hasRequiredLanguage) {
        return false;
      }
    }

    // TukTuk Seats
    if (t.persons > otherUserData.get("tuktukSeats")) {
      return false;
    }

    //TukTuk Electric
    if (t.onlyElectricVehicles != null
        && t.onlyElectricVehicles!
        && !otherUserData.get("tuktukElectric")) {
      return false;
    }

    return true;
  }

  getAppModeState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setGuideMode");
    guideMode = previousState ?? false;
  }
}
