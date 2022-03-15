import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/packages/chat_types/src/message.dart';
import 'package:ttp_chat/theme/style.dart';

import '../../../../config.dart';
import '../../../services/routes.dart';

class OrderMessageWidget extends StatelessWidget {
  const OrderMessageWidget(
    this.message, {
    Key? key,
  }) : super(key: key);

  final Message message;

  String get totalPrice {
    if (message.metadata?['total_price_db'] == null || message.metadata?['total_price_db'] == 'None') {
      return "${message.metadata?['base_price_db']}";
    }
    return "${message.metadata?['total_price_db']}";
  }

  String get orderStatus => getOrderStatus(message.metadata?['status']).toUpperCase();

  bool get checkedOut => message.metadata?['status'] == 'checked_out';

  bool get paymentPending => message.metadata?['status'] == "checked_out" && !GetIt.I.get<ChatUtils>().isCreatorsApp;

  bool get isCreatorsApp => GetIt.I.get<ChatUtils>().isCreatorsApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(2),
          color: ThemeUtils.defaultAppThemeData.scaffoldBackgroundColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(color: checkedOut ? Config.mentaikoColor : Theme.of(context).primaryColor),
              child: Text(
                orderStatus,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey[300]!),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${message.metadata?['id']}',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 6.0,
                      ),
                      Row(
                        children: [
                          Text(
                            getOrderDate(message.createdAt!),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            ' \u2022 ${message.metadata?['total_items']} items',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            ' \u2022 \$$totalPrice',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            //TODO Show correct order type based on HomeOrder/HomeBrand, with old Order/Brand
                            //!https://www.notion.so/tabletophq/Take-Away-Pickup-rename-b9ce98007a5145c88853bcb8ad2817be?d=b8f06bdfb9024354bf33f5b54183f956
                            ' \u2022 ${getOrderType(message.metadata)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 26.0,
                      ),
                      GestureDetector(
                        onTap: () => context.push(
                            RouteParser(paymentPending ? Routes.orderPaymentRoute : Routes.orderDetailRoute)
                                .reverse({'id': "${message.metadata?['id']}"})),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              border: Border.all(color: paymentPending ? Config.mentaikoColor : Colors.grey[300]!)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  paymentPending ? 'assets/icon/payment.svg' : 'assets/icon/order_details.svg',
                                  package: 'ttp_chat',
                                  color: paymentPending ? Config.mentaikoColor : Theme.of(context).primaryColor,
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  getButtonText(message.metadata?['status']),
                                  style: TextStyle(
                                      color: paymentPending ? Config.mentaikoColor : Theme.of(context).primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String getButtonText(String status) {
    bool isCreatorsApp = GetIt.I<ChatUtils>().isCreatorsApp;
    String btnText = 'View Order';

    switch (status) {
      case 'checked_out':
        return isCreatorsApp ? btnText : 'Go to Payment ';
      case 'pending_completion':
        return isCreatorsApp ? btnText : 'Mark as Received';
      case 'expired':
        return isCreatorsApp ? btnText : 'Reorder';
      default:
        return btnText;
    }
  }

  static String getOrderStatus(String status) {
    bool isCreatorsApp = GetIt.I<ChatUtils>().isCreatorsApp;
    switch (status) {
      case 'paid':
        return isCreatorsApp ? 'New' : 'Pending';
      case 'checked_out':
        return 'Pending Payment';
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
        return 'Disputed';
      case 'expired':
        return 'Expired';
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
}
