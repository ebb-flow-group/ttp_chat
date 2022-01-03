import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:ttp_chat/core/new_screens/search_user/widgets/no_search_results.dart';
import 'package:ttp_chat/core/new_screens/widgets/chat_tile.dart';
import 'package:ttp_chat/core/new_screens/widgets/helpers.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/screens/loading_screen.dart';
import 'package:ttp_chat/utils/functions.dart';

class RoomsList extends StatefulWidget {
  final bool? isSwitchedAccount;
  final String accessToken;
  final view list;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const RoomsList(
      this.isSwitchedAccount, this.accessToken, this.onViewOrderDetailsClick,
      {this.list = view.brands, Key? key})
      : super(key: key);

  @override
  _RoomsListState createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  late Stream<List<types.Room>> stream;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      stream = FirebaseChatCore.instance.rooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<List<types.Room>>(
        stream: stream,
        initialData: const [],
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const LoadingScreen();
            default:
              if (snapshot.hasError) {
                consoleLog('BRAND STREAM B ERROR: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 17.0),
                  child: NoResults(),
                );
              }
              return roomsListWidget(snapshot);
          }
        },
      ),
    );
  }

  Widget roomsListWidget(AsyncSnapshot<List<types.Room>> snapshot) {
    List<types.Room> rooms = snapshot.data!
        .where((element) =>
            element.metadata!['other_user_type'] ==
            (widget.list == view.brands ? 'brand' : 'user'))
        .toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.only(top: 17),
      child: rooms.isEmpty
          ? const NoResults()
          : ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                var room = rooms[index];
                return ChatTile(
                  room,
                  onTap: () async {
                    var result = await pushTo(
                        ChatPage(room, widget.isSwitchedAccount!,
                            widget.onViewOrderDetailsClick),
                        context);
                    if (result == null) {
                      setState(() {
                        stream = FirebaseChatCore.instance.rooms();
                      });
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 17);
              },
            ),
    );
  }
}
