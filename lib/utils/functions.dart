import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../packages/chat_core/src/util.dart';

Future pushTo(Widget page, BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
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
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
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
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'createdAt': FieldValue.serverTimestamp(),
        'firstName': user.firstName,
        'imageUrl': user.imageUrl,
        'lastName': user.lastName,
        'lastSeen': user.lastSeen,
        'metadata': user.metadata,
        'role': user.role?.toShortString(),
        'updatedAt': FieldValue.serverTimestamp(),
        'user_type': "user"
      });
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
    print(string ?? 'Null string');
  }
}

Future<types.Room?> checkIfRoomExists(String userId) async {
  log(userId);
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<types.Room> rooms = await processRoomsQuery(FirebaseAuth.instance.currentUser!, snapshot);
    if (rooms.isNotEmpty) {
      for (var room in rooms) {
        // Checking if room type is Direct
        if (room.userIds.contains(userId) &&
            (room.type != types.RoomType.channel || room.type != types.RoomType.group)) {
          consoleLog('Room Exists $room');
          return room;
        }
      }
      consoleLog("Room Doesn't Exist");
      return null;
    } else {
      consoleLog("Room Doesn't Exist");
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
