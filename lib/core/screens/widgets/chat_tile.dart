import 'package:flutter/material.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

import '../../../config.dart';
import 'chat_avatar.dart';
import 'helpers.dart';
import 'last_message_widget.dart';

class ChatTile extends StatelessWidget {
  final Room room;
  final void Function()? onTap;

  const ChatTile(this.room, {this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        onTap?.call();
        hideKeyboard(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 16),
        child: Row(
          children: [
            ChatAvatar(room, hasMargin: true),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name ?? "",
                          style: Ts.bold13(Config.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        LastMessaageWidget(room.metadata?['last_messages'] ?? {}),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        getLastMessageDateTime(room.metadata?['last_messages'] ?? {}),
                        style: Ts.demi11(Config.grayG1Color),
                      ),
                      const SizedBox(height: 6),
                      room.metadata?['unread_message_count'] != 0
                          ? Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                              ),
                              child: Text(room.metadata?['unread_message_count'].toString() ?? "",
                                  style: Ts.bold10(Config.creameryColor)),
                            )
                          : const SizedBox()
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
