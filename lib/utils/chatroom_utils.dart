import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../packages/chat_core/src/util.dart';
import 'functions.dart';

class ChatRoomUtils {
  static Future<types.Room?> checkIfRoomExists(String userId, {bool isChannel = false}) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get();
      List<types.Room> rooms = await processRoomsQuery(FirebaseAuth.instance.currentUser!, snapshot);
      if (rooms.isNotEmpty) {
        for (var room in rooms) {
          if (room.userIds.contains(userId)) {
            // Checking if room type is Direct or channel
            if (isChannel) {
              if (room.type == types.RoomType.channel) {
                return room;
              }
            } else if ((room.type != types.RoomType.channel && room.type != types.RoomType.group)) {
              consoleLog('Room Exists $room');
              return room;
            }
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

  static Future<types.Room?> getRoomFromId(String roomId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
      return await processRoomDocument(snapshot, FirebaseAuth.instance.currentUser!);
    } catch (e) {
      consoleLog(e.toString());
      return null;
    }
  }
}
