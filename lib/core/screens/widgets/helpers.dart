import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum view { users, brands }

String getLastMessageDateTime(Object? lastMessageData) {
  String formattedDate = '';

  if (lastMessageData is Map<String, dynamic> && lastMessageData.isNotEmpty && lastMessageData['createdAt'] != null) {
    if (lastMessageData['createdAt'] is Timestamp) {
      Timestamp timestamp = lastMessageData['createdAt'] as Timestamp;
      DateTime date = timestamp.toDate();
      DateTime now = DateTime.now();
      if (date.day == now.day && date.month == now.month && date.year == now.year) {
        formattedDate = DateFormat('hh:mm a').format(date);
      } else if (date.year == now.year - 1) {
        formattedDate = DateFormat('MMM dd').format(date);
      } else {
        formattedDate = DateFormat('d MMM').format(date);
      }
    } else if (lastMessageData['createdAt'] is String) {
      formattedDate = lastMessageData['createdAt'];
    }
  }

  return formattedDate;
}

getInitials(String text) =>
    (text.isNotEmpty ? text.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join() : '').toUpperCase();
