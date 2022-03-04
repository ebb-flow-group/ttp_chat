import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../../features/chat/presentation/chat_provider.dart';
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
  final Stream<List<types.Room>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<types.Room>>(
        stream: stream,
        initialData: chatProvider.roomList,
        builder: (context, snapshot) {
          int userCount =
              snapshot.data?.where((element) => element.metadata!['other_user_type'] == ('user')).toList().length ?? 0;
          int brandCount =
              snapshot.data?.where((element) => element.metadata!['other_user_type'] == ('brand')).toList().length ?? 0;
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
                            count: userCount),
                        HomeTab(
                            onTap: () => onTap(1),
                            selectedTabIndex: selectedTabIndex,
                            index: 1,
                            title: 'Brands',
                            count: brandCount),
                      ]
                    : [
                        HomeTab(
                            onTap: () => onTap(0),
                            selectedTabIndex: selectedTabIndex,
                            index: 0,
                            title: 'Brands',
                            count: brandCount),
                        HomeTab(
                            onTap: () => onTap(1),
                            selectedTabIndex: selectedTabIndex,
                            index: 1,
                            title: 'People',
                            count: userCount),
                      ],
              ),
              Container(
                height: 3,
                color: Theme.of(context).primaryColor,
              )
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
