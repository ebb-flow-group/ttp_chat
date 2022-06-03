import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/packages/chat_types/src/room.dart';

import '../../../../config.dart';
import '../../../../packages/chat_types/src/util.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import '../../widgets/chat_avatar.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Room chatRoom;

  const ChatRoomAppBar(this.chatRoom, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: false,
      titleSpacing: 1,
      title: GestureDetector(
        onTap: () {
          if (!GetIt.I<ChatUtils>().isCreatorsApp && getChatUserId(chatRoom) != null) {
            String userId = getChatUserId(chatRoom) ?? "";
            if (chatRoom.metadata?["other_user_type"] == "brand") {
              Routes.navigateToOutletPage(context, userId);
            } else if (chatRoom.metadata?["other_user_type"] == "user") {
              Routes.navigateToUserProfile(context, userId);
            }
          }
        },
        child: Row(
          children: [
            ChatAvatar(chatRoom, radius: 20),
            const SizedBox(width: 10),
            Text(
              chatRoom.name ?? "",
              style: Ts.bold15(Config.primaryColor),
            ),
          ],
        ),
      ),
      actions: const [
        // IconButton(
        //     icon: SvgPicture.asset(
        //       'assets/chat_icons/settings_two.svg',
        //       color: Theme.of(context).primaryColor,
        //       height: 18,
        //       width: 18,
        //     ),
        //     onPressed: () {}),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
