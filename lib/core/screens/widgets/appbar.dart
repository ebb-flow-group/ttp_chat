import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

AppBar chatAppBar(
  BuildContext context, {
  void Function()? goToSearch,
  void Function()? viewOrdersPage,
}) {
  return AppBar(
    backgroundColor: const Color(0xFFFDFBEF).withOpacity(0.2),
    title: Text('Chat', style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 24)),
    actions: [
      Row(
        children: [
          //...
          IconButton(
            onPressed: viewOrdersPage,
            icon: SvgPicture.asset(
              'assets/icon/orders.svg',
              package: 'ttp_chat',
              color: Theme.of(context).primaryColor,
              width: 20,
              height: 20,
            ),
          ),

          //...
          IconButton(
            onPressed: goToSearch,
            icon: SvgPicture.asset(
              'assets/chat_icons/start_new_chat.svg',
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    ],
    centerTitle: false,
  );
}
