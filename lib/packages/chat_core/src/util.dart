import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

/// Extension with one [toShortString] method
/*extension RoleToShortString on types.Role {
  /// Converts enum to the string equal to enum's name
  String toShortString() {
    return toString().split('.').last;
  }
}*/

/// Extension with one [toShortString] method
/*extension RoomTypeToShortString on types.RoomType {
  /// Converts enum to the string equal to enum's name
  String toShortString() {
    return toString().split('.').last;
  }
}*/

/// Fetches user from Firebase and returns a promise
Future<Map<String, dynamic>> fetchUser(String userId, {String? role}) async {
  if (userId.isEmpty) return {};
  final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  final Map<String, dynamic> data = doc.data() ?? {};
  data['id'] = doc.id;

  data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
  data['id'] = doc.id;
  data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
  data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;
  data['role'] = role;

  return data;
}

/// Returns a list of [types.Room] created from Firebase query.
/// If room has 2 participants, sets correct room name and image.
Future<List<types.Room>> processRoomsQuery(
  User firebaseUser,
  QuerySnapshot query,
) async {
  // print("************************* processRoomsQuery *************************");
  final futures = query.docs.map(
    (doc) => processRoomDocument(doc, firebaseUser),
  );
  //log("processRoomsQuery ${futures.length.toString()}");

  return await Future.wait(futures);
}

/// Returns a [types.Room] created from Firebase document
Future<types.Room> processRoomDocument(
  DocumentSnapshot doc,
  User firebaseUser,
) async {
  final data = doc.data() as Map<String, dynamic>;
  String type = data['type'] as String;
  if (type == "channel") {
    return processChannelRoomDocument(doc, firebaseUser);
  } else {
    return processDirectRoomDocument(doc, firebaseUser);
  }
}

types.Room defaultRoom = const types.Room(
  id: '',
  users: [],
  type: types.RoomType.direct,
  userIds: [],
);

/// Returns a [types.Room] created from Firebase document
Future<types.Room> processDirectRoomDocument(
  DocumentSnapshot doc,
  User firebaseUser,
) async {
  try {
    final data = doc.data() as Map<String, dynamic>;

    data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
    data['id'] = doc.id;
    data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

    var imageUrl = data['imageUrl'] == null ? '' : data['imageUrl'] as String;
    final userIds = data['userIds'] as List<dynamic>;
    // final userRoles = data['userRoles'] == null ? {} : data['userRoles'] as Map<String, dynamic>;
    // data['name'] = await getOtherUserName(firebaseUser, userIds);
    var users = [];
    users = await Future.wait(
      userIds.map(
        (userId) => fetchUser(userId as String),
      ),
    );
    String otherUserType = "";
    String otherUserId = "";

    final e = userIds.where((element) => element != firebaseUser.uid).toList();
    if (e.isNotEmpty && e.first.toString().isNotEmpty) {
      otherUserId = e.first.toString();
    }
    try {
      final otherUser = users.firstWhere(
        (u) => u['id'] != firebaseUser.uid,
      );

      imageUrl = otherUser['imageUrl'] ?? "";
      data['name'] = '${otherUser['firstName'] ?? ''} ${otherUser['lastName'] ?? ''}';
      otherUserType = otherUser['user_type'] ?? "";
    } catch (e) {
      log("********************************************");
      log("processRoomDocument: $e");
      log("********************************************");
      // Do nothing if other user is not found, because he should be found.
      // Consider falling back to some default values.
    }

    data['imageUrl'] = imageUrl;
    data['users'] = users;
    data['userIds'] = userIds;
    if (data['lastMessages'] != null) {
      final lastMessages = data['lastMessages'].map((lm) {
        final author = users.firstWhere(
          (u) => u['id'] == lm['authorId'],
          orElse: () => {'id': lm['authorId'] as String},
        );
        lm['author'] = author;
        lm['createdAt'] = lm['createdAt']?.millisecondsSinceEpoch;
        lm['id'] = lm['id'] ?? '';
        lm['updatedAt'] = lm['updatedAt']?.millisecondsSinceEpoch;
        return lm;
      }).toList();
      data['lastMessages'] = lastMessages;
    }

    data['metadata'] = {
      'other_user_type': otherUserType.isEmpty ? await getOtherUserType(firebaseUser, userIds) : otherUserType,
      'last_messages': await getLastMessageOfRoom(doc.id),
      'unread_message_count': await getUnreadMessageCount(doc, firebaseUser)
    };

    //For Deleted Accounts
    if (otherUserId == "deleted-brand") {
      data['name'] = "Deleted Account";
      data['metadata']['other_user_type'] = "brand";
    } else if (otherUserId == "deleted-user") {
      data['name'] = "Deleted Account";
      data['metadata']['other_user_type'] = "user";
    } else if (data['metadata']['other_user_type'] == null ||
        data['metadata']['other_user_type'] == "null" ||
        data['metadata']['other_user_type']?.isEmpty) {
      data['name'] = "Deleted Account";
      data['metadata']['other_user_type'] = "brand";
      data['userIds'] = [firebaseUser, "deleted-brand"];
    }
    return types.Room.fromJson(data);
  } catch (e) {
    log("********************************************");
    log("processDirectRoomDocument: $e");
    log("********************************************");
    return defaultRoom;
  }
}

/// Returns a  channel [types.Room] created from Firebase document
Future<types.Room> processChannelRoomDocument(
  DocumentSnapshot doc,
  User firebaseUser,
) async {
  try {
    final data = doc.data() as Map<String, dynamic>;
    data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
    data['id'] = doc.id;
    data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;
    String? imageUrl;
    final userIds = data['userIds'] as List<dynamic>;
    String otherUserType = "";
    String ownerId = data["owner"];
    Map<String, dynamic> otherUser = await fetchUser(data["owner"]);
    //log("processChannelRoomDocument: ${otherUser.toString()}");
    try {
      imageUrl = data['imageUrl'] ?? otherUser['imageUrl'] ?? "";
      otherUserType = otherUser['user_type'] ?? "";
    } catch (e) {
      log("********************************************");
      log("processRoomDocument: $e");
      log("********************************************");
      // Do nothing if other user is not found, because he should be found.
      // Consider falling back to some default values.
    }
    data['imageUrl'] = imageUrl;
    data['users'] = [];
    data['userIds'] = userIds;
    if (data['lastMessages'] != null) {
      final lastMessages = data['lastMessages'].map((lm) {
        // final author = [].firstWhere(
        //   (u) => u['id'] == lm['authorId'],
        //   orElse: () => {'id': lm['authorId'] as String},
        // );

        // lm['author'] = author;
        lm['createdAt'] = lm['createdAt']?.millisecondsSinceEpoch;
        lm['id'] = lm['id'] ?? '';
        lm['updatedAt'] = lm['updatedAt']?.millisecondsSinceEpoch;

        return lm;
      }).toList();

      data['lastMessages'] = lastMessages;
    }

    data['metadata'] = {
      'other_user_type': otherUserType.isEmpty ? await getOtherUserType(firebaseUser, userIds) : otherUserType,
      'last_messages': await getLastMessageOfRoom(doc.id),
      'unread_message_count': await getUnreadMessageCount(doc, firebaseUser)
    };

    //For Deleted Accounts
    if (ownerId == "deleted-brand") {
      data['name'] = "Deleted Account";
      data['metadata']['other_user_type'] = "brand";
    } else if (ownerId == "deleted-user") {
      data['name'] = "Deleted Account";
      data['metadata']['other_user_type'] = "user";
    }

    // log(data.toString());
    return types.Room.fromJson(data);
  } catch (e) {
    log("********************************************");
    log("processChannelRoomDocument: $e");
    log("********************************************");
    return defaultRoom;
  }
}

Future<String> getOtherUserName(User firebaseUser, List<dynamic> userIds) async {
  // print('CURRENT USER ID: ${firebaseUser.uid}');
  // print('SELECTED CHAT USER: $userIds');

  final e = userIds.where((element) => element != firebaseUser.uid).toList();
  if (e.isNotEmpty && e.first.toString().isNotEmpty) {
    //For Deleted Accounts
    if (e.first == "deleted-brand" || e.first == "deleted-user") {
      return "Deleted Account";
    }
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(e[0].toString()).get();
    final data = snapshot.data();
    return data == null ? '' : '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
  }
  return "";
}

Future<String> getOtherUserType(User firebaseUser, List<dynamic> userIds) async {
  // print('CURRENT USER ID FOR TYPE: ${firebaseUser.uid}');
  // print('SELECTED CHAT USER FOR TYPE: $userIds');

  final e = userIds.where((element) => element != firebaseUser.uid).toList();
  if (e.isNotEmpty && e.first.toString().isNotEmpty) {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(e[0].toString()).get();

    final data = snapshot.data();
    return '${data?['user_type']}';
  }
  return "";
}

Future<Map<String, dynamic>> getLastMessageOfRoom(String roomId) async {
  final collection = await FirebaseFirestore.instance
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .get();

  /*collection.docs.sort((a, b){
    var aData = a.data() as Map<String, dynamic>;
    var bData = b.data() as Map<String, dynamic>;
    Timestamp aTimestamp = aData['createdAt'] as Timestamp;
    Timestamp bTimestamp = bData['createdAt'] as Timestamp;
    return aTimestamp.compareTo(bTimestamp);
  });*/

  return collection.docs.isNotEmpty ? collection.docs[0].data() : {};
}

Future<int> getUnreadMessageCount(DocumentSnapshot<Object?> room, User firebaseUser) async {
  final roomId = room.id;
  final Map roomData = room.data() as Map<String, dynamic>;
  final String type = roomData['type'] ?? "";
  if (type == "channel") {
    return getUnreadChannelMessageCount(roomId, firebaseUser);
  } else {
    final collection = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .where('authorId', isNotEqualTo: firebaseUser.uid)
        .where('status', isEqualTo: 'sent')
        .get();
    return collection.docs.length;
  }
}

Future<int> getUnreadChannelMessageCount(String roomId, User firebaseUser) async {
  final collection = await FirebaseFirestore.instance
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .where('authorId', isNotEqualTo: firebaseUser.uid)
      .where('unreadUserIds', arrayContains: firebaseUser.uid)
      .get();
  return collection.docs.length;
}
