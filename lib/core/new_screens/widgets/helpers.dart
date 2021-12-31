import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum view { users, brands }

String getLastMessageDateTime(Map<String, dynamic> lastMessageData) {
  String formattedDate = '';

  if (lastMessageData.isNotEmpty) {
    Timestamp timestamp = lastMessageData['createdAt'] as Timestamp;
    DateTime d = timestamp.toDate();
    formattedDate = DateFormat('hh:mm a').format(d);
  }
  return formattedDate;
}
