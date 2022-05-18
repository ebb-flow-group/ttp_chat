import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/utils/navigation_helper.dart';

import '../../../../config.dart';
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
  final ChatProvider provider;

  final view list;

  const RoomsList(this.snapshot, {this.list = view.brands, required this.provider, Key? key}) : super(key: key);

  @override
  State<RoomsList> createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Builder(
        builder: (context) {
          if (widget.snapshot.hasError) {
            consoleLog('BRAND STREAM B ERROR: ${widget.snapshot.error}');
          }

          if ((widget.snapshot.hasData && widget.snapshot.data != null && widget.snapshot.data!.isNotEmpty)) {
            return RoomListView(
              snapshot: widget.snapshot,
              list: widget.list,
              onTap: (room) async {
                setState(() {});
                var result = await Push.to(ChatPage(room), context);
                if (result == null) {
                  // log('****** Updating Room List ******');
                  widget.provider.updateStream();
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
    List<types.Room> rooms = snapshot.data ?? [];
    //     ?.where((element) => element.metadata?['other_user_type'] == (list == view.brands ? 'brand' : 'user'))
    //     .toList() ??
    // [];

    //For Searching Users
    if (context.read<ChatProvider>().searchString.isNotEmpty) {
      rooms = rooms
          .where((element) =>
              (element.name?.toLowerCase().contains(context.read<ChatProvider>().searchString.toLowerCase()) == true))
          .toList();
    }
    return RefreshIndicator(
      backgroundColor: Theme.of(context).primaryColor,
      color: Config.mentaikoColor,
      onRefresh: () {
        context.read<ChatProvider>().updateStream();
        return Future.delayed(
          const Duration(seconds: 1),
        );
      },
      child: ListView(
        children: [
          rooms.isEmpty
              ? const NoResults()
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 50),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    var room = rooms[index];
                    return ChatTile(room, onTap: () => onTap(room));
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox();
                  },
                ),
        ],
      ),
    );
  }
}
