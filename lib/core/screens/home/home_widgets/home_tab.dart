import 'package:flutter/material.dart';
import 'package:ttp_chat/core/screens/search_page/search_widgets/search_tab_bar.dart';

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
