import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';
import 'package:ttp_chat/utils/functions.dart';

import '../../../../packages/chat_types/src/util.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import 'chat_avatar.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatProvider chatProvider;

  const ChatAppBar(this.chatProvider, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: false,
      titleSpacing: 1,
      title: GestureDetector(
        onTap: () {
          if (!GetIt.I<ChatUtils>().isCreatorsApp) {
            if (chatProvider.selectedChatRoom?.metadata?["other_user_type"] == "brand" &&
                getChatUserId(chatProvider.selectedChatRoom) != null) {
              String? userId = getChatUserId(chatProvider.selectedChatRoom);
              consoleLog("userId: $userId");
              if (userId != null && userId != 'deleted-brand') {
                context.push(Routes.homeOutletDetailPage, extra: userId);
              }
            }
          }
        },
        child: Row(
          children: [
            ChatAvatar(chatProvider.selectedChatRoom!),
            const SizedBox(
              width: 10,
            ),
            Text(
              chatProvider.selectedChatRoom?.name ?? "",
              style: appBarTitleStyle(context),
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
