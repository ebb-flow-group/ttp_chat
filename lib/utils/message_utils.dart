import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

/// Returns the same [messages] list with added `isLastMessageWithOrder` property to [CustomMessage]s metadata object
/// if they are the last message with the order id.
/// 
/// This property is used to determine if the order message should be displayed with buttons or not.
///
/// Assuming [messages] are sorted in descending order by timestamp
List<types.Message> addIsLastOrderMessageProperty(List<types.Message> messages) {
  // Map<orderId, indexOfLatestMessageWithOrderId>
  final Map<int, int> orderIdsToLastMessageIndex = {};

  for (final types.Message message in messages) {
    if (message is types.CustomMessage && message.metadata?['id'] != null) {
      final int orderId = message.metadata?['id'] as int;
      if (orderIdsToLastMessageIndex[orderId] == null) {
        orderIdsToLastMessageIndex[orderId] = messages.indexOf(message);
      }
    }
  }

  orderIdsToLastMessageIndex.forEach((key, value) {
    final types.CustomMessage message = messages[value] as types.CustomMessage;
    message.metadata?['isLastMessageWithOrder'] = true;
  });

  return messages;
}
