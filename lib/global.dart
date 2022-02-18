// ignore: constant_identifier_names
import 'package:ttp_chat/packages/chat_types/src/room.dart';

import 'packages/chat_core/src/firebase_chat_core.dart';

const BASE_URL = "https://dev-v2.tabletop-cloud.com";
// const BASE_URL = "https://prod-v2.tabletop-cloud.com";
// const BASE_URL = "https://stage-v2.tabletop-cloud.com";

Stream<List<Room>> roomsStream = FirebaseChatCore.instance.rooms(orderByUpdatedAt: true);
