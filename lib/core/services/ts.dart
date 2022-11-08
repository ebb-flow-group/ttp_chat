import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Ts {
  static TextStyle _extraBold(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontWeight: FontWeight.w800,
      fontSize: size.sp,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _bold(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontWeight: FontWeight.w700,
      fontSize: size.sp,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _demi(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontSize: size.sp,
      fontWeight: FontWeight.w600,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _med(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontSize: size.sp,
      fontWeight: FontWeight.w500,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _text(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontWeight: FontWeight.w400,
      fontSize: size.sp,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle custom({
    required double size,
    required Color color,
    required FontWeight fontWeight,
    required double height,
    required double letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontWeight: fontWeight,
      fontSize: size.sp,
      height: height / size,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ***************
  // * Headers
  // * ---------------
  // * These are the large type used for headers.
  // ***************

  static TextStyle h1Bold(Color color) {
    return _extraBold(30, color, 35, -.2);
  }

  static TextStyle h1Semi(Color color) {
    return _demi(30, color, 35, -.3);
  }

  static TextStyle h1Reg(Color color) {
    return _text(30, color, 30, -.3);
  }

  static TextStyle h2Bold(Color color) {
    return _extraBold(25, color, 30, -.2);
  }

  static TextStyle h2Semi(Color color) {
    return _demi(25, color, 30, -.3);
  }

  static TextStyle h2Reg(Color color) {
    return _text(25, color, 30, -.3);
  }

  static TextStyle h3Bold(Color color) {
    return _extraBold(20, color, 30, -.2);
  }

  static TextStyle h3Semi(Color color) {
    return _demi(20, color, 30, -.3);
  }

  static TextStyle h3Reg(Color color) {
    return _text(20, color, 30, -.3);
  }

  // ***************
  // * Texts & Titles
  // * ---------------
  // * These are the main font configurations that are used for text in cards, subtitles, names, descriptions and
  // * prices.
  // ***************

  static TextStyle t1Bold(Color color) {
    return _extraBold(18, color, 25, -.1);
  }

  static TextStyle t1Semi(Color color) {
    return _demi(18, color, 25, -.2);
  }

  static TextStyle t1Reg(Color color) {
    return _med(18, color, 25, -.2);
  }

  static TextStyle t2Bold(Color color) {
    return _extraBold(16, color, 20, -.1);
  }

  static TextStyle t2Semi(Color color) {
    return _demi(16, color, 20, -.2);
  }

  static TextStyle t2Reg(Color color) {
    return _med(16, color, 20, -.2);
  }

  static TextStyle t3Bold(Color color) {
    return _extraBold(14, color, 20, -.1);
  }

  static TextStyle t3Semi(Color color) {
    return _demi(14, color, 20, -.2);
  }

  static TextStyle t3Reg(Color color) {
    return _med(14, color, 20, -.2);
  }

  // ***************
  // * Paragraphs
  // * ---------------
  // * Paragraph sizes mirror those of Texts & Titles, but with one difference - line heights are taller to accommodate
  // * better spacing for long bodies of text.
  // ***************

  static TextStyle p1Bold(Color color) {
    return _extraBold(18, color, 30, -.1);
  }

  static TextStyle p1Semi(Color color) {
    return _demi(18, color, 30, -.2);
  }

  static TextStyle p1Reg(Color color) {
    return _text(18, color, 30, -.2);
  }

  static TextStyle p2Bold(Color color) {
    return _extraBold(16, color, 25, -.1);
  }

  static TextStyle p2Semi(Color color) {
    return _demi(16, color, 25, -.2);
  }

  static TextStyle p2Reg(Color color) {
    return _text(16, color, 25, -.2);
  }

  static TextStyle p3Bold(Color color) {
    return _extraBold(14, color, 25, -.1);
  }

  static TextStyle p3Semi(Color color) {
    return _demi(14, color, 25, -.2);
  }

  static TextStyle p3Reg(Color color) {
    return _text(14, color, 25, -.2);
  }

  // ***************
  // * Fine Print
  // * ---------------
  // *
  // ***************

  static TextStyle f1Bold(Color color) {
    return _extraBold(12, color, 20, -.1);
  }

  static TextStyle f1Semi(Color color) {
    return _demi(12, color, 20, -.2);
  }

  static TextStyle f1Med(Color color) {
    return _text(12, color, 20, -.2);
  }

  static TextStyle f2Bold(Color color) {
    return _extraBold(10, color, 10, -.1);
  }

  static TextStyle f2Semi(Color color) {
    return _demi(10, color, 10, -.2);
  }

  static TextStyle f2Reg(Color color) {
    return _text(10, color, 10, -.2);
  }

  static TextStyle fpCaps(Color color) {
    return _bold(12, color, 20, -.2);
  }

  // ***************
  // * Buttons
  // * ---------------
  // *
  // ***************

  static TextStyle b1Bold(Color color) {
    return _extraBold(16, color, 20, -.2);
  }

  static TextStyle b2Bold(Color color) {
    return _extraBold(14, color, 20, -.2);
  }

  static TextStyle b2Reg(Color color) {
    return _extraBold(14, color, 20, -.2);
  }

  static TextStyle b3Bold(Color color) {
    return _extraBold(12, color, 20, -.2);
  }

  static TextStyle b4Bold(Color color) {
    return _extraBold(11, color, 20, -.2);
  }
}
