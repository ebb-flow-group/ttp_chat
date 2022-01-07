import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ttp_chat/core/screens/home/home_widgets/rooms_list.dart';
import 'package:ttp_chat/core/screens/widgets/helpers.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';

import 'home_tabs.dart';

class RoomListView extends StatelessWidget {
  const RoomListView(
      {Key? key,
      required this.selectedTabIndex,
      required this.isSwitchedAccount,
      required this.chatProvider,
      required this.stream,
      required this.onTap,
      this.onViewOrderDetailsClick})
      : super(key: key);

  final int selectedTabIndex;
  final bool isSwitchedAccount;
  final ChatProvider chatProvider;

  final Function(int?, String?, String?)? onViewOrderDetailsClick;
  final Stream<List<types.Room>> stream;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 17),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 17.0),
          child: InputSearch(
              hintText: 'Search a brand, user or mobile',
              onChanged: (String value) {}),
        ),
        const SizedBox(height: 17),
        HomeTabs(
            isSwitchedAccount: isSwitchedAccount,
            selectedTabIndex: selectedTabIndex,
            chatProvider: chatProvider,
            onTap: onTap),
        isSwitchedAccount
            ? Expanded(
                child: RoomsList(
                    stream, isSwitchedAccount, onViewOrderDetailsClick,
                    list: chatProvider.selectedTabIndex == 0
                        ? view.users
                        : view.brands),
              )
            : Expanded(
                child: RoomsList(
                    stream, isSwitchedAccount, onViewOrderDetailsClick,
                    list: chatProvider.selectedTabIndex == 0
                        ? view.brands
                        : view.users),
              )
      ],
    );
  }
}
