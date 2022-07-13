import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ttp_chat/utils/functions.dart';

import '../screens/chat_utils.dart';

class ChatNotificationService {
  static subscribeToChannel(Map<String, dynamic> room) {
    //TODO handle Subcribing to topic on Web
    if (kIsWeb) return;

    ///Not Subcribing the owner of the room
    if (room['owner'] == chatUtils.firebaseAuth.currentUser?.uid) return;
    String? topic = room['topicName'];
    if (topic != null) {
      ///  consoleLog('Subscribing to topic: $topic');
      FirebaseMessaging.instance.subscribeToTopic(topic);
    }
  }

  static subscribeToAllChannels() {
    //TODO handle Subcribing to topic on Web
    if (kIsWeb) return;

    chatUtils.firebaseFirestore
        .collection('rooms')
        .where('userIds', arrayContains: chatUtils.firebaseAuth.currentUser!.uid)
        .where("type", isEqualTo: "channel")
        .get()
        .then((value) {
      for (var doc in value.docs) {
        Map<String, dynamic> room = doc.data();
        //Not Subcribing the owner of the room
        if (room['owner'] == chatUtils.firebaseAuth.currentUser?.uid) return;
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

  static Future unSubscribeFromAllChannels() async {
    //TODO handle Subcribing to topic on Web
    if (kIsWeb) return;

    if (chatUtils.firebaseAuth.currentUser == null) return;
    QuerySnapshot<Map<String, dynamic>> data = await chatUtils.firebaseFirestore
        .collection('rooms')
        .where('userIds', arrayContains: chatUtils.firebaseAuth.currentUser!.uid)
        .where("type", isEqualTo: "channel")
        .get();
    for (var doc in data.docs) {
      Map<String, dynamic> room = doc.data();
      String? topic = room['topicName'];
      if (topic != null) {
        log('UnSubscribing From topic: $topic');
        FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
    }
  }
}
