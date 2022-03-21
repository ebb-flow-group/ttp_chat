import 'package:flutter/material.dart';

import '../../../widgets/no_search_results.dart';

class SearchListView extends StatelessWidget {
  final List list;
  final Widget Function(BuildContext, int) itemBuilder;
  const SearchListView({required this.list, required this.itemBuilder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            itemBuilder: itemBuilder,
          )
        : const NoResults();
  }
}
