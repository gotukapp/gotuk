import 'package:dm/Utils/Colors.dart';
import 'package:flutter/material.dart';

class ColorNotifier with ChangeNotifier {
  bool isDark = false;
  set setIsDark(value) {
    isDark = value;
    notifyListeners();
  }

  get getIsDark => isDark;
  get getwhitegrey => isDark ? greyColor : bgcolor;
  get getbgcolor => isDark ? darkmode : bgcolor; //background color
  get getlogobgcolor => isDark ? LogoColor : LogoColor; //background color
  get getdarkmodecolor => isDark ? boxcolor : WhiteColor; //containar color
  get getlightblackcolor => isDark ? boxcolor : lightBlack;
  get getdarklightgreycolor => isDark ? darkGrey : lightGrey;
  get getlightdarkgreycolor => isDark ? lightGrey : darkGrey;

  get getwhiteblackcolor => isDark ? WhiteColor : BlackColor; //text defultsystemicon imageicon color

  get getwhitelogocolor => isDark ? WhiteColor : LogoColor;

  get getdarkgreycolor => isDark ? darkGrey : darkGrey;
  get getgreycolor => isDark ? greyColor : greyColor;
  get getwhitebluecolor => isDark ? WhiteColor : Darkblue;
  get getlogowhitecolor => isDark ? LogoColor : WhiteColor;
  get getblackgreycolor => isDark ? lightBlack2 : greyColor;

  get gettextfieldcolor => isDark ? fieldColor : textFieldColor;
  get getfieldcolor => isDark ? textFieldColor : fieldColor;

  get getcardcolor => isDark ? darkmode : WhiteColor;
  get getgreywhite => isDark ? WhiteColor : greyColor;
  get getredcolor => isDark ? RedColor : RedColor2;
  get getprocolor => isDark ? yelloColor : yelloColor2;
  get getblackwhitecolor => isDark ? BlackColor : WhiteColor;
  get getlightblack => isDark ? lightBlack2 : lightBlack2;
  get getbuttoncolor => isDark ? greyColor : onoffColor;
  get getdarkbluecolor => isDark ? Darkblue : Darkblue;
  get getdarkscolor => isDark ? BlackColor : bgcolor;
  get getdarkwhitecolor => isDark ? WhiteColor : WhiteColor;
}
