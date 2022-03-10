import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/global.dart';
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
    final futures = query.docs.map((doc) => getUnreadMessageCount(doc.id, FirebaseAuth.instance.currentUser!));
    return await Future.wait(futures);
  }

  static String getOrderStatus(String status) {
    bool isCreatorsApp = GetIt.I<ChatUtils>().isCreatorsApp;
    switch (status) {
      case 'paid':
        return 'PAID';
      case 'checked_out':
        return isCreatorsApp ? 'CHECKED OUT' : 'TO PAY';
      case 'failed':
        return 'FAILED';
      case 'rejected':
        return 'REJECTED';
      case 'accepted':
        return 'ACCEPTED';
      case 'scheduled':
        return 'SCHEDULED';
      case 'pending_completion':
        return 'PENDING COMPLETION';
      case 'completed':
        return 'COMPLETED';
      case 'dispute':
        return 'DISPUTE';
      default:
        return '';
    }
  }

  static String getOrderType(Map<String, dynamic>? metadata) {
    if (metadata == null) return "";
    log(metadata.toString());
    String orderType = metadata['type'];
    if (metadata["message_type"] == "home_order_update" || metadata["message_type"] == "home_order_create") {
      switch (orderType) {
        case 'pick_up':
          return 'Pickup';
        case 'take_away':
          return 'Pickup';
        case 'dine_in':
          return 'Dine In';
        case 'delivery':
          return 'Delivery';
        default:
          return '';
      }
    } else {
      switch (orderType) {
        case 'pick_up':
          return 'Pickup';
        case 'take_away':
          return 'Take Away';
        case 'dine_in':
          return 'Dine In';
        case 'delivery':
          return 'Delivery';
        default:
          return '';
      }
    }
    return "";
  }

  String getOrderDate(int orderDate) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(orderDate);

    if (date == DateTime.now()) {
      return 'Today';
    } else if (date.isBefore(DateTime.now())) {
      return DateFormat('dd MMM').format(date);
    } else {
      return '';
    }
  }

  Future updateUnreadMessageStatus(ChatProvider provider) async {
    try {
      final collection = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(provider.selectedChatUser!.id)
          .collection('messages')
          .where('authorId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> singleMessage in collection.docs) {
        FirebaseFirestore.instance
            .collection('rooms')
            .doc(provider.selectedChatUser!.id)
            .collection('messages')
            .doc(singleMessage.id)
            .update({'status': 'delivered'});
      }
    } catch (e, s) {
      consoleLog('Error in updateUnreadMessageStatus: $e\n $s');
    }
  }
}
