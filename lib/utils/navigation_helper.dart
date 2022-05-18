import 'package:flutter/material.dart';

class Push {
  static Future<T?> to<T extends Object?>(Widget page, BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<T?> toNamed<T extends Object?>(String routeName, BuildContext context, {Object? arguments}) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> off<T extends Object?, TO extends Object?>(Widget page, BuildContext context, {TO? result}) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
      result: result,
    );
  }

  static Future<T?> offNamed<T extends Object?, TO extends Object?>(String routeName, BuildContext context,
      {Object? arguments}) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> offAll<T extends Object?>(Widget page, BuildContext context,
      {bool Function(Route<dynamic>)? predicate}) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      predicate ?? (route) => false,
    );
  }

  static Future<T?> offAllNamed<T extends Object?>(String routeName, BuildContext context,
      {bool Function(Route<dynamic>)? predicate, Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }
}
