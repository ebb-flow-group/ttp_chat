import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

displaySnackBar(String message, BuildContext context) {
  var snackBar = SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: Ts.f1Semi(Colors.white),
    ),
    elevation: 0.0,
    backgroundColor: Config.mentaikoColor,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<types.User?> getUserFromFireStore(String userId,
    {bool createUser = true, String? firstName, String? imageUrl = "", String? lastName = ""}) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      types.User result = types.User.fromJson(data)..id = snapshot.id;

      return result;
    } else if (createUser) {
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
  return null;
}

consoleLog(String? string) {
  if (kDebugMode) {
    print(string ?? 'Null string');
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
