import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Colors.dart';
import '../Utils/customwidget .dart';
import '../Utils/dark_lightmode.dart';
import '../Utils/tour.dart';

class FullMapPage extends StatelessWidget {
  const FullMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FullMap();
  }
}

class FullMap extends StatefulWidget {
  const FullMap({super.key});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapLibreMapController? mapController;
  var isLight = true;
  late ColorNotifire notifire;
  late Circle circle;
  late Timer routeTimer;
  late Timer showStarPoint;
  bool showStarPointIsActive = false;
  int index = 0;
  late OverlayEntry overlayEntry;

  Future<void> addImageFromAsset(String name, String assetName) async {
    final bytes = await rootBundle.load(assetName);
    final list = bytes.buffer.asUint8List();
    return mapController!.addImage(name, list);
  }

  _onMapCreated(MapLibreMapController controller) {
    mapController = controller;

    List<LatLng> lineCoordinates = tour1.coords
        .map((c) => LatLng(c["lat"], c["lng"]))
        .toList();

    if (lineCoordinates.isNotEmpty) {
      LatLngBounds bounds = LatLngBounds(
        southwest: lineCoordinates.reduce((a, b) =>
            LatLng(a.latitude < b.latitude ? a.latitude : b.latitude, a.longitude < b.longitude ? a.longitude : b.longitude)),
        northeast: lineCoordinates.reduce((a, b) =>
            LatLng(a.latitude > b.latitude ? a.latitude : b.latitude, a.longitude > b.longitude ? a.longitude : b.longitude)),
      );
      mapController!.moveCamera(CameraUpdate.newLatLngBounds(bounds));
    }
  }



  rotateCamera(position) async {
    print(position);
    await mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition( target: LatLng(position["lat"], position["lng"]),
        zoom: 17,
        bearing: position["course"].toDouble(),
        tilt: 60)
    ));
  }

  _onStyleLoadedCallback() async {
    addImageFromAsset("star-marker", "assets/images/star.png");
    mapController?.addLine(
      LineOptions(
          draggable: false,
          lineColor: "#ff0000",
          lineWidth: 4.0,
          lineOpacity: 0.7,
          geometry: tour1.coords.map((c) => LatLng(c["lat"], c["lng"])).toList()
      ),
    );

    late List points = [];
    for (var a in tour1.starPoints) {
        points.add({
          "type": "Feature",
          "id": a["index"],
          "properties": {
            "name":  a["name"],
          },
          "geometry": {
            "type": "Point",
            "coordinates": [tour1.coords[a["index"]]["lng"], tour1.coords[a["index"]]["lat"]]
          }
        });
    }
    dynamic _points = {
      "type": "FeatureCollection",
      "features": points
    };

    await mapController!.addGeoJsonSource("points", _points);

    await mapController!.addSymbolLayer(
      "points",
      "symbols",
      const SymbolLayerProperties(
        iconImage: "star-marker", //  "{type}-15",
        iconSize: 0.8,
        iconAllowOverlap: true,
        textField: [Expressions.get, "name"],
        textSize: 13,
        textAllowOverlap: true,
        textFont: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
        textAnchor: 'top',
        textOffset: [ Expressions.literal, [0, 0.8] ],
        textColor: '#000000',
        textHaloBlur: 1,
        textHaloColor: '#ffffff',
        textHaloWidth: 0.8
      ),
    );

    circle = await mapController!.addCircle(
      CircleOptions(
          geometry: LatLng(tour1.coords[0]["lat"], tour1.coords[0]["lng"]),
          circleColor: BlackColor.toString()),
    );
    showStarPointImage(tour1.starPoints[0]["img"]);

    List<dynamic> startPointsIndex = tour1.starPoints.map((a) => a["index"]).toList();
    routeTimer = Timer.periodic(const Duration(milliseconds: 1000), (t) {
      if (!showStarPointIsActive) {
        index = index + 1;
      }

      if (index == tour1.coords.length) {
        index = 0;
      }

      if(!showStarPointIsActive) {
        _updateSelectedCircle(CircleOptions(
            geometry: LatLng(
                tour1.coords[index]["lat"], tour1.coords[index]["lng"]),
            circleColor: BlackColor.toString()));

        rotateCamera(tour1.coords[index]);
      }

      if (startPointsIndex.contains(index)) {
        dynamic starPoint = tour1.starPoints.firstWhere((a) => a["index"] == index);

        overlayEntry.remove();
        showStarPointImage(starPoint["img"]);

        if(!showStarPointIsActive) {
          showStarPointIsActive = true;
          showStarPoint = Timer(const Duration(seconds: 5), () {
            showStarPointIsActive = false;
          });
        }
      }
    });
  }

  void showStarPointImage(String img) {
    overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 0,
          child: Material(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              color: WhiteColor,
              child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(img),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: null
              ),
            ),
          ),
        )
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _updateSelectedCircle(CircleOptions changes) {
    mapController?.updateCircle(circle, changes);
  }

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(38.7100, -9.1307),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: CustomAppbar(
              centertext: "Tour Details",
              ActionIcon: null,
              bgcolor: notifire.getblackwhitecolor,
              actioniconcolor: notifire.getwhiteblackcolor,
              leadingiconcolor: notifire.getwhiteblackcolor,
              titlecolor: notifire.getwhiteblackcolor)),
      backgroundColor: notifire.getblackwhitecolor,
      body: MapLibreMap(
        styleString: 'https://api.maptiler.com/maps/satellite/style.json?key=c9mafO6rAK56K3BOW5w1',
        onMapCreated: _onMapCreated,
        initialCameraPosition: _kInitialPosition,
        onStyleLoadedCallback: _onStyleLoadedCallback,
      ));
  }

  @override
  void dispose() {
    overlayEntry.remove();
    routeTimer.cancel();
    super.dispose();
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
