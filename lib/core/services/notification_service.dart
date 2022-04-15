import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ttp_chat/utils/functions.dart';

class NotificationService {
  static subscribeToChannel(Map<String, dynamic> room) {
    ///Not Subcribing the owner of the room
    if (room['owner'] == FirebaseAuth.instance.currentUser?.uid) return;
    String? topic = room['topicName'];
    if (topic != null) {
      ///  consoleLog('Subscribing to topic: $topic');
      FirebaseMessaging.instance.subscribeToTopic(topic);
    }
  }

  static subscribeToAllChannels() {
    FirebaseFirestore.instance
        .collection('rooms')
        .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .where("type", isEqualTo: "channel")
        .get()
        .then((value) {
      for (var doc in value.docs) {
        Map<String, dynamic> room = doc.data();
        //Not Subcribing the owner of the room
        if (room['owner'] == FirebaseAuth.instance.currentUser?.uid) return;
        String? topic = room['topicName'];
        if (topic != null) {
          log('Subscribing to topic: $topic');
          FirebaseMessaging.instance.subscribeToTopic(topic);
        }
      }
    }).catchError((e) {
      consoleLog(e.toString());
    });
  }
}
