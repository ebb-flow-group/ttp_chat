import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/packages/chat_types/src/room.dart';
import 'package:ttp_chat/utils/functions.dart';

import '../../../../packages/chat_types/src/util.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import '../../widgets/chat_avatar.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({Key? key, required this.chatRoom}) : super(key: key);

  final Room chatRoom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Text(
          'You’re about to chat with',
          style: Ts.text15(Config.grayG1Color),
        ),
        const SizedBox(height: 30),
        ChatAvatar(chatRoom, radius: 50),
        const SizedBox(height: 14),
        Text(
          chatRoom.name ?? "",
          style: Ts.bold17(Config.primaryColor),
        ),
        //  const SizedBox(height: 4),
        // Text(
        //   '@${getChatUserId(chatRoom?.userIds)}',
        //   style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor),
        // ),
        const SizedBox(height: 30),
        if (!GetIt.I<ChatUtils>().isCreatorsApp)
          if (getChatUserId(chatRoom) != null)
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                child: Text(
                  "View Profile",
                  style: Ts.bold14(Config.creameryColor),
                ),
                onPressed: () {
                  String userId = getChatUserId(chatRoom) ?? "";
                  if (chatRoom.metadata?["other_user_type"] == "brand") {
                    Routes.navigateToOutletPage(context, userId);
                  } else if (chatRoom.metadata?["other_user_type"] == "user") {
                    Routes.navigateToUserProfile(context, userId);
                  } else {
                    consoleLog("ChatRoomAppBar: user type not found");
                  }
                }),
      ],
    );
  }
}
