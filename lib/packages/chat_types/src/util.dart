import '../../../core/screens/chat_utils.dart';
import 'message.dart' show Status;
import 'room.dart';
import 'user.dart' show Role;

/// Get User Id Of The Other User
///
/// If room is Channel then it returns owner Id of the room
/// If room is Direct : Returns the other user Id from [userIds]
String? getChatUserId(Room? room) {
  List ids = room?.userIds ?? [];
  if (room?.type == RoomType.channel) return room?.owner;
  String? chatUserId;
  if (ids.isEmpty == true) {
    return null;
  }
  for (var id in ids) {
    if (id != chatUtils.firebaseAuth.currentUser?.uid) {
      chatUserId = id.toString();
    }
  }
  if (chatUserId == "deleted-brand" || chatUserId == "deleted-user") {
    return null;
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
