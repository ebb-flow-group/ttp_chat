import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/utils/chatroom_utils.dart';

import '../../config.dart';
import '../../packages/chat_core/src/firebase_chat_core.dart';
import '../../utils/functions.dart';
import 'chat_page/chat_page.dart';
import 'chat_utils.dart';
import 'loading_screen.dart';

class DirectChat extends StatefulWidget {
  final String? otherUserId;
  final String? roomId;

  /// Whether the Direct chat is with Channel Or User
  @Deprecated('replacing this with roomId')
  final bool isChannel;
  final String? accessToken, refreshToken;

  /// If The user doen't exist in firebase, this name and image will be added when the user is created
  @Deprecated('Not using these fields, better to remove from Navigation')
  final String firstName, lastName, profileImage;
  @Deprecated('Use otherUserId instead')
  final String username, phoneNumber;
  @Deprecated('Using Go Router for navigation Now, this can be removed')
  final Function(int?, String?, String?)? onViewOrderDetailsClick;
  const DirectChat(
      {required this.accessToken,
      required this.refreshToken,
      this.otherUserId,
      this.phoneNumber = "",
      this.username = "",
      this.firstName = "",
      this.lastName = "",
      this.roomId,
      this.profileImage = "",
      this.isChannel = false,
      this.onViewOrderDetailsClick,
      Key? key})
      :
        //TODO: Add After Deprecated fields username, phoneNumber are removed
        // assert(otherUserId != null || roomId != null, "Either otherUserId or roomId must be provided"),
        super(key: key);

  @override
  _DirectChatState createState() => _DirectChatState();
}

class _DirectChatState extends State<DirectChat> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      init();
    });
  }

  types.Room? room;

  bool isLoading = true;

  StreamSubscription<User?>? userStream;

  String get otherUserId {
    return widget.otherUserId ?? (widget.username.isEmpty ? widget.phoneNumber : widget.username);
  }

  init() async {
    if (widget.accessToken == null ||
        widget.accessToken!.isEmpty ||
        widget.refreshToken == null ||
        widget.refreshToken!.isEmpty) {
      displaySnackBar("Error, Please Login to Chat", context);
      Navigator.pop(context);
      return;
    }
    if (otherUserId.isEmpty && widget.roomId == null) {
      consoleLog("other UserId is null ");
      _showChatRoomError();
      return;
    }
    ChatUtils.initFirebaseApp(
        accessToken: widget.accessToken!,
        refreshToken: widget.refreshToken!,
        onInit: () {
          log('Firebase app initialized');
          if (FirebaseAuth.instance.currentUser == null) return;
          findChat();
        });
  }

  findChat() async {
    types.Room? chatRoom;
    if (widget.roomId != null) {
      consoleLog("Getting Room from RoomId");
      chatRoom = await ChatRoomUtils.getRoomFromId(widget.roomId!);
    } else {
      consoleLog("Getting Room from UserId");
      chatRoom = await ChatRoomUtils.checkIfRoomExists(otherUserId);
    }
    if (chatRoom != null) {
      consoleLog("Room Exists");
      room = chatRoom;
      setState(() {});
    } else {
      //TODO: remove fields firstname , lastname and show error intead of creating new user
      types.User? user = await getUserFromFireStore(otherUserId,
          firstName: widget.firstName, lastName: widget.lastName, imageUrl: widget.profileImage);
      if (user != null) {
        consoleLog("Creating New Room for $otherUserId");
        room = await FirebaseChatCore.instance.createRoom(user);
        consoleLog('Room Name: ${room!.name}\nId: ${room!.id}\nUsers: ${room!.userIds}');
        setState(() {});
      } else {
        _showChatRoomError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return room == null
        ? const Scaffold(
            backgroundColor: Config.creameryColor,
            body: LoadingScreen(),
          )
        : ChatPage(room!);
  }

  _showChatRoomError() {
    displaySnackBar(
        "This store isn’t enabled for chat. You could give them a call, or reach out to Tabletop Support for assistance.",
        context);
    Navigator.pop(context);
  }
}
