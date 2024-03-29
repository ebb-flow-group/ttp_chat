import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Layout Service
class L {
  static const designWidth = 375;
  static Orientation? orientation;

  // Should be overriden in Root
  static double screenMinSize = 375;
  static double ratio = 1;

  static double appBarHeight = v(56);

  static double appBar2Height = v(56);

  static String lang = 'en';

  static Map<String, Map<String, String>> translationMap = {};

  static void setScreenMinSize(double value) {
    screenMinSize = value;

    if (value < 500) {
      ratio = screenMinSize / designWidth;
    } else if (value < 1000) {
      ratio = 1.4;
    } else {
      ratio = 1.7;
    }
  }

  static void setOrientation(Orientation value) {
    orientation = value;
  }

  // For height
  static double h(double value) {
    return value.h;
  }

  // For width
  static double w(double value) {
    return value.w;
  }

  // For radius
  static double r(double value) {
    return value.r;
  }

  static double v(double value) {
    return value;
    // return value * ratio;
  }

  // Translations
  static String t(String text) {
    return text;

    // if (translationMap.containsKey(text)) {
    //   if (translationMap[text]!.containsKey(lang)) {
    //     var value = translationMap[text]![lang];
    //     if (value!.isNotEmpty) {
    //       return value;
    //     }
    //   }
    // }

    // return text;
  }
}
