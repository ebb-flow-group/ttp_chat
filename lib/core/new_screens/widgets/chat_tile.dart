import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:ttp_chat/core/new_screens/widgets/chat_avatar.dart';

import 'helpers.dart';
import 'last_message_widget.dart';

class ChatTile extends StatelessWidget {
  final Room room;
  final Function()? onTap;

  const ChatTile(this.room, {this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          ChatAvatar(room),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
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
                      getLastMessageDateTime(
                          room.metadata?['last_messages'] ?? {}),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    room.metadata?['unread_message_count'] != 0
                        ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                            child: Text(
                              room.metadata?['unread_message_count']
                                      .toString() ??
                                  "",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12, height: 1),
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
