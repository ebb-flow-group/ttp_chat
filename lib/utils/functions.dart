import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

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

Future<types.User?> getUserFromFireStore(String userId,
    {String? firstName, String? imageUrl = "", String? lastName = ""}) async {
  try {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      types.User result = types.User(
        id: snapshot.id,
        firstName: data['firstName'],
        lastName: data['lastName'],
        imageUrl: data['imageUrl'],
      );
      return result;
    } else {
      var user = types.User(
        firstName: firstName ?? "Guest",
        id: userId,
        imageUrl: imageUrl ?? "",
        lastName: lastName ?? "",
      );
      consoleLog("Creating New User $firstName $lastName $userId");

      await FirebaseChatCore.instance.createUserInFirestore(user);
      return user;
    }
  } catch (e) {
    // If any error
    consoleLog('GET USER ERROR $e');
    return null;
  }
}

consoleLog(String? string) {
  if (kDebugMode) {
    log(string ?? 'Null string');
  }
}

Future<types.Room?> checkIfRoomExists(String userId) async {
  log(userId);
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (var roomDoc in snapshot.docs) {
        var room = roomDoc.data() as Map<String, dynamic>;
        var userIds = (room['userIds'] ?? []) as List<dynamic>;
        if (userIds.contains(userId)) {
          consoleLog('Room Exists $room');
          return types.Room(
            id: roomDoc.id,
            type: types.RoomType.direct,
            name: room['name'],
            imageUrl: room['imageUrl'],
            userIds: room['userIds'] ?? [],
            users: const [],
          );
        }
      }
      log("Room Doesn't Exist");
      return null;
    } else {
      log("Room Doesn't Exist");
      return null;
    }
  } catch (e) {
    consoleLog(e.toString());
    return null;
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
