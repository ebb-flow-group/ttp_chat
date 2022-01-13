import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../config.dart';
import '../../features/chat/presentation/chat_provider.dart';
import '../../packages/chat_core/src/firebase_chat_core.dart';
import '../../utils/functions.dart';
import 'chat_page.dart';
import 'loading_screen.dart';

class DirectChat extends StatefulWidget {
  final bool isBrandUser;
  final String? accessToken, refreshToken;
  final String phoneNumber, username, firstName, lastName, profileImage;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;
  const DirectChat(
      {required this.accessToken,
      required this.refreshToken,
      this.phoneNumber = "",
      this.username = "",
      this.firstName = "",
      this.lastName = "",
      this.profileImage = "",
      this.onViewOrderDetailsClick,
      this.isBrandUser = false,
      Key? key})
      : super(key: key);

  @override
  _DirectChatState createState() => _DirectChatState();
}

class _DirectChatState extends State<DirectChat> {
  @override
  void initState() {
    super.initState();
    init();
  }

  types.Room? room;

  bool isLoading = true;

  StreamSubscription<User?>? userStream;

  init() async {
    await Firebase.initializeApp();
    String? otherUserId = widget.isBrandUser ? widget.phoneNumber : widget.username;
    if (otherUserId == '') {
      consoleLog("other UserId is null");
      displaySnackBar("Error, User Not Found", context);
      Navigator.pop(context);
      return;
    }
    if (widget.accessToken == null ||
        widget.accessToken!.isEmpty ||
        widget.refreshToken == null ||
        widget.refreshToken!.isEmpty) {
      displaySnackBar("Error, Please Login to Chat", context);
      Navigator.pop(context);
      return;
    }
    log(otherUserId);
    if (FirebaseAuth.instance.currentUser == null) {
      widget.isBrandUser
          ? ChatProvider.brandSignIn(widget.isBrandUser, widget.accessToken, widget.refreshToken)
          : ChatProvider.userSignIn(widget.isBrandUser, widget.accessToken, widget.refreshToken);
      try {
        userStream = FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (mounted) {
            if (user != null) {
              if (userStream != null) {
                userStream!.cancel();
              }
              findChat(otherUserId);
            }
          }
        });
      } catch (e) {
        consoleLog(e.toString());
        displaySnackBar("Error, Please try again later", context);
        Navigator.pop(context);
      }
    } else {
      findChat(otherUserId);
    }
  }

  findChat(String otherUserId) async {
    types.Room? chatRoom = await checkIfRoomExists(otherUserId);
    if (chatRoom != null) {
      log("Room Exists");
      room = chatRoom;
      setState(() {});
    } else {
      types.User? user = await getUserFromFireStore(
        otherUserId,
        firstName: widget.firstName,
        lastName: widget.lastName,
        imageUrl: widget.profileImage,
      );
      if (user != null) {
        consoleLog("Creating New Room for $otherUserId");
        room = await FirebaseChatCore.instance.createRoom(user);
        consoleLog('Room Name: ${room!.name}\nId: ${room!.id}\nUsers: ${room!.userIds}');
        setState(() {});
      } else {
        displaySnackBar("Error, User Not Found", context);
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
        : ChatPage(room!, widget.onViewOrderDetailsClick);
  }
}
