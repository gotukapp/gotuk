import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';

class FullMap extends StatefulWidget {
  final String tourId;

  const FullMap(this.tourId, {super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapLibreMapController? mapController;
  var isLight = true;
  late ColorNotifier notifier;
  late Circle circle;
  late Timer showStarPoint;
  bool showStarPointIsActive = false;
  int index = 0;
  List<LatLng> routeCoordinates = [];

  Future<void> addImageFromAsset(String name, String assetName) async {
    final bytes = await rootBundle.load(assetName);
    final list = bytes.buffer.asUint8List();
    return mapController!.addImage(name, list);
  }

  double markerProgress = 0.0;

  List<List<double>> rawCoords = [];
  Future<void> uploadRoute(String tourId) async {
    final routeRef = FirebaseFirestore.instance
        .collection('tours')
        .doc(tourId)
        .collection('route');

    for (int i = 0; i < rawCoords.length; i++) {
      final coord = rawCoords[i];
      await routeRef.add({
        'order': i,
        'coordinates': GeoPoint(coord[1], coord[0]), // lat, lng
      });
    }
  }

  Future<void> loadRoute() async {
    final tourId = widget.tourId;
    final snapshot = await FirebaseFirestore.instance
        .collection('tours')
        .doc(tourId)
        .collection('route')
        .orderBy('order') // ensure correct sequence
        .get();

    setState(() {
      routeCoordinates = snapshot.docs.map((doc) {
        final geoPoint = doc['coordinates'] as GeoPoint;
        return LatLng(geoPoint.latitude, geoPoint.longitude);
      }).toList();
    });
  }

  _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
  }

  Future<void> followRoute(
      List<LatLng> route,
      {double zoom = 17, double tilt = 60, Duration stepDuration = const Duration(milliseconds: 500)}
      ) async {
    if (route.length < 2) return;

    for (int i = 0; i < route.length - 1; i++) {
      final current = route[i];
      final next = route[i + 1];

      final bearing = _calculateBearing(current, next);

      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: next,
            zoom: zoom,
            bearing: bearing,
            tilt: tilt,
          ),
        ),
        duration: stepDuration,
      );

      await Future.delayed(stepDuration);
    }
  }

  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * (pi / 180);
    final lat2 = to.latitude * (pi / 180);
    final lon1 = from.longitude * (pi / 180);
    final lon2 = to.longitude * (pi / 180);
    final dLon = lon2 - lon1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }

  rotateCamera(position, bearing, duration, zoom) async {
      await mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: zoom,
            bearing: bearing,
            tilt: 60,)
      ), duration: Duration(seconds: duration));
  }

  LatLng getSouthWest(List<LatLng> points) {
    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    return LatLng(minLat, minLng);
  }

  LatLng getNorthEast(List<LatLng> points) {
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    return LatLng(maxLat, maxLng);
  }

  Symbol? movingSymbol;


  _onStyleLoadedCallback() async {
    await loadRoute();
    if (routeCoordinates.isNotEmpty) {
      addImageFromAsset("star-marker", "assets/images/star.png");
      final routeLine = <LatLng>[...routeCoordinates];
      mapController?.addLine(
        LineOptions(
            draggable: false,
            lineColor: "#ff0000",
            lineWidth: 6.0,
            lineOpacity: 0.7,
            geometry: routeLine
        ),
      );

      if (routeLine.isNotEmpty) {
        await mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: getSouthWest(routeLine),
              northeast: getNorthEast(routeLine),
            ),
            left: 24,
            top: 24,
            right: 24,
            bottom: 24,
          )
        , duration: const Duration(seconds: 3));

        await tourRoute(widget.tourId);
      }
    }
  }

  CameraPosition kInitialPosition = const CameraPosition(
    target: LatLng(38.7100, -9.1307),
    zoom: 10,
  );

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "Tour Details",
              ActionIcon: null,
              bgcolor: notifier.getblackwhitecolor,
              actioniconcolor: notifier.getwhiteblackcolor,
              leadingiconcolor: notifier.getwhiteblackcolor,
              titlecolor: notifier.getwhiteblackcolor)),
      backgroundColor: notifier.getblackwhitecolor,
      body: MapLibreMap(
        styleString: 'https://maps.geo.eu-south-2.amazonaws.com/maps/v0/maps/gotuk/style-descriptor?key=v1.public.eyJqdGkiOiIxNTc3NWE1NS00NjJmLTQzMGUtOTkxZS0zMjM4ODVjMjc3ZWIifbXmeDGXMAZqEl2sUE6KYfKX_E4EqSN4RpOtV84uQDoivjwmekY429E6K4EYjOxYDLhdXwpOO-qR4-zHkDsuzb_Eb6BbKLzkr6nO27fG13B59qntX34q7FXlFnrKpTMNNLE2uQNBq0DmsU6loGCTooT6wYnytCorv5JJ7z7sMCgULmR_e2fiMcasLKSaQkt5fDzh7TAVz4-22ENzJCt7xdXGGuv6gEeqSmuCer8B7ewj73f-7AdHZNmOuupQu3ExoApvY4WEe5WjolGv18qqL9x1PfKFp_mx3UQjhYwkbtSbcTy29QTaTsMsxpsE4015Nt--JbyKG73cj0mP6MaCMHs.MmMzNmNhMzctMTc3ZC00YTI2LWIwOTItZWE3NGI0OWVhMWM1',
        onMapCreated: _onMapCreated,
        initialCameraPosition: kInitialPosition,
        onStyleLoadedCallback: _onStyleLoadedCallback,
      ));
  }

  @override
  void dispose() {
    super.dispose();
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



  Future<void> tourRoute(String tourId) async {
    if (tourId == 'iFeHZGf61ZR6RsCxZFUf') {
      await rotateCamera(routeCoordinates[2], 160.0, 4, 17.0);
      rotateCamera(routeCoordinates[105], 260.0, 9, 15.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[225], 250.0, 8, 14.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[300], 250.0, 10, 16.0);
      await Future.delayed(const Duration(seconds: 8));
      rotateCamera(routeCoordinates[330], 80.0, 7, 15.0);
      await Future.delayed(const Duration(seconds: 4));
      rotateCamera(routeCoordinates[360], 85.0, 6, 13.5);
    }

    if (tourId == 'iPvTzM9QAK99KjlmWOQc') {
      await rotateCamera(routeCoordinates[2], 310.0, 4, 17.0);
      rotateCamera(routeCoordinates[60], 300.0, 9, 16.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[90], 250.0, 8, 15.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[120], 310.0, 8, 15.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[140], 310.0, 8, 16.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[110], 70.0, 8, 14.0);
    }

    if (tourId == 'lrBbhAD64JMbq81yjUAF') {
      await rotateCamera(routeCoordinates[2], 80.0, 4, 17.0);
      rotateCamera(routeCoordinates[45], 280.0, 9, 16.0);
      await Future.delayed(const Duration(seconds: 8));
      rotateCamera(routeCoordinates[95], 200.0, 8, 16.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[170], 320.0, 8, 16.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[210], 5.0, 8, 16.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[305], 5.0, 8, 16.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[320], 100.0, 8, 15.0);
      await Future.delayed(const Duration(seconds: 6));
      rotateCamera(routeCoordinates[315], 190.0, 8, 14.0);
    }
  }
}
