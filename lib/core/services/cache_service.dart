import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/utils/functions.dart';

import '../../features/chat/presentation/chat_provider.dart';

class CacheService {
  saveRoomList(List<types.Room> roomList, ChatProvider provider) {
    SharedPreferences.getInstance().then((prefs) {
      try {
        List rooms = roomList.map((room) {
          try {
            var createdAt = room.metadata?['last_messages']['createdAt'];
            DateTime? d = createdAt is Timestamp ? createdAt.toDate() : DateTime.tryParse(createdAt?.toString() ?? "");
            var formattedDate = d != null ? DateFormat('hh:mm a').format(d) : createdAt;
            room.metadata?['last_messages']["createdAt"] = formattedDate;
            room.metadata?['last_messages']["updatedAt"] = formattedDate;
            try {
              json.encode(room.toJson());
            } catch (e) {
              room.metadata?['last_messages']["metadata"] = {};
              try {
                json.encode(room.toJson());
              } catch (e) {
                room.metadata?['last_messages'] = {};
              }
            }
            return room.toJson();
          } catch (e) {
            log(room.toJson().toString());
            consoleLog("Error while encoding room: $e");
            consoleLog(e.toString());
          }
        }).toList();
        prefs.setString("roomList", json.encode(rooms));
      } catch (e) {
        consoleLog("Error in saving room list: $e");
        consoleLog(e.toString());
      }
    });
  }

  clearRoomList() {
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.remove("roomList");
    });
  }
}
