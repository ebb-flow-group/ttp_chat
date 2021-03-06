import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

import '../../../config.dart';
import '../../../utils/cached_network_image.dart';
import '../../../utils/util.dart';
import '../../services/ts.dart';
import 'helpers.dart';

class ChatAvatar extends StatelessWidget {
  final double radius;
  final bool hasMargin;
  final Room room;
  const ChatAvatar(this.room, {this.radius = 20, this.hasMargin = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = Colors.white;

    if (room.type == RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
          (u) => u.id != FirebaseAuth.instance.currentUser!.uid,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found
      }
    }

    final hasImage = room.imageUrl != null && room.imageUrl != '';
    final name = room.name ?? '';

    return Container(
      margin: hasMargin ? const EdgeInsets.only(right: 16) : null,
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
          color: color,
          image: !hasImage ? null : DecorationImage(image: cachedImageProvider(room.imageUrl), fit: BoxFit.cover),
          shape: BoxShape.circle,
          gradient: Config.tabletopGradient),
      child: !hasImage
          ? Center(
              child: Text(
                getInitials(name),
                style: Ts.bold13(Config.creameryColor),
              ),
            )
          : null,
    );
  }
}
