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

  static TextStyle _bold2(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontWeight: FontWeight.w700,
      fontSize: size.sp,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  @Deprecated('Use _bold2 instead')
  static TextStyle _bold(double size, Color color, {bool isUnderline = false, bool isLineThrough = false}) {
    return _bold2(size, color, 1, 0).copyWith(
      decoration: isUnderline
          ? TextDecoration.underline
          : isLineThrough
              ? TextDecoration.lineThrough
              : TextDecoration.none,
    );
  }

  static TextStyle _demi2(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontSize: size.sp,
      fontWeight: FontWeight.w600,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  @Deprecated('Use _demi2 instead')
  static TextStyle _demi(double size, Color color, {bool isUnderline = false}) {
    return _demi2(size, color, 1, 0).copyWith(
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static TextStyle custom(double size, Color color, {bool isUnderline = false, bool isLineThrough = false}) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontWeight: FontWeight.w700,
      fontSize: size.sp,
      color: color,
      decoration: isUnderline
          ? TextDecoration.underline
          : isLineThrough
              ? TextDecoration.lineThrough
              : TextDecoration.none,
    );
  }

  static TextStyle _text2(double size, Color color, double height, double letterSpacing) {
    return TextStyle(
      fontFamily: 'AvertaStd',
      fontWeight: FontWeight.w400,
      fontSize: size.sp,
      color: color,
      height: height / size,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _text(double size, Color color, {bool isUnderline = false}) {
    return _text2(size, color, 1, 0).copyWith(
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
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
    return _demi2(30, color, 35, -.3);
  }

  static TextStyle h1Reg(Color color) {
    return _text2(30, color, 30, -.3);
  }

  static TextStyle h2Bold(Color color) {
    return _extraBold(25, color, 30, -.2);
  }

  static TextStyle h2Semi(Color color) {
    return _demi2(25, color, 30, -.3);
  }

  static TextStyle h2Reg(Color color) {
    return _text2(25, color, 30, -.3);
  }

  static TextStyle h3Bold(Color color) {
    return _extraBold(20, color, 30, -.2);
  }

  static TextStyle h3Semi(Color color) {
    return _demi2(20, color, 30, -.3);
  }

  static TextStyle h3Reg(Color color) {
    return _text2(20, color, 30, -.3);
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
    return _demi2(18, color, 25, -.2);
  }

  static TextStyle t1Reg(Color color) {
    // TODO: implement t3Reg with (missing) font-family AvertaStd-Medium
    return _text2(18, color, 25, -.2);
  }

  static TextStyle t2Bold(Color color) {
    return _extraBold(16, color, 20, -.1);
  }

  static TextStyle t2Semi(Color color) {
    return _demi2(16, color, 20, -.2);
  }

  static TextStyle t2Reg(Color color) {
    // TODO: implement t3Reg with (missing) font-family AvertaStd-Medium
    return _text2(16, color, 20, -.2);
  }

  static TextStyle t3Bold(Color color) {
    return _extraBold(14, color, 20, -.1);
  }

  static TextStyle t3Semi(Color color) {
    return _demi2(14, color, 20, -.2);
  }

  static TextStyle t3Reg(Color color) {
    // TODO: implement t3Reg with (missing) font-family AvertaStd-Medium
    return _text2(14, color, 20, -.2);
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
    return _demi2(18, color, 30, -.2);
  }

  static TextStyle p1Reg(Color color) {
    return _text2(18, color, 30, -.2);
  }

  static TextStyle p2Bold(Color color) {
    return _extraBold(16, color, 25, -.1);
  }

  static TextStyle p2Semi(Color color) {
    return _demi2(16, color, 25, -.2);
  }

  static TextStyle p2Reg(Color color) {
    return _text2(16, color, 25, -.2);
  }

  static TextStyle p3Bold(Color color) {
    return _extraBold(14, color, 25, -.1);
  }

  static TextStyle p3Semi(Color color) {
    return _demi2(14, color, 25, -.2);
  }

  static TextStyle p3Reg(Color color) {
    return _text2(14, color, 25, -.2);
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
    return _demi2(12, color, 20, -.2);
  }

  static TextStyle f1Med(Color color) {
    return _text2(12, color, 20, -.2);
  }

  static TextStyle f2Bold(Color color) {
    return _extraBold(10, color, 10, -.1);
  }

  static TextStyle f2Semi(Color color) {
    return _demi2(10, color, 10, -.2);
  }

  static TextStyle f2Reg(Color color) {
    return _text2(10, color, 10, -.2);
  }

  static TextStyle fpCaps(Color color) {
    return _bold2(12, color, 20, -.2);
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

  // ***************
  // * Old Implementation of Text Styles
  // * ---------------
  // *
  // ***************

  @Deprecated('Use new text styles')
  static TextStyle text12(Color color, {bool isUnderline = false}) {
    return _text(12, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle text14(Color color, {bool isUnderline = false}) {
    return _text(14, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle text16(Color color, {bool isUnderline = false}) {
    return _text(16, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle text18(Color color, {bool isUnderline = false}) {
    return _text(18, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle demi14(Color color, {bool isUnderline = false}) {
    return _demi(14, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle bold12(Color color, {bool isUnderline = false}) {
    return _bold(12, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle bold14(Color color, {bool isUnderline = false}) {
    return _bold(14, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle bold16(Color color, {bool isUnderline = false}) {
    return _bold(16, color, isUnderline: isUnderline);
  }

  @Deprecated('Use new text styles')
  static TextStyle bold17(Color color, {bool isUnderline = false}) {
    return _bold(17, color, isUnderline: isUnderline);
  }

  @Deprecated('message')
  static TextStyle bold20(Color color) {
    return _bold(20, color);
  }
}
