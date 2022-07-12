import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/packages/chat_types/src/room.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/utils/functions.dart';

import '../../features/chat/domain/brand_firebase_token_model.dart';
import '../../models/base_model.dart';
import '../../network/api_service.dart';
import '../../packages/chat_core/src/util.dart';
import '../services/notification_service.dart';

final chatUtils = GetIt.I<ChatUtils>();

class ChatUtils {
  /// This should be set to [true] if the package is running in Creators App
  final bool isCreatorsApp;

  /// Firebase App to use throughout the package
  final FirebaseApp firebaseApp;

  /// The base url of current environment for API calls
  final String baseUrl;

  ChatUtils({this.isCreatorsApp = false, required this.baseUrl, required this.firebaseApp});

  List<types.Room> roomList = [];

  /// Used to store room list as cache while the app is running
  updateRoomList(List<types.Room> roomList) {
    this.roomList = roomList;
  }

  /// Logs in the user to Firebase using the given [accessToken] and [refreshToken]
  static initFirebaseApp({required String accessToken, required String refreshToken, void Function()? onInit}) async {
    StreamSubscription<User?>? userStream;
    if (chatUtils.firebaseAuth.currentUser == null) {
      GetIt.I<ChatUtils>().isCreatorsApp
          ? ChatProvider.brandSignIn(accessToken, refreshToken)
          : ChatProvider.userSignIn(accessToken, refreshToken);
      try {
        userStream = chatUtils.firebaseAuth.authStateChanges().listen((User? user) {
          if (user != null) {
            onInit?.call();
            if (userStream != null) {
              userStream.cancel();
            }
          }
        });
      } catch (e) {
        consoleLog(e.toString());
      }
    } else {
      onInit?.call();
    }
  }

  static Future<BaseModel<BrandFirebaseTokenModel>> getCreatorFcmTokens(String accessToken) async {
    return await ApiService().getBrandFirebaseToken(accessToken);
  }

  static Stream<List<int>> getUnreadMessages({FirebaseApp? app}) {
    var firebaseUser = getFirebaseAuth(app).currentUser;
    if (firebaseUser == null) return const Stream.empty();

    final collection = getFirebaseFirestore(app).collection('rooms').where('userIds', arrayContains: firebaseUser.uid);

    return collection.snapshots().asyncMap((query) => _processChatsQuery(query, app: app));
  }

  static Future<List<int>> _processChatsQuery(QuerySnapshot query, {FirebaseApp? app}) async {
    final futures = query.docs.map((doc) {
      final Map<String, dynamic> room = doc.data() as Map<String, dynamic>;
      if (room['type'] == "channel") {
        //Subscribing to channel
        ChatNotificationService.subscribeToChannel(room);
      }
      return getUnreadMessageCount(doc, getFirebaseAuth(app).currentUser!, app: app);
    });
    return await Future.wait(futures);
  }

  static Future updateUnreadMessageStatus(ChatProvider provider) async {
    // Handling the Room Types
    if (provider.selectedChatRoom?.type == RoomType.channel) {
      final collection = await chatUtils.firebaseFirestore
          .collection('rooms')
          .doc(provider.selectedChatRoom!.id)
          .collection('messages')
          .where('authorId', isNotEqualTo: chatUtils.firebaseAuth.currentUser!.uid)
          .where('unreadUserIds', arrayContains: chatUtils.firebaseAuth.currentUser!.uid)
          .get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> singleMessage in collection.docs) {
        chatUtils.firebaseFirestore
            .collection('rooms')
            .doc(provider.selectedChatRoom!.id)
            .collection('messages')
            .doc(singleMessage.id)
            .update({
          'unreadUserIds': FieldValue.arrayRemove([chatUtils.firebaseAuth.currentUser!.uid]),
        });
      }
    } else {
      try {
        final collection = await chatUtils.firebaseFirestore
            .collection('rooms')
            .doc(provider.selectedChatRoom!.id)
            .collection('messages')
            .where('authorId', isNotEqualTo: chatUtils.firebaseAuth.currentUser!.uid)
            .where("status", isEqualTo: "sent")
            .get();
        for (QueryDocumentSnapshot<Map<String, dynamic>> singleMessage in collection.docs) {
          chatUtils.firebaseFirestore
              .collection('rooms')
              .doc(provider.selectedChatRoom!.id)
              .collection('messages')
              .doc(singleMessage.id)
              .update({'status': 'delivered'});
        }
      } catch (e, s) {
        consoleLog('Error in updateUnreadMessageStatus: $e\n $s');
      }
    }
  }

  FirebaseAuth get firebaseAuth => FirebaseAuth.instanceFor(app: firebaseApp);
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instanceFor(app: firebaseApp);
  FirebaseStorage get firebaseStorage => FirebaseStorage.instanceFor(app: firebaseApp);

  static FirebaseAuth getFirebaseAuth(FirebaseApp? app) =>
      app == null ? chatUtils.firebaseAuth : FirebaseAuth.instanceFor(app: app);

  static FirebaseFirestore getFirebaseFirestore(FirebaseApp? app) =>
      app == null ? chatUtils.firebaseFirestore : FirebaseFirestore.instanceFor(app: app);
}
