import 'package:flutter/material.dart';
import 'package:ttp_chat/core/screens/widgets/helpers.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/packages/chat_types/src/room.dart';

import 'rooms_list.dart';

class RoomListView extends StatelessWidget {
  const RoomListView({
    Key? key,
    required this.selectedTabIndex,
    required this.isSwitchedAccount,
    required this.chatProvider,
    required this.stream,
    required this.onTap,
  }) : super(key: key);

  final int selectedTabIndex;
  final bool isSwitchedAccount;
  final ChatProvider chatProvider;

  final AsyncSnapshot<List<Room>> stream;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 17.0),
          child: InputSearch(
            hintText: 'Search a brand, user or mobile',
            onChanged: (String value) {
              chatProvider.searchUsers(value);
            },
          ),
        ),
        const SizedBox(height: 10),
        isSwitchedAccount
            ? Expanded(
                child: RoomsList(
                  stream,
                  provider: chatProvider,
                  list: chatProvider.selectedTabIndex == 0 ? View.users : View.brands,
                ),
              )
            : Expanded(
                child: RoomsList(
                  stream,
                  provider: chatProvider,
                  list: chatProvider.selectedTabIndex == 0 ? View.brands : View.users,
                ),
              )
      ],
    );
  }
}
