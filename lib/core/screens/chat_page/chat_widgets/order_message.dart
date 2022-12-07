import 'package:flutter/material.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_accepted.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_completed.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_disputed.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_failed.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_paid.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_pending_completion.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_rejected.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message/order_message_scheduled.dart';
import 'package:ttp_chat/core/widgets/empty.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

class OrderMessage extends StatelessWidget {
  final CustomMessage message;

  const OrderMessage(
    this.message, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (message.metadata?['status']) {
      case 'checked_out':
        // `checked_out` status not supported in chat
        return const Empty();
      case 'failed':
        return OrderMessageFailed(message: message);

      case 'paid':
        return OrderMessagePaid(message: message);

      case 'rejected':
        return OrderMessageRejected(message: message);

      case 'accepted':
        return OrderMessageAccepted(message: message);

      case 'scheduled':
        return OrderMessageScheduled(message: message);

      case 'pending_completion':
        return OrderMessagePendingCompletion(message: message);

      case 'completed':
        return OrderMessageCompleted(message: message);

      case 'dispute':
        return OrderMessageDisputed(message: message);

      case 'expired':
        // `expired` status not supported in chat
        return const Empty();
      case 'cancelled_without_refund':
      case 'cancelled':
        // TODO: Pending design
        return const Empty();
      default:
        return const Empty();
    }
  }
}
