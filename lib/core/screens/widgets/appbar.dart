import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/core/services/ts.dart';

import '../../../config.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function()? onSearchTap;
  const ChatAppBar({this.onSearchTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Chat', style: Ts.h2Bold(Config.primaryColor)),
      actions: [
        Row(
          children: [
            //...
            // IconButton(
            //   onPressed: viewOrdersPage ?? () => context.push(Routes.ordersRoute),
            //   icon: SvgPicture.asset(
            //     'assets/icon/orders.svg',
            //     package: 'ttp_chat',
            //     color: Theme.of(context).primaryColor,
            //     width: 20,
            //     height: 20,
            //   ),
            // ),

            //...
            IconButton(
              onPressed: onSearchTap,
              icon: SvgPicture.asset(
                'assets/chat_icons/start_new_chat.svg',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ],
      automaticallyImplyLeading: false,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
