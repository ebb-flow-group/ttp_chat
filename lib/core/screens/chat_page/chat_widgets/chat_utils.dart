import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/utils/functions.dart';

class ChatUtils {
  String getOrderStatus(String status) {
    switch (status) {
      case 'paid':
        return 'PAID';
      case 'checked_out':
        return 'CHECKED OUT';
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

  String getOrderType(String orderType) {
    switch (orderType) {
      case 'pick_up':
        return 'Take Away';
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
