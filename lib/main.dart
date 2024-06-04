// ignore_for_file: use_key_in_widget_constructors

import 'package:dm/IntroScreen/onbording.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Utils/dark_lightmode.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifire()),
      ],
      child: BoardingScreen(),
    ),
  );
}

class BoardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onbording(),
    );
  }
}
