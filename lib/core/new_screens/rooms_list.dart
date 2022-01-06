import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/new_screens/search_user/widgets/no_search_results.dart';
import 'package:ttp_chat/core/new_screens/widgets/chat_tile.dart';
import 'package:ttp_chat/core/new_screens/widgets/helpers.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/widgets/rive_anim.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/utils/functions.dart';

class RoomsList extends StatefulWidget {
  final Stream<List<types.Room>> stream;
  final bool? isSwitchedAccount;
  final String accessToken;
  final view list;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const RoomsList(this.stream, this.isSwitchedAccount, this.accessToken,
      this.onViewOrderDetailsClick,
      {this.list = view.brands, Key? key})
      : super(key: key);

  @override
  _RoomsListState createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  late ChatProvider chatProvider;

  late Stream<List<types.Room>> stream;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    if (FirebaseAuth.instance.currentUser != null) {
      stream = widget.stream;
      stream.listen((event) => chatProvider.saveRoomList(event));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<List<types.Room>>(
        stream: stream,
        initialData: chatProvider.roomList,
        builder: (context, snapshot) {
          // log("message");
          // log(chatProvider.roomList.map((e) => e.toJson()).toList().toString());
          if (snapshot.hasError) {
            consoleLog('BRAND STREAM B ERROR: ${snapshot.error}');
          }

          if ((snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) ||
              chatProvider.roomList.isNotEmpty) {
            return roomsListWidget(snapshot);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: RiveAnim(
                riveFileName: 'assets/chat_icons/loading_anim.riv',
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoResults();
          }
          return Container();
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
                        stream.listen(
                            (event) => chatProvider.saveRoomList(event));
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
