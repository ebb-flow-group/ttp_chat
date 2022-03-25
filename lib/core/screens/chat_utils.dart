import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/global.dart';
import 'package:ttp_chat/packages/chat_types/src/room.dart';
import 'package:ttp_chat/utils/functions.dart';

import '../../packages/chat_core/src/util.dart';

class ChatUtils {
  final bool isCreatorsApp;
  final String baseUrl;
  ChatUtils({this.isCreatorsApp = false, this.baseUrl = BASE_URL});

  static initFirebaseApp({required String accessToken, required String refreshToken, void Function()? onInit}) async {
    await Firebase.initializeApp();
    if (FirebaseAuth.instance.currentUser == null) {
      GetIt.I<ChatUtils>().isCreatorsApp
          ? ChatProvider.brandSignIn(accessToken, refreshToken)
          : ChatProvider.userSignIn(accessToken, refreshToken);
      try {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            onInit?.call();
          }
        });
      } catch (e) {
        consoleLog(e.toString());
      }
    } else {
      onInit?.call();
    }
  }

  Stream<List<int>> getUnreadMessages() {
    var firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return const Stream.empty();

    final collection = FirebaseFirestore.instance.collection('rooms').where('userIds', arrayContains: firebaseUser.uid);

    return collection.snapshots().asyncMap((query) => processChatsQuery(query));
  }

  Future<List<int>> processChatsQuery(
    QuerySnapshot query,
  ) async {
    final futures = query.docs.map((doc) => getUnreadMessageCount(doc, FirebaseAuth.instance.currentUser!));
    return await Future.wait(futures);
  }

  static Future updateUnreadMessageStatus(ChatProvider provider) async {
    if (provider.selectedChatRoom?.type == RoomType.channel) {
      //log("updateUnreadMessageStatus: channel");
      final collection = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(provider.selectedChatRoom!.id)
          .collection('messages')
          .where('authorId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('unreadUserIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> singleMessage in collection.docs) {
        FirebaseFirestore.instance
            .collection('rooms')
            .doc(provider.selectedChatRoom!.id)
            .collection('messages')
            .doc(singleMessage.id)
            .update({
          'unreadUserIds': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
        });
      }
    } else {
      try {
        final collection = await FirebaseFirestore.instance
            .collection('rooms')
            .doc(provider.selectedChatRoom!.id)
            .collection('messages')
            .where('authorId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("status", isEqualTo: "sent")
            .get();
        for (QueryDocumentSnapshot<Map<String, dynamic>> singleMessage in collection.docs) {
          FirebaseFirestore.instance
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
}
