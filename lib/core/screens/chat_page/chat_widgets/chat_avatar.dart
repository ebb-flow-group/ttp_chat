import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/src/room.dart';
import 'package:ttp_chat/utils/util.dart';

class ChatAvatar extends StatelessWidget {
  final Room room;
  final double radius;
  const ChatAvatar(this.room, {this.radius = 20, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = getRoomAvatarNameColor(room);
    final hasImage = room.imageUrl != null && room.imageUrl != '';
    final name = getRoomName(room);
    return CircleAvatar(
      backgroundColor: color,
      backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
      radius: radius,
      child: !hasImage
          ? Text(
              name.isEmpty ? '' : name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
          : null,
    );
  }
}
