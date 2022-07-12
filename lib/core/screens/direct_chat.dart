import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  final String? accessToken, refreshToken;
  const DirectChat({required this.accessToken, required this.refreshToken, this.otherUserId, this.roomId, Key? key})
      : assert(otherUserId != null || roomId != null, "Either otherUserId or roomId must be provided"),
        super(key: key);

  @override
  _DirectChatState createState() => _DirectChatState();
}

class _DirectChatState extends State<DirectChat> {
  final _chatUtils = GetIt.I<ChatUtils>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  types.Room? room;

  String? get otherUserId => widget.otherUserId;

  init() async {
    if (widget.accessToken == null ||
        widget.accessToken!.isEmpty ||
        widget.refreshToken == null ||
        widget.refreshToken!.isEmpty) {
      displaySnackBar("Error, Please Login to Chat", context);
      Navigator.pop(context);
      return;
    }
    if ((otherUserId == null || otherUserId?.isEmpty == true) && widget.roomId == null) {
      consoleLog("other UserId is null ");
      _showChatRoomError();
      return;
    }
    ChatUtils.initFirebaseApp(
        accessToken: widget.accessToken!,
        refreshToken: widget.refreshToken!,
        onInit: () {
          log('Firebase app initialized');
          if (_chatUtils.firebaseAuth.currentUser == null) return;
          findChat();
        });
  }

  findChat() async {
    types.Room? chatRoom;
    if (widget.roomId != null) {
      consoleLog("Getting Room from RoomId");
      chatRoom = await ChatRoomUtils.getRoomFromId(widget.roomId!);
    } else if (otherUserId != null) {
      consoleLog("Getting Room from UserId");
      chatRoom = await ChatRoomUtils.checkIfRoomExists(otherUserId!);
    }
    if (chatRoom != null) {
      consoleLog("Room Exists");
      room = chatRoom;
      setState(() {});
    } else if (otherUserId != null) {
      types.User? user = await getUserFromFireStore(otherUserId!, createUser: false);
      if (user != null) {
        consoleLog("Creating New Room for $otherUserId");

        room = await FirebaseChatCore.instance.createRoom(user);
        consoleLog('Room Name: ${room!.name}\nId: ${room!.id}\nUsers: ${room!.userIds}');
        setState(() {});
      } else {
        _showChatRoomError();
      }
    } else {
      _showChatRoomError();
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
        "This user isn’t enabled for chat. You could reach out to Tabletop Support for assistance.", context);
    Navigator.pop(context);
  }
}
