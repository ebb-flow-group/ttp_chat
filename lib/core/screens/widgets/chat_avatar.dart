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
    var color = Config.creameryColor;

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

     if (!hasImage) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration:  BoxDecoration(
          color: color,
          gradient: Config.tabletopGradient,
          shape: BoxShape.circle,
        ),
        child: Center(
            child: Text(
          getInitials(name),
          style: Ts.custom(
            size: radius / 1.5,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: radius / 1.5,
            letterSpacing: -.3,
          ),
        )),
      );
    }

    return ClipOval(
      child: Container(
        color: color,
        height: radius * 2,
        width: radius * 2,
        child: cachedImage(room.imageUrl),
      ),
    );
  }
}
