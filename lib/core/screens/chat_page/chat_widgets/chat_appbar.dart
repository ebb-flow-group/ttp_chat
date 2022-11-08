import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/core/screens/widgets/chat_avatar.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/routes.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/core/widgets/verified_text.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/packages/chat_types/src/util.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatProvider chatProvider;

  const ChatRoomAppBar(this.chatProvider, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: false,
      titleSpacing: 1,
      title: GestureDetector(
        onTap: () {
          if (!GetIt.I<ChatUtils>().isCreatorsApp && getChatUserId(chatProvider.selectedChatRoom) != null) {
            String userId = getChatUserId(chatProvider.selectedChatRoom) ?? "";
            if (chatProvider.selectedChatRoom?.metadata?["other_user_type"] == "brand") {
              Routes.navigateToOutletPage(context, userId);
            } else if (chatProvider.selectedChatRoom?.metadata?["other_user_type"] == "user") {
              Routes.navigateToUserProfile(context, userId);
            }
          }
        },
        child: Row(
          children: [
            ChatAvatar(chatProvider.selectedChatRoom!, radius: 15),
            const SizedBox(width: 10),
            VerifiedText(
              text: chatProvider.selectedChatRoom?.name ?? '',
              verified: chatProvider.selectedChatRoom?.verified ?? false,
              style: Ts.t2Bold(Config.primaryColor),
              iconSize: L.v(13),
              iconPadding: const EdgeInsets.only(left: 5),
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
