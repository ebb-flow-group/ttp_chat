import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../../features/chat/presentation/chat_provider.dart';
import '../../../../packages/chat_types/src/room.dart';
import '../../search_page/search_widgets/search_tab_bar.dart';

class HomeTabs extends StatelessWidget {
  const HomeTabs({
    Key? key,
    required this.isSwitchedAccount,
    required this.selectedTabIndex,
    required this.onTap,
    required this.chatProvider,
    required this.stream,
  }) : super(key: key);

  final bool isSwitchedAccount;
  final int selectedTabIndex;
  final ChatProvider chatProvider;
  final void Function(int) onTap;
  final AsyncSnapshot<List<Room>> stream;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      int userUnreadMessageCount = 0;
      int brandUnreadMessageCount = 0;
      if (stream.hasData && stream.data != null) {
        List<types.Room> userRooms =
            stream.data?.where((element) => element.metadata?['other_user_type'] == ('user')).toList() ?? [];
        List<types.Room> brandRooms =
            stream.data?.where((element) => element.metadata?['other_user_type'] == ('brand')).toList() ?? [];

        userUnreadMessageCount = userRooms.fold(
            0,
            (int previousValue, element) =>
                previousValue + (int.tryParse("${element.metadata?['unread_message_count'] ?? 0}") ?? 0));
        brandUnreadMessageCount = brandRooms.fold(
            0,
            (int previousValue, element) =>
                previousValue + (int.tryParse("${element.metadata?['unread_message_count'] ?? 0}") ?? 0));
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: isSwitchedAccount
                ? [
                    HomeTab(
                        onTap: () => onTap(0),
                        selectedTabIndex: selectedTabIndex,
                        index: 0,
                        title: 'People',
                        count: userUnreadMessageCount),
                    HomeTab(
                        onTap: () => onTap(1),
                        selectedTabIndex: selectedTabIndex,
                        index: 1,
                        title: 'Brands',
                        count: brandUnreadMessageCount),
                  ]
                : [
                    HomeTab(
                        onTap: () => onTap(0),
                        selectedTabIndex: selectedTabIndex,
                        index: 0,
                        title: 'Brands',
                        count: brandUnreadMessageCount),
                    HomeTab(
                        onTap: () => onTap(1),
                        selectedTabIndex: selectedTabIndex,
                        index: 1,
                        title: 'People',
                        count: userUnreadMessageCount),
                  ],
          ),
          Container(
            height: 3,
            color: Theme.of(context).primaryColor,
            child: stream.connectionState == ConnectionState.waiting && stream.data == null
                ? LinearProgressIndicator(color: Theme.of(context).primaryColor)
                : null,
          ),
        ],
      );
    });
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    Key? key,
    required this.selectedTabIndex,
    required this.index,
    required this.title,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  final int selectedTabIndex;
  final int index;
  final String title;
  final int count;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SearchTabBar(
      index: index,
      count: count,
      title: title,
      selectedTabIndex: selectedTabIndex,
      onTap: onTap,
    );
  }
}
