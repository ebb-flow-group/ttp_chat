import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum view { users, brands }

String getLastMessageDateTime(Map<String, dynamic> lastMessageData) {
  String formattedDate = '';

  if (lastMessageData.isNotEmpty && lastMessageData['createdAt'] != null) {
    if (lastMessageData['createdAt'] is Timestamp) {
      Timestamp timestamp = lastMessageData['createdAt'] as Timestamp;
      DateTime d = timestamp.toDate();
      formattedDate = DateFormat('hh:mm a').format(d);
    } else if (lastMessageData['createdAt'] is String) {
      formattedDate = lastMessageData['createdAt'];
    }
  }
  return formattedDate;
}
