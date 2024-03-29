import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/utils/functions.dart';

import '../../../utils/functions.dart';
import 'util.dart';

/// Provides access to Firebase chat data. Singleton, use
/// FirebaseChatCore.instance to aceess methods.
class FirebaseChatCore {
  FirebaseChatCore._privateConstructor() {
    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user != null) firebaseUser = user;
    });
  }

  /// Current logged in user in Firebase. Does not update automatically.
  /// Use [FirebaseAuth.authStateChanges] to listen to the state changes.
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  /// Singleton instance
  static final FirebaseChatCore instance = FirebaseChatCore._privateConstructor();

  // ignore: sort_constructors_first
  FirebaseChatCore.instanceFor({@required FirebaseApp? app}) {
    // ignore: prefer_asserts_in_initializer_lists
    assert(app != null);

    firebaseUser = FirebaseAuth.instanceFor(app: app!).currentUser!;
  }

  /// Creates a chat group room with [users]. Creator is automatically
  /// added to the group. [name] is required and will be used as
  /// a group name. Add an optional [imageUrl] that will be a group avatar
  /// and [metadata] for any additional custom data.
  Future<types.Room> createGroupRoom({
    String? imageUrl,
    Map<String, dynamic>? metadata,
    @required String? name,
    @required List<types.User>? users,
  }) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final currentUser = await fetchUser(firebaseUser!.uid);
    final roomUsers = [types.User.fromJson(currentUser)] + users!;

    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'metadata': metadata,
      'name': name,
      'type': types.RoomType.group.toSShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userIds': roomUsers.map((u) => u.id).toList(),
      'userRoles': roomUsers.fold<Map<String, String>>(
        {},
        (previousValue, user) => {
          ...previousValue,
          user.id: user.role!.toShortString(),
        },
      ),
    });

    return types.Room(
        id: room.id,
        imageUrl: imageUrl,
        metadata: metadata,
        name: name,
        type: types.RoomType.group,
        users: roomUsers,
        userIds: const []);
  }

  /// Creates a direct chat for 2 people. Add [metadata] for any additional
  /// custom data.
  Future<types.Room> createRoom(
    types.User otherUser, {
    Map<String, dynamic>? metadata,
  }) async {
    if (firebaseUser == null) return Future.error('User does not exist');

    final query =
        await FirebaseFirestore.instance.collection('rooms').where('userIds', arrayContains: firebaseUser!.uid).get();

    final rooms = await processRoomsQuery(firebaseUser!, query);

    try {
      log("checking if room exists");
      return rooms.firstWhere((room) {
        // Returning False if the room is not a direct chat
        if (room.type == types.RoomType.group) return false;
        if (room.type == types.RoomType.channel) return false;

        final userIds = room.userIds;

        return userIds.contains(firebaseUser!.uid) && userIds.contains(otherUser.id);
      });
    } catch (e) {
      // Do nothing if room does not exist
      // Create a new room instead
    }

    consoleLog("Creating new room");

    final currentUser = await fetchUser(firebaseUser!.uid);
    final users = [types.User.fromJson(currentUser), otherUser];

    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': otherUser.imageUrl,
      'metadata': metadata,
      'name': '${otherUser.firstName ?? ""} ${otherUser.lastName ?? ""}',
      'type': types.RoomType.direct.toSShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userIds': users.map((u) => u.id).toList(),
      'userRoles': null,
    });

    return types.Room(
        id: room.id,
        metadata: metadata,
        type: types.RoomType.direct,
        users: users,
        name: '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}',
        imageUrl: otherUser.imageUrl,
        userIds: users.map((u) => u.id).toList());
  }

  /// Creates [types.User] in Firebase to store name and avatar used on
  /// rooms list
  Future<void> createUserInFirestore(types.User user, {bool isBrand = false}) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set({
      'createdAt': FieldValue.serverTimestamp(),
      'firstName': user.firstName,
      'imageUrl': user.imageUrl,
      'lastName': user.lastName,
      'lastSeen': user.lastSeen,
      'metadata': user.metadata,
      'role': user.role?.toShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'user_type': isBrand ? 'brand' : 'user',
    });
  }

  /// Removes [types.User] from `users` collection in Firebase
  Future<void> deleteUserFromFirestore(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  /// Returns a stream of messages from Firebase for a given room
  Stream<List<types.Message>> messages(types.Room room) {
    return FirebaseFirestore.instance
        .collection('rooms/${room.id}/messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.fold<List<types.Message>>(
          [],
          (previousValue, doc) {
            final data = doc.data();
            final author = room.users.firstWhere(
              (u) => u.id == data['authorId'],
              orElse: () => types.User(id: data['authorId'] as String),
            );

            data['author'] = author.toJson();
            data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
            data['id'] = doc.id;
            data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

            return [...previousValue, types.Message.fromJson(data)];
          },
        );
      },
    );
  }

  /// Returns a stream of changes in a room from Firebase
  Stream<types.Room> room(String roomId) {
    if (firebaseUser == null) return const Stream.empty();
    log('room: $roomId');
    return FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .asyncMap((doc) => processRoomDocument(doc, firebaseUser!));
  }

  /// Returns a stream of rooms from Firebase. Only rooms where current
  /// logged in user exist are returned. [orderByUpdatedAt] is used in case
  /// you want to have last modified rooms on top, there are a couple
  /// of things you will need to do though:
  /// 1) Make sure `updatedAt` exists on all rooms
  /// 2) Write a Cloud Function which will update `updatedAt` of the room
  /// when the room changes or new messages come in
  /// 3) Create an Index (Firestore Database -> Indexes tab) where collection ID
  /// is `rooms`, field indexed are `userIds` (type Arrays) and `updatedAt`
  /// (type Descending), query scope is `Collection`
  Stream<List<types.Room>> rooms({bool orderByUpdatedAt = false}) {
    // print("********************");
    // print("Fetching Rooms");
    // print("********************");
    if (firebaseUser == null) return const Stream.empty();

    final collection = orderByUpdatedAt
        ? FirebaseFirestore.instance
            .collection('rooms')
            .where('userIds', arrayContains: firebaseUser!.uid)
            .orderBy('updatedAt', descending: true)
        : FirebaseFirestore.instance.collection('rooms').where('userIds', arrayContains: firebaseUser?.uid);

    return collection.snapshots().asyncMap((query) => processRoomsQuery(firebaseUser!, query));
  }

  /// Sends a message to the Firestore. Accepts any partial message and a
  /// room ID. If arbitraty data is provided in the [partialMessage]
  /// does nothing.
  void sendMessage(dynamic partialMessage, types.Room? room) async {
    if (firebaseUser == null || room == null) return;
    String roomId = room.id;

    types.Message message;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialCustom: partialMessage,
        status: types.Status.sent,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialFile: partialMessage,
        status: types.Status.sent,
      );
    } else if (partialMessage is types.PartialVoice) {
      message = types.VoiceMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialVoice: partialMessage,
        status: types.Status.sent,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialImage: partialMessage,
        status: types.Status.sent,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialText: partialMessage,
        status: types.Status.sent,
      );
    } else {
      message = types.TextMessage.fromPartial(
        author: types.User(id: ''),
        id: '',
        partialText: const types.PartialText(text: ''),
        status: types.Status.sent,
      );
    }

    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
    messageMap['authorId'] = firebaseUser?.uid;
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    messageMap['updatedAt'] = FieldValue.serverTimestamp();

    final roomMap = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // For checking unread messages in a channel
    if (room.type == types.RoomType.channel) {
      room.userIds.removeWhere((element) => element == firebaseUser?.uid);
      messageMap['unreadUserIds'] = room.userIds;
      roomMap['unreadUserIds'] = room.userIds;
    }
    await FirebaseFirestore.instance.collection('rooms/$roomId/messages').add(messageMap);

    if (room.type == types.RoomType.direct) {
      roomMap['unreadUserId'] = (List.of(room.userIds)..remove(firebaseUser?.uid)).first;
    }
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update(roomMap);
  }

  /// Updates a message in the Firestore. Accepts any message and a
  /// room ID. Message will probably be taken from the [messages] stream.
  void updateMessage(types.Message message, String roomId) async {
    if (firebaseUser == null) return;
    if (message.author.id != firebaseUser!.uid) return;

    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'id' || key == 'createdAt');
    messageMap['updatedAt'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance.collection('rooms/$roomId/messages').doc(message.id).update(messageMap);
  }

  /// Returns a stream of all users from Firebase
  Stream<List<types.User>> users() {
    if (firebaseUser == null) return const Stream.empty();
    return FirebaseFirestore.instance.collection('users').snapshots().map(
          (snapshot) => snapshot.docs.fold<List<types.User>>(
            [],
            (previousValue, doc) {
              if (firebaseUser!.uid == doc.id) return previousValue;

              final data = doc.data();

              data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
              data['id'] = doc.id;
              data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
              data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

              return [...previousValue, types.User.fromJson(data)];
            },
          ),
        );
  }
}
