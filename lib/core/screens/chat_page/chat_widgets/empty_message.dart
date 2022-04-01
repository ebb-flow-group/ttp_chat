import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';
import 'package:ttp_chat/utils/functions.dart';

import '../../../../packages/chat_types/src/util.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import '../../widgets/chat_avatar.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({Key? key, required this.chatProvider}) : super(key: key);

  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Text(
          'You\'re about to chat up...',
          style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 30),
        ChatAvatar(chatProvider.selectedChatRoom!, radius: 50),
        const SizedBox(height: 14),
        Text(
          chatProvider.selectedChatRoom?.name ?? "",
          style: appBarTitleStyle(context),
        ),
        //  const SizedBox(height: 4),
        // Text(
        //   '@${getChatUserId(chatProvider.selectedChatRoom?.userIds)}',
        //   style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor),
        // ),
        const SizedBox(height: 30),
        if (!GetIt.I<ChatUtils>().isCreatorsApp)
          if ((chatProvider.selectedChatRoom?.metadata?["other_user_type"] == "brand" &&
              getChatUserId(chatProvider.selectedChatRoom) != null))
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                child: Text(
                  "View Profile",
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                onPressed: () {
                  String? userId = getChatUserId(chatProvider.selectedChatRoom);
                  consoleLog("userId: $userId");
                  if (userId != null && userId != 'deleted-brand') {
                    context.push(Routes.homeOutletDetailPage, extra: userId);
                  }
                }),
      ],
    );
  }
}
