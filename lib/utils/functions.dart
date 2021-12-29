// ignore_for_file: unnecessary_new

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future pushTo(Widget page, BuildContext context) {
  return Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => page));
}

displaySnackBar(String message, BuildContext context) {
  var snackBar = SnackBar(
    content: Text(message),
    elevation: 0.0,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      textColor: const Color(0xFFFAF2FB),
      label: 'OK',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

consoleLog(String? string) {
  if (kDebugMode) {
    log(string ?? 'Null string');
  }
}

bool isLoggedInUser(String? uid) {
  if (uid == null) {
    return false;
  }
  return uid == (FirebaseAuth.instance.currentUser?.uid ?? "");
}

areItemsEqual(List data) {
  //check if all elements of list are equal
  if (data.toSet().length == 1) {
    return true;
  } else {
    return false;
  }
}
