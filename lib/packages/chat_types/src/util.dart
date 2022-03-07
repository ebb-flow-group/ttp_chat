import 'package:firebase_auth/firebase_auth.dart';

import 'message.dart' show Status;
import 'room.dart' show RoomType;
import 'user.dart' show Role;

String? getChatUserId(List? ids) {
  String? chatUserId;
  if (ids == null && (ids?.isEmpty == true)) {
    return null;
  }
  for (var id in ids!) {
    if (id != FirebaseAuth.instance.currentUser?.uid) {
      chatUserId = id;
    }
  }
  return chatUserId;
}

/// Converts [stringStatus] to the [Status] enum.
Status? getStatusFromString(String? stringStatus) {
  for (final status in Status.values) {
    if (status.toString() == 'Status.$stringStatus') {
      return status;
    }
  }

  return null;
}

/// Converts [stringRole] to the [Role] enum.
Role? getRoleFromString(String? stringRole) {
  for (final role in Role.values) {
    if (role.toString() == 'Role.$stringRole') {
      return role;
    }
  }

  return null;
}

/// Converts [stringRoomType] to the [RoomType] enum.
RoomType getRoomTypeFromString(String stringRoomType) {
  for (final roomType in RoomType.values) {
    if (roomType.toString() == 'RoomType.$stringRoomType') {
      return roomType;
    }
  }

  return RoomType.unsupported;
}
