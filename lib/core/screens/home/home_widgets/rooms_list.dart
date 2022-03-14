import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../../features/chat/presentation/chat_provider.dart';
import '../../../../packages/chat_types/src/room.dart';
import '../../../../utils/functions.dart';
import '../../../widgets/no_search_results.dart';
import '../../chat_page/chat_page.dart';
import '../../loading_screen.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/helpers.dart';

class RoomsList extends StatefulWidget {
  final AsyncSnapshot<List<Room>> snapshot;
  final bool isSwitchedAccount;

  final view list;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const RoomsList(this.snapshot, this.isSwitchedAccount, this.onViewOrderDetailsClick,
      {this.list = view.brands, Key? key})
      : super(key: key);

  @override
  _RoomsListState createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Builder(
        builder: (context) {
          // log("message");
          // log(chatProvider.roomList.map((e) => e.toJson()).toList().toString());
          if (widget.snapshot.hasError) {
            consoleLog('BRAND STREAM B ERROR: ${widget.snapshot.error}');
          }

          if ((widget.snapshot.hasData && widget.snapshot.data != null && widget.snapshot.data!.isNotEmpty) ||
              chatProvider.roomList.isNotEmpty) {
            return RoomListView(
              snapshot: widget.snapshot,
              list: widget.list,
              onTap: (room) async {
                var result = await pushTo(ChatPage(room, widget.onViewOrderDetailsClick), context);
                if (result == null) {
                  setState(() {
                    // log('****** Updating Room List ******');
                    chatProvider.updateStream();
                  });
                }
              },
            );
          }
          if (widget.snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          if (!widget.snapshot.hasData || widget.snapshot.data!.isEmpty) {
            return const NoResults();
          }
          return Container();
        },
      ),
    );
  }
}

class RoomListView extends StatelessWidget {
  const RoomListView({
    Key? key,
    required this.list,
    required this.onTap,
    required this.snapshot,
  }) : super(key: key);

  final view list;
  final ValueChanged<types.Room> onTap;
  final AsyncSnapshot<List<types.Room>> snapshot;

  @override
  Widget build(BuildContext context) {
    List<types.Room> rooms = snapshot.data
            ?.where((element) => element.metadata!['other_user_type'] == (list == view.brands ? 'brand' : 'user'))
            .toList() ??
        [];
    //For Searching Users
    if (context.read<ChatProvider>().searchString.isNotEmpty) {
      rooms = rooms
          .where((element) =>
              (element.name?.toLowerCase().contains(context.read<ChatProvider>().searchString.toLowerCase()) == true))
          .toList();
    }
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
                  onTap: () {
                    onTap(room);
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
