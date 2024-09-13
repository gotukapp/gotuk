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
  int index = 0;
  late OverlayEntry overlayEntry;
  List<Symbol> starPointsSymbol = [];

  Future<void> addImageFromAsset(String name, String assetName) async {
    final bytes = await rootBundle.load(assetName);
    final list = bytes.buffer.asUint8List();
    return mapController!.addImage(name, list);
  }

  _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
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

    for (var a in tour1.starPoints) {
        Symbol symbol = await mapController!.addSymbol(
          SymbolOptions(
          geometry: LatLng(tour1.coords[a["index"]]["lat"], tour1.coords[a["index"]]["lng"]),
          iconImage: 'star-marker',
          iconSize: 1,
          fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
          textField: a["name"],
          textSize: 14,
          textOffset: const Offset(0, 0.8),
          textAnchor: 'top',
          textColor: '#000000',
          textHaloBlur: 1,
          textHaloColor: '#ffffff',
          textHaloWidth: 0.8,
        ), {'point': a});
        starPointsSymbol.add(symbol);
    }

    circle = await mapController!.addCircle(
      CircleOptions(
          geometry: LatLng(tour1.coords[0]["lat"], tour1.coords[0]["lng"]),
          circleColor: BlackColor.toString()),
    );
    showStarPointImage(tour1.starPoints[0]["img"]);

    List<dynamic> startPointsIndex = tour1.starPoints.map((a) => a["index"]).toList();
    routeTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      index = index + 1;
      if (index > 57) {
        index = 0;
      }

      if (startPointsIndex.contains(index)) {
        dynamic starPoint = tour1.starPoints.firstWhere((a) => a["index"] == index);
        int symbolIndex = tour1.starPoints.indexOf(starPoint);

        for (var options in starPointsSymbol) {
            SymbolOptions opt = const SymbolOptions(iconSize: 1);
            mapController?.updateSymbol(options, opt);
        };

        SymbolOptions newOptions = const SymbolOptions(iconSize: 1.5);
        mapController?.updateSymbol(starPointsSymbol[symbolIndex], newOptions);

        overlayEntry.remove();
        showStarPointImage(starPoint["img"]);
      }

      _updateSelectedCircle(CircleOptions(
          geometry: LatLng(tour1.coords[index]["lat"], tour1.coords[index]["lng"]),
          circleColor: BlackColor.toString()));
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
    zoom: 14.2,
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
        styleString: 'https://api.maptiler.com/maps/basic-v2/style.json?key=c9mafO6rAK56K3BOW5w1',
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
