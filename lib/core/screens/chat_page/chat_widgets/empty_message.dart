import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';

import '../../../../packages/chat_types/src/util.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import 'chat_avatar.dart';

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
        ChatAvatar(chatProvider.selectedChatUser!, radius: 50),
        const SizedBox(height: 14),
        Text(
          chatProvider.selectedChatUser?.name ?? "",
          style: appBarTitleStyle(context),
        ),
        //  const SizedBox(height: 4),
        // Text(
        //   '@${getChatUserId(chatProvider.selectedChatUser?.userIds)}',
        //   style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor),
        // ),
        const SizedBox(height: 30),
        if (!GetIt.I<ChatUtils>().isCreatorsApp)
          if ((chatProvider.selectedChatUser?.metadata?["other_user_type"] == "brand" &&
              getChatUserId(chatProvider.selectedChatUser?.userIds) != null))
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
                  String? userId = getChatUserId(chatProvider.selectedChatUser?.userIds);
                  log("userId: $userId");
                  if (userId != null && userId != 'deleted-brand') {
                    context.push(Routes.homeOutletDetailPage, extra: userId);
                  }
                }),
      ],
    );
  }
}
